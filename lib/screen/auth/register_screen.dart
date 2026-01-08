import 'package:flutter/material.dart';
import 'package:drabithah_parfume/services/auth_service.dart';
import 'package:drabithah_parfume/screen/auth/login_screen.dart'; // Arahkan ke Login

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleRegister() async {
    // Validasi
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mohon isi semua data!")));
      return;
    }

    setState(() => _isLoading = true);

    final auth = AuthService();
    // Panggil Service Register (Logic tetap sama)
    bool success = await auth.register(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      
      // --- LOGIC BARU SESUAI REQUEST ---
      // Sukses Daftar -> Pindah ke Halaman Login (Bukan Home)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Daftar Berhasil! Silakan Login."), backgroundColor: Colors.green),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal Daftar. Cek koneksi."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Buat Akun Baru"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.person_add_alt_1, size: 60, color: Colors.amber),
              const SizedBox(height: 20),
              
              // Input Nama
              _buildInput("Nama Lengkap", _nameController, Icons.person_outline, false),
              const SizedBox(height: 16),
              
              // Input Email
              _buildInput("Email", _emailController, Icons.email_outlined, false),
              const SizedBox(height: 16),
              
              // Input HP
              _buildInput("Nomor HP", _phoneController, Icons.phone_android, false),
              const SizedBox(height: 16),
              
              // Input Password
              _buildInput("Password", _passwordController, Icons.lock_outline, true),
              const SizedBox(height: 30),

              // Tombol Daftar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("DAFTAR SEKARANG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget kecil biar codingan rapi
  Widget _buildInput(String label, TextEditingController controller, IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}