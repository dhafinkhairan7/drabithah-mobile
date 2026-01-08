import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  // ⚠️ PASTIKAN LINK INI SESUAI DENGAN MOCKAPI KAMU ⚠️
  final String baseUrl = "https://695e4cf22556fd22f6780748.mockapi.io/products"; 

  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal load data');
      }
    } catch (e) {
      rethrow;
    }
  }
}