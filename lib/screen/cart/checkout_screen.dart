import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drabithah_parfume/providers/cart_providers.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    
    // Perhitungan Ringkasan Pesanan
    double subtotal = cart.totalAmount;
    double pengiriman = 25000;
    double diskon = 50000;
    double pajak = subtotal * 0.1; // Pajak 10%
    double total = subtotal + pengiriman + pajak - diskon;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. ALAMAT PENGIRIMAN
            _buildCheckoutCard(
              title: "Alamat Pengiriman",
              actionText: "Edit",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Budi Santoso", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text("+62 812 3456 7890", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 5),
                  const Text("Jl. Melati Raya No. 123", style: TextStyle(color: Colors.grey)),
                  const Text("Jakarta Selatan, DKI Jakarta 12345", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. METODE PEMBAYARAN
            _buildCheckoutCard(
              title: "Metode Pembayaran",
              actionText: "Ubah",
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.credit_card, color: Colors.amber),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Visa **** 1234", style: TextStyle(fontWeight: FontWeight.bold)),
                      const Text("Kedaluwarsa: 12/26", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. RINGKASAN PESANAN
            _buildCheckoutCard(
              title: "Ringkasan Pesanan",
              actionText: "",
              child: Column(
                children: [
                  _buildSummaryRow("Subtotal", "Rp ${subtotal.toStringAsFixed(0)}"),
                  _buildSummaryRow("Pengiriman", "Rp ${pengiriman.toStringAsFixed(0)}"),
                  _buildSummaryRow("Diskon", "-Rp ${diskon.toStringAsFixed(0)}", isDiscount: true),
                  _buildSummaryRow("Pajak", "Rp ${pajak.toStringAsFixed(0)}"),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        "Rp ${total.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 4. TOMBOL KONFIRMASI (LOGIC JALAN)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Alert Konfirmasi
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Konfirmasi Pembelian"),
                      content: const Text("Apakah Anda yakin ingin menyelesaikan transaksi ini?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx); // Tutup Dialog
                            cart.clear(); // Kosongkan Keranjang
                            Navigator.of(context).popUntil((route) => route.isFirst); // Balik ke Home
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Pembelian Berhasil!"), backgroundColor: Colors.green)
                            );
                          },
                          child: const Text("Ya, Beli", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  "Konfirmasi Pembelian (Rp ${total.toStringAsFixed(0)})",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER CARD ---
  Widget _buildCheckoutCard({required String title, required String actionText, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (actionText.isNotEmpty)
                Text(actionText, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(color: isDiscount ? Colors.red : Colors.black, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}