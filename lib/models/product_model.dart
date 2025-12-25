// File: lib/models/product_model.dart 

class Product {
  final String id;
  final String name;
  final String series;
  final double price;
  final String imageUrl;
  final String? description;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.series,
    required this.price,
    required this.imageUrl,
    this.description,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Generate ID from name if not provided
    String productId = json['id']?.toString() ?? 
        (json['name']?.toString().toLowerCase().replaceAll(' ', '_') ?? 'unknown');
    
    // Ensure price is converted to double properly
    double productPrice = 0.0;
    if (json['price'] != null) {
      if (json['price'] is int) {
        productPrice = (json['price'] as int).toDouble();
      } else if (json['price'] is double) {
        productPrice = json['price'] as double;
      } else {
        productPrice = double.tryParse(json['price'].toString()) ?? 0.0;
      }
    }

    return Product(
      id: productId,
      name: json['name'] ?? 'No Name',
      series: json['series'] ?? 'Uncategorized',
      price: productPrice,
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/800x800',
      description: json['description'] as String?,
      isFavorite: false,
    );
  }
}
