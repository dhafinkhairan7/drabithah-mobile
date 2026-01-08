import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drabithah_parfume/providers/cart_providers.dart';
import 'package:drabithah_parfume/providers/wishlist_providers.dart';
import 'package:drabithah_parfume/screen/cart/cart_screen.dart';
import 'package:drabithah_parfume/screen/home/product_detail_screen.dart';
import 'package:drabithah_parfume/screen/home/all_product_screen.dart';
import 'package:drabithah_parfume/screen/catalog/catalog_screen.dart';
import 'package:drabithah_parfume/screen/wishlist/wishlist_screen.dart';
import 'package:drabithah_parfume/screen/profile/profile_screen.dart';
import 'package:drabithah_parfume/services/product_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<dynamic> _allProducts = [];
  bool _isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeContent(products: _allProducts, isLoading: _isLoading, onRefresh: _fetchData),
      const WishlistScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFFFFC107),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wishlist"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "Troli"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final List<dynamic> products;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const HomeContent({super.key, required this.products, required this.isLoading, required this.onRefresh});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _searchQuery = "";

  Widget _buildSmartImage(String imgUrl) {
    if (imgUrl.startsWith('http')) {
      return Image.network(imgUrl, width: double.infinity, fit: BoxFit.cover,
        errorBuilder: (ctx, _, __) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)));
    } else {
      return Image.asset(imgUrl, width: double.infinity, fit: BoxFit.cover,
        errorBuilder: (ctx, _, __) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported)));
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
          TextButton(onPressed: () { Navigator.pop(ctx); onConfirm(); }, child: const Text("Ya, Lanjutkan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = widget.products.where((product) {
      return product['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: const Text("D'rabithah"), 
        actions: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) => Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined), 
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CartScreen())),
                      ),
                      if (cart.itemCount > 0)
                        Positioned(
                          right: 2, 
                          top: 2, 
                          child: CircleAvatar(
                            radius: 8, 
                            backgroundColor: Colors.red, 
                            child: Text(
                              '${cart.itemCount}', 
                              style: const TextStyle(fontSize: 10, color: Colors.white)
                            )
                          )
                        )
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.grid_view_outlined), 
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CatalogScreen()))
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "Cari parfum...", prefixIcon: const Icon(Icons.search, color: Colors.amber),
                    filled: true, fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),

                if (widget.isLoading)
                   const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: CircularProgressIndicator(color: Colors.amber)))
                else if (widget.products.isEmpty)
                   const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text("Data Kosong / Gagal Load.")))
                else ...[
                  if (_searchQuery.isEmpty) ...[
                    SizedBox(
                      height: 160,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildBannerItem("Spring Collection", "Temukan", "https://images.unsplash.com/photo-1615634260167-c8cdede054de?q=80&w=800"),
                          const SizedBox(width: 15),
                          _buildBannerItem("Exclusive Deal", "Belanja", "https://images.unsplash.com/photo-1541643600914-78b084683601?q=80&w=800"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text("Jelajahi Kategori", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCategoryItem("Eau de Parfum", Icons.local_drink), 
                        _buildCategoryItem("Eau de Toilette", Icons.opacity),
                        _buildCategoryItem("Katalog", Icons.grid_view, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CatalogScreen()))),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Produk Unggulan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
                        GestureDetector(
                          onTap: () {
                            List<Map<String, dynamic>> safeList = widget.products.map((e) => Map<String, dynamic>.from(e)).toList();
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AllProductsScreen(products: safeList)));
                          },
                          child: const Text("Lihat Semua", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.70, crossAxisSpacing: 15, mainAxisSpacing: 15),
                    itemCount: _searchQuery.isEmpty ? (filteredProducts.length > 4 ? 4 : filteredProducts.length) : filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = Map<String, dynamic>.from(filteredProducts[index]);
                      return _buildProductCard(context, product);
                    },
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerItem(String title, String btnText, String imgUrl) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken)),
        color: Colors.grey[300],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
            child: Text(btnText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, height: 100,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.black87, size: 28), const SizedBox(height: 10), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))]),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    // FIX LOGIC: Mengambil ID unik dari data MockAPI
    final String productId = product['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    double price = double.tryParse(product['price'].toString()) ?? 0.0;

    return Consumer<WishlistProvider>(
      builder: (context, wishlist, _) {
        bool isLoved = wishlist.isWishlisted(productId);
        return GestureDetector(
          onTap: () => _showConfirmationDialog(context, "Lihat Detail Produk?", "Apakah Anda ingin melihat detail dari ${product['name']}?", () => Navigator.push(context, MaterialPageRoute(builder: (c) => ProductDetailScreen(product: product)))),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 5))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: _buildSmartImage(product['image'] ?? ''),
                      ),
                      Positioned(
                        right: 8, top: 8,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => _showConfirmationDialog(context, isLoved ? "Hapus Wishlist?" : "Simpan Wishlist?", "Update daftar keinginan?", () => wishlist.toggleWishlist(product)),
                              child: CircleAvatar(radius: 16, backgroundColor: Colors.white.withValues(alpha: 0.9), child: Icon(isLoved ? Icons.favorite : Icons.favorite_border, size: 18, color: isLoved ? Colors.red : Colors.black54)),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _showConfirmationDialog(context, "Tambah ke Keranjang?", "Masukkan ${product['name']} ke troli?", () {
                                // PANGGIL PROVIDER DENGAN ID UNIK
                                Provider.of<CartProvider>(context, listen: false).addItem(
                                  productId, 
                                  product['name'], 
                                  price, 
                                  product['image'] ?? ''
                                );
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil masuk keranjang!"), duration: const Duration(milliseconds: 500)));
                              }),
                              child: const CircleAvatar(radius: 16, backgroundColor: Colors.amber, child: Icon(Icons.add, size: 20, color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product['name'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Serif'), maxLines: 1), const SizedBox(height: 4), Text("Rp ${price.toStringAsFixed(0)}", style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold, fontSize: 14))]),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}