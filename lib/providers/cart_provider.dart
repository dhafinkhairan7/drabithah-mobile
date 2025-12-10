// lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  // key = product.id
  final Map<String, CartItem> _items = {};

  // Semua item dalam bentuk list
  List<CartItem> get items => _items.values.toList();

  // Jumlah jenis item
  int get itemCount => _items.length;

  // Jumlah total unit (misal 3 produk A + 2 produk B => 5)
  int get totalUnits {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  // Subtotal (total harga)
  double get subtotal {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  // Add item: jika sudah ada -> tambah quantity, jika belum ada -> masukkan baru
  void addItem(Product product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItem(
        id: product.id,
        product: product,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  // Decrease quantity by 1. Jika quantity <= 1 -> remove
  void decreaseItem(String productId) {
    if (!_items.containsKey(productId)) return;
    final existing = _items[productId]!;
    if (existing.quantity > 1) {
      existing.quantity -= 1;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Remove item sepenuhnya
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Clear keranjang
  void clear() {
    _items.clear();
    notifyListeners();
  }

  void decreaseQuantity(String id) {
    decreaseItem(id);
  }

  // Increase quantity by 1
  void increaseItem(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity += 1;
      notifyListeners();
    }
  }

  void increaseQuantity(String id) {
    increaseItem(id);
  }
}