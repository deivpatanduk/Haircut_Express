import 'package:flutter/material.dart';
import 'package:haircut_express/models/barber.dart'; // Import Model
import 'package:haircut_express/components/barber_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Dummy Barber menggunakan Model Barber
    final List<Barber> barbers = [
      Barber(
        name: 'Budi Santoso',
        specialty: 'Classic Cut',
        rating: 4.8,
        photoUrl: 'https://i.pravatar.cc/150?u=budi',
      ),
      Barber(
        name: 'Andi Pratama',
        specialty: 'Fade & Modern',
        rating: 4.9,
        photoUrl: 'https://i.pravatar.cc/150?u=andi',
      ),
    ];

    return Scaffold(
      // ... (Kode UI Body Dashboard Anda, pastikan ListView.builder menggunakan data barbers di atas)
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Top Stylist", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...barbers.map((b) => BarberCard(barber: b)).toList(),
        ],
      ),
    );
  }
}