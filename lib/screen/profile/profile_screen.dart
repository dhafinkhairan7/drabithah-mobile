import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:drabithah_parfume/screen/auth/login_screen.dart';
import 'package:drabithah_parfume/screen/profile_menu/my_order_screen.dart';
import 'package:drabithah_parfume/screen/profile_menu/my_reviews_screen.dart';
import 'package:drabithah_parfume/screen/profile_menu/account_settings_screen.dart';
import 'package:drabithah_parfume/screen/profile_menu/help_center_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = "Loading...";
  String _userEmail = "Loading...";
  String? _imagePath; // Menyimpan lokasi foto di HP

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 1. Load Data User & Foto Profil
  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "Tamu";
      _userEmail = prefs.getString('userEmail') ?? "Belum Login";
      _imagePath = prefs.getString('profileImage'); // Ambil path foto jika ada
    });
  }

  // 2. Fungsi Ganti Foto (Pake Image Picker)
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Buka Galeri
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Simpan Path Foto ke Memori HP
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', image.path);

      setState(() {
        _imagePath = image.path; // Update tampilan
      });
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto Profil Berhasil Diubah!")));
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Batal", style: TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleLogout();
            }, 
            child: const Text("Ya, Keluar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            // --- BAGIAN FOTO PROFIL (BISA DIGANTI) ---
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[200],
                  // Logic Foto: Kalau ada path file pakai FileImage, kalau ga ada pakai Icon
                  backgroundImage: _imagePath != null 
                      ? FileImage(File(_imagePath!)) 
                      : null,
                  child: _imagePath == null 
                      ? const Icon(Icons.person, size: 60, color: Colors.grey) 
                      : null,
                ),
                // Tombol Kamera Kecil
                Positioned(
                  bottom: 0, right: 0,
                  child: GestureDetector(
                    onTap: _pickImage, // Klik buat ganti foto
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                )
              ],
            ),
            
            const SizedBox(height: 15),
            
            // NAMA & EMAIL
            Text(_userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(_userEmail, style: const TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 30),
            
            // --- OPSI AKUN (TOMBOL BERFUNGSI) ---
            const Align(alignment: Alignment.centerLeft, child: Text("Opsi Akun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 10),
            
            _buildProfileMenu(
              icon: Icons.shopping_bag_outlined, 
              title: "Pesanan Saya", 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const MyOrdersScreen()))
            ),
            
            _buildProfileMenu(
              icon: Icons.star_outline, 
              title: "Ulasan Saya", 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const MyReviewsScreen()))
            ),

            // "Daftar Keinginan" SUDAH DIHAPUS (Sesuai request)

            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft, child: Text("Pengaturan & Dukungan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 10),

            _buildProfileMenu(
              icon: Icons.settings_outlined, 
              title: "Pengaturan Akun", 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AccountSettingsScreen()))
            ),
            
            _buildProfileMenu(
              icon: Icons.help_outline, 
              title: "Pusat Bantuan", 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HelpCenterScreen()))
            ),

            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft, child: Text("Lain-lain", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 10),

            // LOGOUT
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.logout, color: Colors.red),
                ),
                title: const Text("Keluar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () => _showLogoutConfirmationDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET TOMBOL MENU BIAR RAPI
  Widget _buildProfileMenu({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.amber[700]),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}