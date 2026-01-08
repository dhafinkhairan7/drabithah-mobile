import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- DAFTAR WARNA (PALETTE) ---
// Warna Emas (Utama)
const Color primaryColor = Color(0xFFFFC107); 
// Warna Kuning Pudar (Buat background kotak/variasi)
const Color secondaryColor = Color(0xFFFFF8E1); 
// Warna Hitam (Buat Teks Judul)
const Color blackColor = Color(0xFF222222);
// Warna Abu-abu (Buat Teks Deskripsi)
const Color greyColor = Color(0xFF9E9E9E);

// --- SETTINGAN TEMA APLIKASI ---
ThemeData appTheme() {
  return ThemeData(
    // Warna Utama Aplikasi
    primaryColor: primaryColor,
    
    // Background Aplikasi (Putih Bersih)
    scaffoldBackgroundColor: Colors.white,
    
    // Skema Warna Material Design 3
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryColor,
      secondary: primaryColor,
    ),
    
    // Font Global (Pakai Poppins biar modern)
    textTheme: GoogleFonts.poppinsTextTheme(),
    
    // Gaya AppBar (Judul di Atas)
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0, // Gak ada bayangan
      iconTheme: IconThemeData(color: blackColor), // Ikon warna hitam
      titleTextStyle: TextStyle(
        color: blackColor, 
        fontSize: 18, 
        fontWeight: FontWeight.bold
      ),
    ),
    
    // Gaya Tombol (Elevated Button)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white, // Warna teks tombol putih
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Sudut membulat
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold
        ),
      ),
    ),
  );
}