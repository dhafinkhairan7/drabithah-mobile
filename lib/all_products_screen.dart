import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/product_model.dart';
import 'providers/wishlist_provider.dart';
import 'providers/cart_provider.dart';

class AllProductsScreen extends StatefulWidget {
  final String initialSearch;

  const AllProductsScreen({Key? key, this.initialSearch = ''}) : super(key: key);

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final List<Product> _allProducts = [
    Product(
      id: '1',
      name: 'Casablanca',
      series: 'Arabian Series',
      price: 45000.0,
      imageUrl: 'assets/images/casablanca.jpg',
      description: 'Wangian floral yang segar dengan sentuhan woody yang elegan.',
    ),
    Product(
      id: '2',
      name: 'Ghissah',
      series: 'Arabian Series',
      price: 48000.0,
      imageUrl: 'assets/images/ghissah.jpg',
      description: 'Aroma oriental yang kaya dan hangat, memberikan kesan mewah.',
    ),
    Product(
      id: '3',
      name: 'Riyadh',
      series: 'Arabian Series',
      price: 46000.0,
      imageUrl: 'assets/images/riyadh.jpg',
      description: 'Perpaduan citrus dan spice yang segar, ideal untuk aktivitas.',
    ),
    Product(
      id: '4',
      name: 'Aljubail',
      series: 'Arabian Series',
      price: 47000.0,
      imageUrl: 'assets/images/aljubail.jpg',
      description: 'Aroma laut yang segar dengan akhiran cedar, kesan bersih.',
    ),
    Product(
      id: '5',
      name: 'Layla',
      series: 'Luxury Series',
      price: 55000.0,
      imageUrl: 'assets/images/layla.jpg',
      description: 'Wangian bunga mawar dan vanilla yang lembut, feminin.',
    ),
    Product(
      id: '6',
      name: 'Turaif',
      series: 'Luxury Series',
      price: 52000.0,
      imageUrl: 'assets/images/turaif.jpg',
      description: 'Kombinasi oud dan amber yang eksklusif, kemewahan.',
    ),
  ];

  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(_allProducts);
    if (widget.initialSearch.isNotEmpty) {
      _searchController.text = widget.initialSearch;
      _filterProducts(widget.initialSearch);
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _allProducts
          .where(
            (product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.series.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth >= 600 ? 3 : 2;
    final double childAspectRatio = screenWidth >= 600 ? 0.65 : 0.6;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Katalog Parfum',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterProducts,
                decoration: InputDecoration(
                  hintText: 'Cari parfum...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _filterProducts('');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // Product Grid
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada produk yang ditemukan',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
                        final isInWishlist = wishlistProvider.isProductInWishlist(product.id);

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image
                              Expanded(
                                flex: 3,
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          product.imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[100],
                                              child: const Center(
                                                child: Icon(Icons.image_not_supported, color: Colors.grey, size: 24),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => wishlistProvider.toggleWishlist(product),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 12,
                                          child: Icon(
                                            isInWishlist ? Icons.favorite : Icons.favorite_border,
                                            size: 14,
                                            color: isInWishlist ? Colors.red : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Info
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.series,
                                            style: const TextStyle(fontSize: 9, color: Colors.orange, fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            product.name,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            product.description ?? '',
                                            style: const TextStyle(fontSize: 9, color: Colors.grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Rp ${product.price.toStringAsFixed(0)}',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black87),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Provider.of<CartProvider>(context, listen: false).addItem(product, quantity: 1);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${product.name} ditambahkan ke keranjang'),
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                                              child: const Icon(Icons.add, size: 12, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
