// File: lib/providers/wishlist_provider.dart (FINAL - Diperbarui)

import 'package:flutter/material.dart';
import '../models/product_model.dart';

class WishlistProvider with ChangeNotifier {
  final List<Product> _items = [];

  // Getter publik untuk item di wishlist
  List<Product> get wishlistItems => _items;
  
  // Fungsi Pengecekan 1: Menggunakan objek Product
  bool isFavorite(Product product) {
    // Cek apakah produk dengan ID yang sama sudah ada di list
    return _items.any((item) => item.id == product.id);
  }

  // Fungsi Pengecekan 2: Menggunakan ID (untuk digunakan di HomeScreen)
  bool isProductInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }

  // Menambahkan atau menghapus item
  void toggleWishlist(Product product) {
    if (isFavorite(product)) {
      // Hapus produk yang memiliki ID sama
      _items.removeWhere((item) => item.id == product.id);
      debugPrint("Item dihapus dari wishlist: ${product.name}");
    } else {
      // Tambahkan item baru
      _items.add(product);
      debugPrint("Item ditambahkan ke wishlist: ${product.name}");
    }
    // Memberi tahu semua Consumer/Watchers bahwa data telah berubah
    notifyListeners();
  }

  // Menghapus item dari wishlist (digunakan di WishlistScreen)
  void removeItem(Product product) {
    _items.removeWhere((item) => item.id == product.id);
    notifyListeners();
  }
}