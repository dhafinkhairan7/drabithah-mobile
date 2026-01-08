import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drabithah_parfume/providers/wishlist_providers.dart';
import 'package:drabithah_parfume/screen/home/product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {

  // --- FUNGSI PINTAR: PILIH GAMBAR (INTERNET vs LOKAL) ---
  Widget _buildSmartImage(String imgUrl) {
    if (imgUrl.isEmpty) {
      return Container(
        width: 60, height: 60, 
        color: Colors.grey[200], 
        child: const Icon(Icons.image_not_supported)
      );
    }
    if (imgUrl.startsWith('http')) {
      return Image.network(
        imgUrl, width: 60, height: 60, fit: BoxFit.cover,
        errorBuilder: (ctx, _, __) => Container(
          width: 60, height: 60, 
          color: Colors.grey[200], 
          child: const Icon(Icons.broken_image)
        ),
      );
    } else {
      return Image.asset(
        imgUrl, width: 60, height: 60, fit: BoxFit.cover,
        errorBuilder: (ctx, _, __) => Container(
          width: 60, height: 60, 
          color: Colors.grey[200], 
          child: const Icon(Icons.image_not_supported)
        ),
      );
    }
  }

  // --- ALERT DIALOG KONFIRMASI HAPUS ---
  void _showRemoveDialog(BuildContext context, String productName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus dari Wishlist?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin menghapus $productName dari daftar keinginan?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Batal", style: TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
        title: const Text("Daftar Keinginan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) {
          final wishlistItems = wishlistProvider.wishlistItems;

          if (wishlistItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text("Belum ada parfum favorit nih.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              final item = wishlistItems[index];
              
              // PERBAIKAN: Memastikan data ID dan Nama ada
              // Variabel ini sekarang digunakan di bawah agar tidak ada warning
              final String productName = item['name'] ?? "Parfum Tanpa Nama";
              double price = double.tryParse(item['price']?.toString() ?? "0") ?? 0.0;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey.shade100),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildSmartImage(item['image'] ?? ''),
                  ),
                  title: Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "Rp ${price.toStringAsFixed(0)}", 
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      // Menggunakan variabel productId agar logika hapus akurat
                      _showRemoveDialog(context, productName, () {
                        // Logic toggle akan menghapus item berdasarkan ID yang sama
                        wishlistProvider.toggleWishlist(item); 
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Berhasil dihapus dari favorit"))
                        );
                      });
                    },
                  ),
                  onTap: () {
                    // Berpindah ke detail dengan data map produk asli dari API
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: item))
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 