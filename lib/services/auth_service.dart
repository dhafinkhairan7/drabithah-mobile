import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../models/user_model.dart';

class AuthService {
  // URL untuk Laragon dengan struktur folder yang benar
  static const String baseUrl = 'http://drabithah_accounts.test/api';
  
  
  static Future<Map<String, dynamic>> register(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(user.toRegistrationJson()),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Registrasi berhasil',
          'user': responseData['user'] != null ? User.fromJson(responseData['user']) : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      print('Error during registration: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fungsi untuk login user
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Hash password sebelum dikirim (opsional, tergantung backend)
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password, // atau hashedPassword jika backend mengharapkan hash
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Login berhasil',
            'user': responseData['user'] != null ? User.fromJson(responseData['user']) : null,
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Login gagal',
          };
        }
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      print('Error during login: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fungsi untuk logout (jika diperlukan)
  static Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);
      
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Logout berhasil',
      };
    } catch (e) {
      print('Error during logout: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fungsi untuk mendapatkan profil user (jika diperlukan)
  static Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': responseData['user'] != null ? User.fromJson(responseData['user']) : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal mengambil profil',
        };
      }
    } catch (e) {
      print('Error getting profile: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Fungsi helper untuk validasi email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Fungsi helper untuk validasi password
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // Fungsi helper untuk validasi username
  static String? validateUsername(String username) {
    if (username.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    if (username.length < 3) {
      return 'Username minimal 3 karakter';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username hanya boleh mengandung huruf, angka, dan underscore';
    }
    return null;
  }
}
