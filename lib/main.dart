import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORTS SCREEN ASLI ---
// Pastikan nama file ini sesuai dengan yang ada di folder lib lu
import 'home_screen.dart'; 
import 'wishlist_screen.dart'; 
import 'profile_screen.dart'; // Ini akan memanggil desain Profile yang udah lu buat
import 'providers/wishlist_provider.dart';
import 'cart_screen.dart';
import 'providers/cart_provider.dart';
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => WishlistProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
  

// =================================================================
// 1. WIDGET UTAMA (MyApp)
// =================================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Warna Brand Drabithah
  static const Color primaryGold = Color(0xFFF9A825);
  static const Color accentCream = Color(0xFFFFCC80);
  static const Color backgroundLight = Color(0xFFFAFAFA);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drabithah Parfume',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: primaryGold,
          secondary: accentCream,
          surface: Colors.white,
          background: backgroundLight,
          onPrimary: Colors.white,
          onSecondary: Colors.black87,
        ),
        scaffoldBackgroundColor: backgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black, // Biar teks appbar item
        ),
        // Style global untuk bottom nav bar biar konsisten
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryGold,
          unselectedItemColor: Colors.grey,
        ),
        useMaterial3: true,
      ),
      // Langsung arahkan ke MainScreen (yang ada navigasinya)
      home: const MainScreen(),
    );
  }
}

// =================================================================
// 2. WIDGET NAVIGASI (MainScreen)
// =================================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default buka Home

  // List halaman. Urutannya harus sama dengan items di BottomNavigationBar
  final List<Widget> _screens = [
    const HomeScreen(),      // Index 0
    const CartScreen(),      // Index 1
    const WishlistScreen(),  // Index 2
    const ProfileScreen(),   // Index 3 (Ini bakal ngambil dari file profile_screen.dart)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan berganti sesuai index yang dipilih
      body: _screens[_selectedIndex],
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed, // Penting biar label gak geser2 kalau item > 3
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag_rounded),
              label: 'Keranjang',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}