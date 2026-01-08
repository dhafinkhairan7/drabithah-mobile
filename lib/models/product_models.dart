class ProductModel {
  final String id;
  final String name;
  final int price;
  final String description;
  final String image;
  final String category;
  final bool isPopular;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.category,
    required this.isPopular,
  });

  // Pabrik untuk mengubah JSON jadi Object Dart
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      // Hati-hati, kadang API ngasih string angka, kita paksa jadi int
      price: int.tryParse(json['price'].toString()) ?? 0, 
      description: json['description'],
      image: json['image'],
      category: json['category'],
      isPopular: json['is_popular'] ?? false,
    );
  }
}