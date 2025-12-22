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
import 'all_products_screen.dart';

// --- DATA LOKAL ---
final List<Product> localAllProducts = [
  Product(
    id: '101',
    name: 'Casablanca',
    series: 'Arabian Series',
    price: 45000.0,
    imageUrl: 'assets/images/casablanca.jpg',
    description: '',
  ),
  Product(
    id: '102',
    name: 'Ghissah',
    series: 'Arabian Series',
    price: 48000.0,
    imageUrl: 'assets/images/ghissah.jpg',
    description: '',
  ),
  Product(
    id: '103',
    name: 'Riyadh',
    series: 'Arabian Series',
    price: 45000.0,
    imageUrl: 'assets/images/riyadh.jpg',
    description: '',
  ),
  Product(
    id: '104',
    name: 'Aljubail',
    series: 'Arabian Series',
    price: 45000.0,
    imageUrl: 'assets/images/aljubail.jpg',
    description: '',
  ),
  Product(
    id: '105',
    name: 'Layla',
    series: 'Luxury Series',
    price: 45000.0,
    imageUrl: 'assets/images/layla.jpg',
    description: '',
  ),
  Product(
    id: '106',
    name: 'Turaif',
    series: 'Luxury Series',
    price: 45000.0,
    imageUrl: 'assets/images/turaif.jpg',
    description: '',
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String mockApiUrl =
      'https://api.mockfly.dev/mocks/39564858-aa86-4f4d-91b6-d5c4146a48d8/products';
  final TextEditingController _searchController = TextEditingController();

  List<Product> _featuredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse(mockApiUrl));
      List<Product> allData = [];
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        allData = jsonList.map((json) => Product.fromJson(json)).toList();
      } else {
        allData = localAllProducts;
      }

      setState(() {
        // TUGAS: Mengambil hanya 3 produk untuk ditampilkan di Home
        _featuredProducts = allData.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _featuredProducts = localAllProducts.take(3).toList();
        _isLoading = false;
      });
    }
  }

  void _handleSearch(String query) {
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllProductsScreen(initialSearch: query),
        ),
      );
      _searchController.clear();
    }
  }

  void _addToCart(Product product) {
    context.read<CartProvider>().addItem(product, quantity: 1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WishlistProvider>();
    final cp = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomAppBar(
                context,
                wp.wishlistItems.length,
                cp.totalUnits,
              ),
              const SizedBox(height: 16),
              _buildModernBanner(),
              const SizedBox(height: 30),
              _buildStatSection(),
              const SizedBox(height: 30),
              _buildSectionHeader('Kategori Pilihan', null),
              const SizedBox(height: 10),
              _buildCategoryGrid(),
              const SizedBox(height: 30),
              _buildSectionHeader('Produk Unggulan', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllProductsScreen(initialSearch: ''),
                  ),
                );
              }),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildProductListView(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER (GABUNGAN TERBAIK) ---

  Widget _buildCustomAppBar(
    BuildContext context,
    int wishlistCount,
    int cartCount,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selamat Datang,",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Drabithah Store',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildIconBtn(Icons.favorite_outline, wishlistCount, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WishlistScreen(),
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  _buildIconBtn(Icons.shopping_bag_outlined, cartCount, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: _handleSearch,
              decoration: const InputDecoration(
                hintText: 'Cari parfum favoritmu...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                icon: Icon(Icons.search, color: Colors.orange),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListView() {
    return SizedBox(
      height: 340,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredProducts.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) =>
            _buildProductCard(context, _featuredProducts[index]),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final wp = context.watch<WishlistProvider>();
    final isInWishlist = wp.isProductInWishlist(product.id);

    return Container(
      width: 170,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllProductsScreen(initialSearch: ''),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 170,
                  width: 170,
                  padding: const EdgeInsets.all(15),
                  child: Image.asset(product.imageUrl, fit: BoxFit.contain),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => wp.toggleWishlist(product),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 15,
                      child: Icon(
                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isInWishlist ? Colors.red : Colors.grey,
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
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
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
    );
  }

  Widget _buildIconBtn(IconData icon, int count, VoidCallback onTap) {
    return Stack(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.black87),
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(number: '140+', label: 'Produk'),
            _StatItem(number: '1M+', label: 'Terjual'),
            _StatItem(number: '80+', label: 'Outlet'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (onTap != null)
            TextButton(onPressed: onTap, child: const Text("Lihat Semua")),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'EDP', 'icon': Icons.opacity},
      {'name': 'EDT', 'icon': Icons.water_drop},
      {'name': 'Cologne', 'icon': Icons.local_drink},
      {'name': 'Mist', 'icon': Icons.bubble_chart},
    ];
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) => Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                categories[index]['icon'] as IconData,
                color: Colors.orange,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              categories[index]['name'] as String,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1C18), Color(0xFF4A4A4A)],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROMO SPESIAL',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Arabian Parfume',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Beli Sekarang'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number, label;
  const _StatItem({required this.number, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.orange,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
