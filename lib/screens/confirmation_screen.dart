import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/auth_provider.dart';
import '../models/barber.dart'; // Tambahkan import Barber jika perlu, meski di booking baru kita ambil dari Provider

// Ubah menjadi Widget sederhana
class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Alur baru tidak memakai screen ini, tapi kita biarkan agar tidak error
    return const Scaffold(
      body: Center(child: Text("Processing...")),
    );
  }
}aimport 'package:flutter/material.dart';

// Layar ini sekarang hanya placeholder agar compiler tidak error
// karena alur konfirmasi sudah ada di dalam BookingScreen (Step 3)
class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Halaman ini tidak lagi digunakan.")),
    );
  }
}