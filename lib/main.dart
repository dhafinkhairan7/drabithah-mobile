import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drabithah_parfume/providers/cart_providers.dart'; 
import 'package:drabithah_parfume/providers/wishlist_providers.dart'; 
import 'package:drabithah_parfume/screen/auth/login_screen.dart'; 
import 'package:drabithah_parfume/screen/home/home_screen.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Mendaftarkan CartProvider untuk fungsionalitas keranjang belanja
        ChangeNotifierProvider(create: (context) => CartProvider()),
        // Mendaftarkan WishlistProvider untuk fungsionalitas daftar keinginan
        ChangeNotifierProvider(create: (context) => WishlistProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drabithah Parfume',
      
      // --- TEMA MEWAH (GOLD & WHITE) ---
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: const Color(0xFFFFC107), // Warna Emas Utama
        scaffoldBackgroundColor: Colors.white, // Background Putih Bersih
        fontFamily: 'Roboto', 
        
        // App Bar Style
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),

        // Button Style (Rounded & Gold)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC107),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        
        // Input Style
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5), // Abu sangat muda
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        
        useMaterial3: false,
      ),
      
      // --- LOGIC ANTI-LOGOUT ---
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          // Menampilkan loading saat mengecek status login di memori
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)))
            );
          }
          // Jika status isLogin true, langsung ke Home, jika tidak ke Login
          if (snapshot.data == true) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }

  // Fungsi untuk mengecek sesi login yang tersimpan di SharedPreferences
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLogin') ?? false;
  }
}