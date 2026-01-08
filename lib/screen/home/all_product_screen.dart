import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drabithah_parfume/providers/cart_providers.dart'; 
import 'package:drabithah_parfume/providers/wishlist_providers.dart'; 
import 'package:drabithah_parfume/screen/home/product_detail_screen.dart';

class AllProductsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;

  const AllProductsScreen({super.key, required this.products});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  
  // --- FUNGSI PINTAR: PILIH GAMBAR INTERNET ATAU LOKAL ---
  Widget _buildSmartImage(String imgUrl) {
    if (imgUrl.isEmpty) {
      return Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported));
    }

    if (imgUrl.startsWith('http')) {
      return Image.network(
        imgUrl, 
        width: double.infinity, 
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (ctx, _, __) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
      );
    } else {
      return Image.asset(
        imgUrl, 
        width: double.infinity, 
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (ctx, _, __) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
      );
    }
  }

  // Alert Dialog Helper
  void _showConfirmationDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () { Navigator.pop(ctx); onConfirm(); },
            child: const Text("Ya, Lanjutkan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Semua Koleksi", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: widget.products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.70, 
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemBuilder: (context, index) {
            final product = widget.products[index];
            
            // 1. AMBIL ID UNIK DARI DATA PRODUK (PENTING!)
            final String productId = product['id']?.toString() ?? index.toString();
            
            double price = double.tryParse(product['price'].toString()) ?? 0.0;

            return Consumer<WishlistProvider>(
              builder: (context, wishlist, _) {
                // Gunakan productId unik untuk pengecekan wishlist
                bool isLoved = wishlist.isWishlisted(productId);
                
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ProductDetailScreen(product: product))),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded( 
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: _buildSmartImage(product['image'] ?? ''),
                                ),
                              ),
                              Positioned(
                                right: 8, top: 8,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showConfirmationDialog(
                                        context, 
                                        isLoved ? "Hapus Wishlist?" : "Simpan Wishlist?", 
                                        "Update daftar keinginan?", 
                                        () => wishlist.toggleWishlist(product)
                                      ),
                                      child: CircleAvatar(
                                        radius: 16, 
                                        backgroundColor: Colors.white.withOpacity(0.9),
                                        child: Icon(isLoved ? Icons.favorite : Icons.favorite_border, size: 18, color: isLoved ? Colors.red : Colors.black54),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () => _showConfirmationDialog(
                                        context, 
                                        "Tambah ke Keranjang?", 
                                        "Masukkan ${product['name']} ke troli?", 
                                        () {
                                          // 2. GUNAKAN productId UNIK (BUKAN "1" ATAU HARDCODE)
                                          Provider.of<CartProvider>(context, listen: false).addItem(
                                            productId, 
                                            product['name'], 
                                            price, 
                                            product['image'] ?? ''
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil masuk keranjang!"), duration: Duration(milliseconds: 500)));
                                        }
                                      ),
                                      child: CircleAvatar(
                                        radius: 16, 
                                        backgroundColor: Colors.amber, 
                                        child: const Icon(Icons.add, size: 20, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'].toString().toUpperCase(), 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Serif'), 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rp ${price.toStringAsFixed(0)}", 
                                style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold, fontSize: 14)
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            );
          },
        ),
      ),
    );
  }
}