import 'package:flutter/material.dart';
import 'wishlist_screen.dart'; // Pastikan file ini ada di project kamu

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandColorText = Color(0xFFFFA000); 

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'Profile',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        automaticallyImplyLeading: false, // Hilangkan tombol back di menu utama
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- BAGIAN 1: KARTU PROFIL ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.orange,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=5'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            _navigateTo(context, "Edit Profil");
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                            ),
                            child: const Icon(Icons.edit, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Drabithah Parfume',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.black87
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'drabithah.parfume@example.com',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- BAGIAN 2: OPSI AKUN ---
            _buildSectionLabel('Opsi Akun'),
            Container(
              decoration: _boxDecoration(),
              child: Column(
                children: [
                  _buildMenuTile(
                    Icons.inventory_2_outlined,
                    'Pesanan Saya',
                    brandColorText,
                    () => _navigateTo(context, "Pesanan Saya"),
                  ),
                  _buildDivider(),
                  // --- TOMBOL DAFTAR KEINGINAN (KE WISHLIST ASLI) ---
                  _buildMenuTile(
                    Icons.favorite_border,
                    'Daftar Keinginan',
                    brandColorText,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WishlistScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuTile(
                    Icons.star_border,
                    'Ulasan Saya',
                    brandColorText,
                    () => _navigateTo(context, "Ulasan Saya"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- BAGIAN 3: PENGATURAN & DUKUNGAN ---
            _buildSectionLabel('Pengaturan & Dukungan'),
            Container(
              decoration: _boxDecoration(),
              child: Column(
                children: [
                  _buildMenuTile(
                    Icons.settings_outlined,
                    'Pengaturan Akun',
                    brandColorText,
                    () => _navigateTo(context, "Pengaturan Akun"),
                  ),
                  _buildDivider(),
                  _buildMenuTile(
                    Icons.help_outline,
                    'Pusat Bantuan',
                    brandColorText,
                    () => _navigateTo(context, "Pusat Bantuan"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- BAGIAN 4: LAIN-LAIN (LOGOUT) ---
            _buildSectionLabel('Lain-lain'),
            Container(
              decoration: _boxDecoration(),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.orange),
                title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ),
            
            // Jarak tambahan di bawah agar tidak ketutup navigasi
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // LOGIC & HELPER FUNCTIONS
  // =========================================================================

  // 1. Fungsi Navigasi ke Halaman Dummy
  void _navigateTo(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimplePage(title: title),
      ),
    );
  }

  // 2. Fungsi Menampilkan Dialog Logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Simulasi Logout
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Berhasil Keluar")),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Keluar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 3. Widget Judul Section
  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: Colors.black87
          ),
        ),
      ),
    );
  }

  // 4. Widget Dekorasi Kotak Putih
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.05),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  // 5. Widget Item Menu (Tile)
  Widget _buildMenuTile(IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  // 6. Widget Garis Pembatas
  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, indent: 20, endIndent: 20);
  }
}

// =========================================================================
// CLASS DUMMY PAGE (Untuk halaman yang belum jadi)
// =========================================================================
class SimplePage extends StatelessWidget {
  final String title;
  const SimplePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Halaman ini sedang dikembangkan",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}