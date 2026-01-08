import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drabithah_parfume/providers/cart_providers.dart';
import 'package:drabithah_parfume/providers/wishlist_providers.dart';
import 'package:drabithah_parfume/screen/home/product_detail_screen.dart';
import 'package:drabithah_parfume/screen/cart/cart_screen.dart';
import 'package:drabithah_parfume/services/product_service.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<dynamic> _allProducts = [];
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final service = ProductService();
      final data = await service.fetchProducts();
      setState(() {
        _allProducts = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

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

  void _showCheckoutDialog(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.itemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Keranjang masih kosong!"), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Items: ${cart.itemCount}"),
            Text("Total Harga: Rp ${cart.totalAmount.toStringAsFixed(0)}"),
            const SizedBox(height: 10),
            const Text("Lanjutkan ke pembayaran?"),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur pembayaran akan segera hadir!"), backgroundColor: Colors.amber),
              );
            },
            child: const Text("Bayar Sekarang", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _allProducts.where((product) {
      return product['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Katalog Produk", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined), 
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CartScreen()))
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 5, top: 5, 
                    child: CircleAvatar(
                      radius: 8, 
                      backgroundColor: Colors.red, 
                      child: Text('${cart.itemCount}', style: const TextStyle(fontSize: 10, color: Colors.white))
                    )
                  )
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "Cari parfum...", 
                prefixIcon: const Icon(Icons.search, color: Colors.amber),
                filled: true, 
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Product Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                : filteredProducts.isEmpty
                    ? const Center(child: Text("Tidak ada produk ditemukan."))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          itemCount: filteredProducts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.70, 
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemBuilder: (context, index) {
                            final product = Map<String, dynamic>.from(filteredProducts[index]);
                            return _buildProductCard(context, product);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) => FloatingActionButton.extended(
          onPressed: () => _showCheckoutDialog(context),
          backgroundColor: Colors.amber,
          icon: const Icon(Icons.payment, color: Colors.white),
          label: Text(
            "Checkout (${cart.itemCount})", 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final String productId = product['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    double price = double.tryParse(product['price'].toString()) ?? 0.0;

    return Consumer<WishlistProvider>(
      builder: (context, wishlist, _) {
        bool isLoved = wishlist.isWishlisted(productId);
        
        return GestureDetector(
          onTap: () => _showConfirmationDialog(
            context, 
            "Lihat Detail Produk?", 
            "Apakah Anda ingin melihat detail dari ${product['name']}?", 
            () => Navigator.push(context, MaterialPageRoute(builder: (c) => ProductDetailScreen(product: product)))
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 5))],
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
                                backgroundColor: Colors.white.withValues(alpha: 0.9),
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
                                  Provider.of<CartProvider>(context, listen: false).addItem(
                                    productId, 
                                    product['name'], 
                                    price, 
                                    product['image'] ?? ''
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Berhasil masuk keranjang!"), duration: Duration(milliseconds: 500))
                                  );
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
  }
}
