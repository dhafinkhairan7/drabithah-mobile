import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:drabithah_parfume/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  
  // ==========================
  // 1. FUNGSI LOGIN (Yang Hilang Tadi)
  // ==========================
  Future<bool> login(String email, String password) async {
    try {
      // Ambil data user berdasarkan email
      final url = Uri.parse('${ApiConfig.baseUrl}/users?email=$email');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> users = json.decode(response.body);
        
        // Cek apakah ada user dan passwordnya cocok
        if (users.isNotEmpty) {
           var user = users[0];
           if (user['password'] == password) {
             await _saveUserSession(user);
             return true;
           }
        }
      }
      return false; 
    } catch (e) {
      print("ERROR LOGIN: $e");
      return false;
    }
  }

  // ==========================
  // 2. FUNGSI REGISTER (Yang Sudah Benar)
  // ==========================
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/users');
      
      Map<String, dynamic> dataUser = {
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
      };

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(dataUser),
      );

      if (response.statusCode == 201) { 
        var createdUser = json.decode(response.body);
        await _saveUserSession(createdUser);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("ERROR REGISTER: $e");
      return false;
    }
  }

  // ==========================
  // 3. SESSION MANAGEMENT
  // ==========================
  Future<void> _saveUserSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', true);
    // Handle ID yang kadang string kadang int dari MockAPI
    await prefs.setString('userId', user['id'].toString()); 
    await prefs.setString('userName', user['name']);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}