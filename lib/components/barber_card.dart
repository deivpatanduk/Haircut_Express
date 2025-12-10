import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/barber.dart';
import '../providers/booking_provider.dart';
import '../screens/booking_screen.dart';

class BarberCard extends StatelessWidget {
  final Barber barber;
  final bool isBookingScreen;

  const BarberCard({
    super.key,
    required this.barber,
    this.isBookingScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(barber.photoUrl),
              onBackgroundImageError: (_, __) => const Icon(Icons.person),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(barber.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(barber.specialty, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(" ${barber.rating}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            if (!isBookingScreen)
              ElevatedButton(
                onPressed: () {
                  final booking = Provider.of<BookingProvider>(context, listen: false);
                  booking.clearBooking();
                  booking.selectBarber(barber); 
                  booking.nextStep(); 

                  // PENTING: Jangan pakai 'const' di sini karena BookingScreen stateful
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookingScreen()), 
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B263B), foregroundColor: Colors.white),
                child: const Text('Book'),
              ),
          ],
        ),
      ),
    );
  }
}