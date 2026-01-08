import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pusat Bantuan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ExpansionTile(title: Text("Bagaimana cara memesan?"), children: [Padding(padding: EdgeInsets.all(15), child: Text("Pilih produk, masukkan keranjang, lalu checkout."))]),
          ExpansionTile(title: Text("Apakah barang original?"), children: [Padding(padding: EdgeInsets.all(15), child: Text("Ya, semua parfum Drabithah 100% Original."))]),
          ExpansionTile(title: Text("Berapa lama pengiriman?"), children: [Padding(padding: EdgeInsets.all(15), child: Text("Estimasi 2-4 hari kerja tergantung lokasi."))]),
        ],
      ),
    );
  }
}