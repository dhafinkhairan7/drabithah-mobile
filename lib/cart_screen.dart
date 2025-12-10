// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item_model.dart';

import '../utils/format_utils.dart'; // nanti buat file util di bawah

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();
  double discount = 0; // contohnya potongan

  void applyPromo() {
    final code = _promoController.text.trim();
    setState(() {
      // Contoh sederhana: kode "PROMO10" diskon 10% subtotal
      if (code.isEmpty) {
        discount = 0;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan kode promo')),
        );
        return;
      }
      if (code.toUpperCase() == 'PROMO10') {
        discount = 0.10;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kode PROMO10 diterapkan: 10% off')),
        );
      } else {
        discount = 0;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kode promo tidak valid')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Anda'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: items.isEmpty
            ? const Center(child: Text('Keranjang Anda kosong'))
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final CartItem ci = items[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  ci.product.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ci.product.series, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text(ci.product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 8),
                                    Text(
                                      formatCurrency(ci.product.price),
                                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ),
                              // Qty controls
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                   ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
                                          icon: const Icon(Icons.remove, size: 20),
                                          onPressed: () => context.read<CartProvider>().decreaseQuantity(ci.product.id),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Text('${ci.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
                                          icon: const Icon(Icons.add, size: 20),
                                          onPressed: () => context.read<CartProvider>().increaseQuantity(ci.product.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () => context.read<CartProvider>().removeItem(ci.product.id),
                                    icon: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade700),
                                    label: Text('Hapus', style: TextStyle(color: Colors.red.shade700)),
                                  ),
                                ],
                               ),
                           ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Promo input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          decoration: const InputDecoration(
                            hintText: 'Masukkan kode promo',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: applyPromo,
                        child: const Text('Terapkan'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Summary
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text(formatCurrency(cart.subtotal)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Pengiriman'),
                          const Text('Gratis'),
                        ],
                      ),
                      if (discount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Diskon'),
                            Text('- ${ (discount * 100).toStringAsFixed(0)}%'),
                          ],
                        ),
                      ],
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          Text(
                            formatCurrency(cart.subtotal * (1 - discount)),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: navigasi ke pembayaran / checkout flow
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lanjut ke Pembayaran (dummy)')),
                            );
                          },

                          // >>> FIX 2: Tombol Lanjutkan ke Pembayaran (Ganti style)
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, // Warna oranye
                            foregroundColor: Colors.white, // Warna teks putih
                            padding: const EdgeInsets.symmetric(vertical: 18.0), // Padding lebih besar
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Sudut membulat
                          ),
                          child: const Text(
                            'Lanjutkan ke Pembayaran',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}