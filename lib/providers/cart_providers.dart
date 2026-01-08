import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;
  final String image;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
    required this.image,
  });
}

class CartProvider with ChangeNotifier {
  // Map menggunakan ID Produk sebagai Key agar tidak tertukar
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productId, String title, double price, String image) {
    if (_items.containsKey(productId)) {
      // Jika produk sudah ada, tambah jumlahnya saja
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          price: existingItem.price,
          image: existingItem.image,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      // Jika produk belum ada, tambah item baru
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId, // Pastikan ID unik masuk ke sini
          title: title,
          price: price,
          image: image,
          quantity: 1,
        ),
      );
    }
    notifyListeners(); // Memberitahu UI untuk update
  }

  // Logic Hapus Total (Satu baris produk hilang)
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Logic Kurangi Jumlah (Tombol Minus)
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          image: existing.image,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}