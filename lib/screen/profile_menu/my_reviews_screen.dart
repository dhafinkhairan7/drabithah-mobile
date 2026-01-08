import 'package:flutter/material.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ulasan Saya", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text("Golden Dawn"),
            subtitle: Text("⭐⭐⭐⭐⭐ Wanginya enak banget, tahan lama!"),
            leading: Icon(Icons.star, color: Colors.amber),
          ),
          Divider(),
          ListTile(
            title: Text("Aura Elixir"),
            subtitle: Text("⭐⭐⭐⭐ Pengiriman cepat, packing aman."),
            leading: Icon(Icons.star, color: Colors.amber),
          ),
        ],
      ),
    );
  }
}