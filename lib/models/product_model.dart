// File: lib/models/product_model.dart (FINAL - Disinkronkan)

class Product {
  final String id;
  final String name;
  final String series; // Menggunakan 'series' sesuai draft Anda
  final double price;
  final String imageUrl; // Menggunakan 'imageUrl' sesuai draft Anda
  bool isFavorite; // Status favorit yang bisa diubah (mutable)

  Product({
    required this.id,
    required this.name,
    required this.series,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  // Konstruktor untuk membuat Product dari data JSON (dari API)
  factory Product.fromJson(Map<String, dynamic> json) {
    // Penanganan konversi tipe data dari API
    String productId = json['id']?.toString() ?? 'unknown';
    double productPrice = double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;

    return Product(
      id: productId,
      name: json['name'] ?? 'No Name',
      series: json['series'] ?? json['brand'] ?? 'Uncategorized',
      price: productPrice,
      imageUrl: json['imageUrl'] ?? 'assets/images/default.jpg',
      isFavorite: false, // Status awal, akan disinkronkan di HomeScreen
    );
  }
}

// Data Dummy Lokal yang Sudah Disinkronkan
final List<Product> localFeaturedProducts = [
  Product(
    id: '101',
    name: 'Casablanca',
    series: 'Arabian Series',
    price: 45000.0,
    imageUrl: 'assets/images/casablanca.jpg', // Pastikan path ini ada!
    isFavorite: false,
  ),
  Product(
    id: '102',
    name: 'Ghissah',
    series: 'Arabian Series',
    price: 45000.0,
    imageUrl: 'assets/images/ghissah.jpg',
    isFavorite: false,
  ),
  Product(
    id: '103',
    name: 'Riyadh',
    series: 'Arabian Series',
    price: 45000.0,
    imageUrl: 'assets/images/riyadh.jpg',
    isFavorite: false,
  ),
];