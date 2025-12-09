import 'package:flutter/material.dart';
import 'booking_screen.dart';
// Import components baru
import 'components/booking_stepper.dart';
import 'components/calendar_widget.dart';

class ScheduleScreen extends StatelessWidget {
  final Barber selectedBarber;

  const ScheduleScreen({super.key, required this.selectedBarber});

  final Color darkBlue = const Color(0xFF1B263B);
  final Color mediumBlue = const Color(0xFF233044);
  final Color accentYellow = const Color(0xFFFFA500);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        title: Text(
          'Booking: ${selectedBarber.name}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // STEPPER/PROSES LANGKAH (Langkah 2 Aktif)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 16.0,
              ),
              child: BookingStepper(currentStep: 2), // Menggunakan Component
            ),

            // JUDUL UTAMA
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Pilih Tanggal & Waktu',
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
                'Tentukan jadwal appointment Anda',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),

            // KALENDER DAN SLOT WAKTU
            const CalendarWidget(), // Menggunakan Component

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: _buildContinueButton(context),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    // ... (Fungsi ini tetap sama)
    return Container(
      color: darkBlue,
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Navigasi ke halaman Konfirmasi (Langkah 3)
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: accentYellow,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Lanjutkan ke Konfirmasi',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
