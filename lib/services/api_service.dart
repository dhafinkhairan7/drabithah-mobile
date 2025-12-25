import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://694a169e1282f890d2d79363.mockapi.io/api/drabithah';
  
  // Fungsi untuk mengambil data produk dari API
  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Gagal mengambil data produk: $e');
    }
  }

  // Fungsi untuk mencari produk berdasarkan query
  static Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?search=$query'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching products: $e');
      // Filter dari semua produk sebagai fallback
      final allProducts = await fetchProducts();
      return allProducts.where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase()) ||
        product.series.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }

  // Fungsi untuk mengambil detail produk berdasarkan ID
  static Future<Product?> fetchProductDetail(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to load product detail: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product detail: $e');
      // Cari produk di semua produk sebagai fallback
      try {
        final allProducts = await fetchProducts();
        return allProducts.firstWhere((product) => product.id == productId);
      } catch (e) {
        return null;
      }
    }
  }
}
