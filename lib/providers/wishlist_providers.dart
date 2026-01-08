import 'package:flutter/material.dart';

class WishlistProvider with ChangeNotifier {
  // Simpan data produk secara utuh dalam list
  List<Map<String, dynamic>> _wishlistItems = [];

  List<Map<String, dynamic>> get wishlistItems => [..._wishlistItems];

  // Cek apakah produk sudah di-love berdasarkan ID uniknya
  bool isWishlisted(String productId) {
    return _wishlistItems.any((item) => item['id'].toString() == productId);
  }

  void toggleWishlist(Map<String, dynamic> product) {
    final productId = product['id'].toString();
    final existingIndex = _wishlistItems.indexWhere((item) => item['id'].toString() == productId);

    if (existingIndex >= 0) {
      // Jika sudah ada, hapus
      _wishlistItems.removeAt(existingIndex);
    } else {
      // Jika belum ada, tambahkan data lengkapnya
      _wishlistItems.add({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'category': product['category'],
        'description': product['description'],
      });
    }
    notifyListeners();
  }
}