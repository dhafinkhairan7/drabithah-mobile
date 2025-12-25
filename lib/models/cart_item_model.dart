// lib/models/cart_item_model.dart
import 'product_model.dart';

class CartItem {
  final String id; // biasanya product.id
  final Product product;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}
