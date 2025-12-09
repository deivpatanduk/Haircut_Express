import 'package:flutter/material.dart';
import '../booking_screen.dart'; // Untuk mendapatkan model Barber
import '../schedule_screen.dart'; // Untuk navigasi ke ScheduleScreen

class BarberCard extends StatelessWidget {
  final Barber barber;
  final bool
  isBookingScreen; // Flag untuk membedakan tampilan (Dashboard/Booking)

  const BarberCard({
    super.key,
    required this.barber,
    this.isBookingScreen = false,
  });

  final Color mediumBlue = const Color(0xFF233044);
  final Color accentYellow = const Color(0xFFFFA500);
  final Color accentGreen = const Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    final String buttonText = isBookingScreen
        ? (barber.isAvailable ? 'Tersedia' : 'Tidak Tersedia')
        : 'Book Now';
    final Color buttonColor = isBookingScreen
        ? (barber.isAvailable ? accentGreen : Colors.red.shade700)
        : Colors.green.shade600;

    return Card(
      color: mediumBlue,
      margin: isBookingScreen
          ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
          : const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isBookingScreen
            ? _buildBookingContent(context, buttonText, buttonColor)
            : _buildDashboardContent(context, buttonText, buttonColor),
      ),
    );
  }

  // --- Tampilan Khusus Halaman DASHBOARD (Side-by-side) ---
  Widget _buildDashboardContent(
    BuildContext context,
    String buttonText,
    Color buttonColor,
  ) {
    bool isDetailedCard = barber.name == 'Rian Pratama';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 35,
          backgroundImage: NetworkImage(barber.imagePath),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                barber.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                barber.specialization,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 5),
              _buildRatingRow(barber.rating, barber.yearsExperience),
              if (isDetailedCard) ...[
                const SizedBox(height: 4),
                _buildRatingRow('4.9', '(7k review)'),
              ],
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {}, // Dashboard: Tidak ada navigasi
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            minimumSize: const Size(100, 35),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // --- Tampilan Khusus Halaman BOOKING (Centered) ---
  Widget _buildBookingContent(
    BuildContext context,
    String buttonText,
    Color buttonColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(barber.imagePath),
          backgroundColor: mediumBlue,
        ),
        const SizedBox(height: 10),
        Text(
          barber.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          barber.specialization,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),
        _buildRatingRow(
          barber.rating,
          '(${barber.yearsExperience})',
          centered: true,
        ),
        const SizedBox(height: 10),

        SizedBox(
          width: 150,
          child: ElevatedButton(
            // Navigasi HANYA dari Booking Screen
            onPressed: barber.isAvailable
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ScheduleScreen(selectedBarber: barber),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  // Widget Pembantu Rating
  Row _buildRatingRow(
    String rating,
    String experience, {
    bool centered = false,
  }) {
    return Row(
      mainAxisAlignment: centered
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Icon(Icons.star, color: accentYellow, size: 16),
        const SizedBox(width: 5),
        Text(
          '$rating $experience',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
