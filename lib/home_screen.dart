// File: lib/home_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// --- IMPORTS ---
import 'wishlist_screen.dart';
import 'models/product_model.dart';
import 'providers/wishlist_provider.dart';
import 'providers/cart_provider.dart';
import 'cart_screen.dart';

// --- MOCK DATA LOKAL ---
final List<Product> localFeaturedProducts = [
  Product(
    id: '101',
    name: 'Casablanca',
    series: 'Arabian Series',
    price: 45000.0,
    imageUrl: 'assets/images/casablanca.jpg',
  ),
  Product(
    id: '102',
    name: 'Ghissah',
    series: 'Arabian Series',
    price: 45000.0,
    imageUrl: 'assets/images/ghissah.jpg',
  ),
  Product(
    id: '103',
    name: 'Riyadh',
    series: 'Arabian Series',
    price: 45000.0,
    imageUrl: 'assets/images/riyadh.jpg',
  ),
  Product(
    id: '104',
    name: 'Aljubail',
    series: 'Arabian Series',
    price: 45000.0,
    imageUrl: 'assets/images/aljubail.jpg',
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _featuredProductsFuture;
  final String mockApiUrl =
      'https://api.mockfly.dev/mocks/39564858-aa86-4f4d-91b6-d5c4146a48d8/products';

  @override
  void initState() {
    super.initState();
    _featuredProductsFuture = fetchFeaturedProducts();
  }

  Future<List<Product>> fetchFeaturedProducts() async {
    try {
      final response = await http.get(Uri.parse(mockApiUrl));
      List<dynamic> jsonList = [];

      if (response.statusCode == 200) {
        jsonList = jsonDecode(response.body);
      }
      if (jsonList.isEmpty) return localFeaturedProducts;
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      return localFeaturedProducts;
    }
  }

  Future<void> addToCart(Product product) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.addItem(product, quantity: 1);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} berhasil ditambahkan!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugPrint('Error lokal: $e');
    }

    final Uri cartUri = Uri.parse(
      'https://api.mockfly.dev/mocks/39564858-aa86-4f4d-91b6-d5c4146a48d8/cart',
    );
    try {
      await http.post(
        cartUri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'product_id': product.id, 'quantity': 1}),
      );
    } catch (e) {
      debugPrint('API Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomAppBar(context, wishlistProvider.wishlistItems.length),
              const SizedBox(height: 16),

              _buildModernBanner(), // Banner Baru (Tanpa Gambar, Tanpa Error)
              
              const SizedBox(height: 24),
              
              // Statistik
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatInfo('140+', 'Produk'),
                      _buildStatInfo('1M+', 'Terjual'),
                      _buildStatInfo('80+', 'Outlet'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kategori Pilihan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    TextButton(onPressed: (){}, child: const Text("Lihat Semua")),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildCategoryGrid(context),
              
              const SizedBox(height: 24),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Produk Unggulan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),
              
              _buildFeaturedProductsList(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET MODERN FIXED ---

  Widget _buildCustomAppBar(BuildContext context, int wishlistCount) {
    final cartProvider = context.watch<CartProvider>();
    final cartUnitCount = cartProvider.totalUnits;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Selamat Datang,", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      'Drabithah Store',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildIconBtn(context, Icons.favorite_outline, wishlistCount, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
                  }),
                  const SizedBox(width: 8),
                  _buildIconBtn(context, Icons.shopping_bag_outlined, cartUnitCount, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari parfum favoritmu...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.tune, color: Colors.grey, size: 20),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn(BuildContext context, IconData icon, int count, VoidCallback onTap) {
    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Icon(icon, size: 24, color: Colors.black87),
          ),
        ),
        if (count > 0)
          Positioned(
            right: 5,
            top: 5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
            ),
          ),
      ],
    );
  }

  // >>> BANNER SIMPLE & ELEGANT (GAK PAKE GAMBAR) <<<
  Widget _buildModernBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        // GAK ADA Height fixed, biar melar ngikutin isi text
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Gradient pengganti gambar
          gradient: const LinearGradient(
            colors: [Color(0xFF1F1C18), Color(0xFF4A4A4A)], // Hitam ke Abu
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.orange.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                child: const Text('PROMO SPESIAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Arabian Parfume', 
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 24, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 220, 
                child: Text(
                  'Rasakan kemewahan aroma premium tahan lama.',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Beli Sekarang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatInfo(String number, String label) {
    return Column(
      children: [
        Text(number, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.orange)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'name': 'EDP', 'icon': Icons.opacity},
      {'name': 'EDT', 'icon': Icons.water_drop},
      {'name': 'Cologne', 'icon': Icons.local_drink},
      {'name': 'Mist', 'icon': Icons.bubble_chart},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                width: 65, height: 65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Icon(categories[index]['icon'] as IconData, color: Colors.orange, size: 28),
              ),
              const SizedBox(height: 8),
              Text(categories[index]['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeaturedProductsList() {
    return FutureBuilder<List<Product>>(
      future: _featuredProductsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada produk.'));
        } else {
          return Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              final List<Product> products = snapshot.data!;
              return SizedBox(
                height: 365, 
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    product.isFavorite = wishlistProvider.isProductInWishlist(product.id);
                    return _buildProductCard(context, product);
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final wishlistProvider = context.watch<WishlistProvider>();
    final isInWishlist = wishlistProvider.isProductInWishlist(product.id);
    final bool isNetworkImage = product.imageUrl.startsWith('http');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  product: product,
                  onAddToCart: addToCart,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 190,
                    width: 170,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: isNetworkImage
                          ? Image.network(product.imageUrl, fit: BoxFit.contain)
                          : Image.asset(product.imageUrl, fit: BoxFit.contain,
                              errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: () => context.read<WishlistProvider>().toggleWishlist(product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                        ),
                        child: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isInWishlist ? Colors.red : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.series,
                      style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        const Text('4.8', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        const Text(' (2.4k)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Rp ${product.price.toStringAsFixed(0)}', 
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: () => addToCart(product),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// Product Detail Screen (Sama, FIX Grey Color Error)
// =================================================================

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final Function(Product) onAddToCart;

  const ProductDetailScreen({super.key, required this.product, required this.onAddToCart});

  void _showSizeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih Ukuran Botol', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                children: ['30ml', '50ml', '100ml'].map((size) {
                  return ChoiceChip(
                    label: Text(size), 
                    selected: size == '50ml',
                    onSelected: (val){},
                    selectedColor: Colors.orange.withOpacity(0.2),
                    labelStyle: TextStyle(color: size == '50ml' ? Colors.orange : Colors.black),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onAddToCart(product);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Konfirmasi & Masuk Keranjang', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage = product.imageUrl.startsWith('http');
    
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        final bool isProductInWishlist = wishlistProvider.isProductInWishlist(product.id);
        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(isProductInWishlist ? Icons.favorite : Icons.favorite_border, color: isProductInWishlist ? Colors.red : Colors.black),
                      onPressed: () => context.read<WishlistProvider>().toggleWishlist(product),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: Colors.grey[50],
                    padding: const EdgeInsets.all(40),
                    child: isNetworkImage
                        ? Image.network(product.imageUrl, fit: BoxFit.contain)
                        : Image.asset(product.imageUrl, fit: BoxFit.contain),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 50, height: 5, 
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(product.series, style: const TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.star, size: 20, color: Colors.amber[700]),
                            const SizedBox(width: 4),
                            const Text('4.8 (2.4k Reviews)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                              child: const Text("Tersedia", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Rp ${product.price.toStringAsFixed(0)}', 
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black)),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        const Text('Deskripsi Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text(
                          'Parfum ini menghadirkan perpaduan sempurna dari aroma timur yang misterius dan mewah. Cocok untuk menemani aktivitas harian Anda dengan ketahanan hingga 12 jam. Top notes bergamot, middle notes rose, base notes oud.',
                          style: TextStyle(height: 1.6, fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  // FIX ERROR GREY DISINI: Pakai Colors.grey.shade300 atau Colors.grey[300]!
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showSizeSelection(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Tambah Keranjang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}