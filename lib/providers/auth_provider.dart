import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _user?.role == 'admin';
  bool get isVerified => _user?.status == 'Sudah Verifikasi';

  // Constructor untuk menginisialisasi status login
  AuthProvider() {
    _loadUserFromPreferences();
  }

  // Load user data dari SharedPreferences
  Future<void> _loadUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final token = prefs.getString('token');

      if (userJson != null && token != null) {
        final userData = Map<String, dynamic>.from(
          // ignore: use_build_context_synchronously
          await compute(_parseJson, userJson)
        );
        _user = User.fromJson(userData);
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user from preferences: $e');
    }
  }

  // Helper function untuk parsing JSON di isolate
  static Map<String, dynamic> _parseJson(String json) {
    return Map<String, dynamic>.from(
      // ignore: avoid_dynamic_calls
      (jsonDecode(json) as Map)
    );
  }

  // Fungsi registrasi
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validasi input
      final usernameError = AuthService.validateUsername(username);
      if (usernameError != null) {
        _setError(usernameError);
        return false;
      }

      if (!AuthService.isValidEmail(email)) {
        _setError('Email tidak valid');
        return false;
      }

      final passwordError = AuthService.validatePassword(password);
      if (passwordError != null) {
        _setError(passwordError);
        return false;
      }

      // Buat user baru
      final newUser = User(
        username: username,
        email: email,
        password: password,
      );

      // Kirim ke API
      final result = await AuthService.register(newUser);

      if (result['success'] == true) {
        _setSuccess(result['message'] ?? 'Registrasi berhasil');
        return true;
      } else {
        _setError(result['message'] ?? 'Registrasi gagal');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fungsi login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validasi input
      if (!AuthService.isValidEmail(email)) {
        _setError('Email tidak valid');
        return false;
      }

      if (password.isEmpty) {
        _setError('Password tidak boleh kosong');
        return false;
      }

      // Kirim ke API
      final result = await AuthService.login(email, password);

      if (result['success'] == true && result['user'] != null) {
        _user = result['user'] as User;
        _isAuthenticated = true;

        // Simpan ke SharedPreferences
        await _saveUserToPreferences();

        _setSuccess(result['message'] ?? 'Login berhasil');
        return true;
      } else {
        _setError(result['message'] ?? 'Login gagal');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fungsi logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Kirim request logout ke server jika ada token
      if (token != null) {
        await AuthService.logout(token);
      }

      // Hapus data lokal
      await _clearUserFromPreferences();
      
      _user = null;
      _isAuthenticated = false;
      _clearError();
      
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
      // Tetap logout lokal meskipun server error
      await _clearUserFromPreferences();
      _user = null;
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  // Update profil user
  Future<bool> updateProfile({String? username, String? avatar}) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Update user lokal
      if (username != null) {
        final usernameError = AuthService.validateUsername(username);
        if (usernameError != null) {
          _setError(usernameError);
          return false;
        }
      }

      _user = _user!.copyWith(
        username: username,
        avatar: avatar,
        updatedAt: DateTime.now(),
      );

      await _saveUserToPreferences();
      notifyListeners();

      _setSuccess('Profil berhasil diperbarui');
      return true;
    } catch (e) {
      _setError('Gagal memperbarui profil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Simpan user ke SharedPreferences
  Future<void> _saveUserToPreferences() async {
    if (_user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(_user!.toJson()));
      // Anda bisa menyimpan token jika backend mengembalikan token
      // await prefs.setString('token', token);
    } catch (e) {
      print('Error saving user preferences: $e');
    }
  }

  // Hapus user dari SharedPreferences
  Future<void> _clearUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('token');
    } catch (e) {
      print('Error clearing user preferences: $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh user data dari server
  Future<void> refreshUser() async {
    if (!_isAuthenticated || _user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final result = await AuthService.getProfile(token);
        if (result['success'] == true && result['user'] != null) {
          _user = result['user'] as User;
          await _saveUserToPreferences();
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  // Check if user has specific role
  bool hasRole(String role) {
    return _user?.role == role;
  }

  // Check if user is verified
  bool get isUserVerified {
    return _user?.status == 'Sudah Verifikasi';
  }
}
