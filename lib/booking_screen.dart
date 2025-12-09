import 'package:flutter/material.dart';
// Import components baru
import 'components/booking_stepper.dart';
import 'components/barber_card.dart';
// >>> Hapus import 'schedule_screen.dart' yang tidak terpakai <<<

// --- DATA MODEL (Ditempatkan di sini atau di file model terpisah) ---
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

// List data tukang cukur (URL Gambar sudah diperbaiki ke Picsum Photos)
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

// --- WIDGET UTAMA BOOKING SCREEN ---
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
            // STEPPER/PROSES LANGKAH (Menggunakan Component BookingStepper)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 16.0,
              ),
              // Langkah 1 aktif
              child: BookingStepper(currentStep: 1),
            ),

            // JUDUL UTAMA
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

            // SUBTITLE
            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
              child: Text(
                'Pilih barber profesional favorit Anda',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),

            // DAFTAR BARBER (Menggunakan Component BarberCard)
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: barbers.length,
              itemBuilder: (context, index) {
                // Gunakan BarberCard, set isBookingScreen=true untuk tampilan Centered dan Navigasi
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
