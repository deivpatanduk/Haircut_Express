import 'package:flutter/material.dart';
import 'package:haircut_express/models/barber.dart'; // Import Model yang baru dibuat
import 'package:haircut_express/screens/booking_screen.dart'; // Untuk navigasi

class BarberCard extends StatelessWidget {
  final Barber barber;
  final bool isBookingScreen; // Flag untuk membedakan tampilan

  const BarberCard({
    super.key,
    required this.barber,
    this.isBookingScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Foto Barber
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(barber.photoUrl),
              onBackgroundImageError: (_, __) => const Icon(Icons.person),
            ),
            const SizedBox(width: 16),
            // Info Barber
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barber.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    barber.specialty,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        barber.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tombol Aksi (Hanya muncul jika BUKAN di booking screen)
            if (!isBookingScreen)
              ElevatedButton(
                onPressed: () {
                  // Navigasi ke Booking Screen dengan membawa data barber
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(selectedBarber: barber),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B263B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Book'),
              ),
          ],
        ),
      ),
    );
  }
}