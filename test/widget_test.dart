// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tubes_dppb/main.dart'; // Mengimpor main.dart

void main() {
  testWidgets('Aplikasi Parfum smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // MENGGUNAKAN MyApp() sebagai default yang paling umum. 
    // Jika masih error, ganti 'MyApp' dengan nama kelas aplikasi utama di main.dart Anda.
    await tester.pumpWidget(const MyApp()); 

    // Verifikasi apakah ada widget utama di layar
    expect(find.byType(MaterialApp), findsOneWidget); 
    
    // Verifikasi: Apakah ada ikon Home di BottomNavBar? (Asumsi)
    expect(find.byIcon(Icons.home), findsOneWidget); 
  });
}