import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drabithah_parfume/providers/cart_providers.dart';
import 'package:drabithah_parfume/providers/wishlist_providers.dart';
import 'package:drabithah_parfume/screen/cart/cart_screen.dart';
import 'package:drabithah_parfume/screen/wishlist/wishlist_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedSizeIndex = 0;
  final List<String> _sizes = ["30 ml", "50 ml", "100 ml"];

  // --- FUNGSI PINTAR: DETEKSI TIPE GAMBAR (INTERNET VS LOKAL) ---
  ImageProvider _getSmartImageProvider(String imgUrl) {
    if (imgUrl.isEmpty) {
      return const AssetImage('assets/placeholder.png'); // Gambar cadangan jika kosong
    }
    
    if (imgUrl.startsWith('http')) {
      // Jika link dari internet (MockAPI)
      return NetworkImage(imgUrl);
    } else {
      // Jika link dari file lokal (assets/...)
      return AssetImage(imgUrl);
    }
  }

  void _showConfirmationDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), 
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("BATAL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text("YA, LANJUTKAN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Safe Parsing Harga
    double price = 0.0;
    if (widget.product['price'] != null) {
      price = double.tryParse(widget.product['price'].toString()) ?? 0.0;
    }
    
    // Ambil Data String agar aman
    String imageUrl = widget.product['image'] ?? '';
    String description = widget.product['description'] ?? "Untuk kamu yang berani tampil beda. Suntikan energi dan kemewahan dalam setiap semprotan.";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Drabithah", style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const WishlistScreen())),
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CartScreen())),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 5, top: 5,
                    child: CircleAvatar(
                      radius: 7, backgroundColor: const Color(0xFFD32F2F),
                      child: Text('${cart.itemCount}', style: const TextStyle(fontSize: 9, color: Colors.white)),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text("HANYA DI ONLINE", style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            const Text("DRABITHAH PARFUME", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 5),
            Text("${widget.product['name']} - Eau De Parfum", textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 10),
            
            // RATING
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Color(0xFFD32F2F), size: 16),
                Icon(Icons.star, color: Color(0xFFD32F2F), size: 16),
                Icon(Icons.star, color: Color(0xFFD32F2F), size: 16),
                Icon(Icons.star, color: Color(0xFFD32F2F), size: 16),
                Icon(Icons.star, color: Color(0xFFD32F2F), size: 16),
                SizedBox(width: 8),
                Text("24 Ulasan Produk", style: TextStyle(decoration: TextDecoration.underline, fontSize: 12)),
              ],
            ),
            
            const SizedBox(height: 15),
            Text("Rp ${price.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text("Cepat! Stok hanya tersisa sedikit!", style: TextStyle(color: Color(0xFFD32F2F), fontSize: 12, fontStyle: FontStyle.italic)),
            const SizedBox(height: 25),

            // --- GAMBAR PINTAR (SMART IMAGE) ---
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    image: DecorationImage(
                      // PANGGIL FUNGSI PINTAR DI SINI
                      image: _getSmartImageProvider(imageUrl), 
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // IKON LOVE & TAMBAH
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Consumer<WishlistProvider>(
                        builder: (context, wishlist, _) {
                          bool isLoved = wishlist.isWishlisted(widget.product['id'].toString());
                          return IconButton(
                            onPressed: () {
                               _showConfirmationDialog(
                                  context, 
                                  isLoved ? "Hapus Wishlist?" : "Simpan Wishlist?", 
                                  "Update daftar keinginan?", 
                                  () => wishlist.toggleWishlist(widget.product)
                               );
                            },
                            icon: Icon(
                              isLoved ? Icons.favorite : Icons.favorite_border,
                              color: Colors.black,
                              size: 30,
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: 10),
                      IconButton(
                        onPressed: () {
                          _showConfirmationDialog(
                            context, 
                            "TAMBAH KE TAS", 
                            "Masukkan ${widget.product['name']} ke tas belanja?", 
                            () {
                              Provider.of<CartProvider>(context, listen: false).addItem(
                                widget.product['id'].toString(), 
                                widget.product['name'], 
                                price, 
                                imageUrl
                              );
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produk ditambahkan ke Tas")));
                            }
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 30),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Divider(thickness: 0.5),
            const SizedBox(height: 20),

            // UKURAN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Align(alignment: Alignment.centerLeft, child: Text("Ukuran: ${_sizes[_selectedSizeIndex]}", style: const TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(_sizes.length, (index) {
                      bool isSelected = _selectedSizeIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSizeIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(_sizes[index], style: TextStyle(color: isSelected ? Colors.black : Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildInfoSection("DESCRIPTION", "Tentang Produk:", description),
            ),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String subtitle, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 10),
        Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(content, style: const TextStyle(height: 1.5, color: Colors.black87)),
        const SizedBox(height: 20),
        const Divider(thickness: 0.5),
      ],
    );
  }
}