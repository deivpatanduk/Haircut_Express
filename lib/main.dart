import 'package:flutter/material.dart';
// Import MainAppScreen yang akan kita buat di langkah berikutnya
import 'main_app_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Warna dasar gelap yang konsisten
  final Color darkBlue = const Color(0xFF1B263B);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HAIRCUT EXPRESS',
      theme: ThemeData(
        // Menggunakan Dark Theme agar sesuai dengan desain Anda
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: darkBlue, // Background global
      ),
      // Memulai aplikasi dengan kerangka navigasi utama
      home: const MainAppScreen(),
    );
  }
}
