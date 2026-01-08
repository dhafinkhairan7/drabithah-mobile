import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan Akun", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          ListTile(leading: const Icon(Icons.lock_outline), title: const Text("Ubah Kata Sandi"), onTap: () {}),
          const Divider(),
          ListTile(leading: const Icon(Icons.phone_android), title: const Text("Ubah Nomor Telepon"), onTap: () {}),
          const Divider(),
          ListTile(leading: const Icon(Icons.location_on_outlined), title: const Text("Alamat Saya"), onTap: () {}),
          const Divider(),
          ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text("Notifikasi"), trailing: Switch(value: true, onChanged: (v){})),
        ],
      ),
    );
  }
}