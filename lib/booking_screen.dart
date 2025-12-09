import 'package:flutter/material.dart';
import 'components/booking_stepper.dart';
import 'components/barber_card.dart';

class Barber {
  final String name;
  final String specialization;
  final String rating;
  final String yearsExperience;
  final bool isAvailable;
  final String imagePath;

  Barber(
    this.name,
    this.specialization,
    this.rating,
    this.yearsExperience,
    this.isAvailable,
    this.imagePath,
  );
}

final List<Barber> barbers = [
  Barber(
    'Agus Wijaya',
    'Classic & Modern Cut',
    '4.9',
    '10 tahun',
    true,
    'https://picsum.photos/id/102/200/200',
  ),
  Barber(
    'Rian Pratama',
    'Fade Expert',
    '4.8',
    '7 tahun',
    true,
    'https://picsum.photos/id/101/200/200',
  ),
  Barber(
    'Budi Santoso',
    'Traditional Barber',
    '4.9',
    '15 tahun',
    false,
    'https://picsum.photos/id/103/200/200',
  ),
  Barber(
    'Dedi Kurniawan',
    'Pompadour Specialist',
    '4.7',
    '6 tahun',
    true,
    'https://picsum.photos/id/104/200/200',
  ),
];

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  final Color darkBlue = const Color(0xFF1B263B);
  final Color mediumBlue = const Color(0xFF233044);
  final Color accentYellow = const Color(0xFFFFA500);
  final Color accentGreen = const Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 16.0,
              ),
              child: BookingStepper(currentStep: 1),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Pilih Barber',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
              child: Text(
                'Pilih barber profesional favorit Anda',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),

            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: barbers.length,
              itemBuilder: (context, index) {
                return BarberCard(
                  barber: barbers[index],
                  isBookingScreen: true,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
