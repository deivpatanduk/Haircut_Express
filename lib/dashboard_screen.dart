import 'package:flutter/material.dart';
// Import component baru
import 'components/barber_card.dart';
// Import Barber model dari file BookingScreen (asumsi Barber class ada di sana)
import 'booking_screen.dart';

// --- DATA MODEL (DIJAGA TETAP SAMA) ---
// Note: Barber Class diasumsikan berada di booking_screen.dart
// Jika Anda ingin Barber Class berada di sini, hapus import booking_screen.dart di atas

// List data tukang cukur (URL sudah diperbaiki ke Picsum Photos)
final List<Barber> barbers = [
  Barber(
    'Rian Pratama',
    'Classic & Modern Cut',
    '4.9',
    '7k reviews',
    true,
    'https://i.pinimg.com/originals/f8/19/e4/f819e4d4f5b6a266a71f8a5248003e39.jpg',
  ),
  Barber(
    'Agus Wijaya',
    'Fade Expert',
    '4.8',
    '10 tahun',
    true,
    'https://picsum.photos/id/102/200/200',
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
    'Agus Wijosa',
    'Pompadour Specialist',
    '4.7',
    '6 tahun',
    true,
    'https://picsum.photos/id/104/200/200',
  ),
];

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final Color mediumBlue = const Color(0xFF233044);
  final Color accentYellow = const Color(0xFFFFA500);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: <Widget>[
        // Bagian Statistik (Upcoming Bookings, Total Visits, Active Promos)
        _buildStatsSection(mediumBlue, accentYellow),
        const SizedBox(height: 20),

        const Text(
          'Promo Spesial',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // Bagian Promo (Horizontal)
        _buildPromoSection(mediumBlue, accentYellow),
        const SizedBox(height: 30),

        const Text(
          'Barber Profesional Kami',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // Daftar Barber (Menggunakan Component BarberCard)
        ...barbers.map(
          (barber) => BarberCard(barber: barber, isBookingScreen: false),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- WIDGET METHOD: STATS SECTION ---
  Widget _buildStatsSection(Color bgColor, Color accentColor) {
    return Column(
      children: [
        _buildStatCard(
          title: 'Upcoming Bookings',
          value: '2',
          subtitle: 'appointment terjadwal',
          icon: Icons.calendar_today_outlined,
          color: bgColor,
          iconColor: accentColor,
        ),
        _buildStatCard(
          title: 'Total Visits',
          value: '0',
          subtitle: 'kunjungan selesai',
          icon: Icons.show_chart,
          color: bgColor,
          iconColor: Colors.green,
        ),
        _buildStatCard(
          title: 'Active Promos',
          value: '2',
          subtitle: 'promo tersedia',
          icon: Icons.star_border,
          color: bgColor,
          iconColor: accentYellow,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    Color iconColor = Colors.white,
  }) {
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            Icon(icon, color: iconColor),
          ],
        ),
      ),
    );
  }

  // --- WIDGET METHOD: PROMO SECTION (URL DIPERBAIKI) ---
  Widget _buildPromoSection(Color cardColor, Color accentColor) {
    return SizedBox(
      height: 300,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _buildPromoCard(
            cardColor: cardColor,
            accentColor: accentYellow,
            // URL Promo 1 DIPERBAIKI
            imagePath: 'https://picsum.photos/id/201/300/200',
            title: 'Diskon 30% Member Baru',
            description: 'Khusus untuk member yang booking pertama kali.',
            validUntil: 'Valid hingga 23 Des',
            discountLabel: '-30%',
          ),
          const SizedBox(width: 15),
          _buildPromoCard(
            cardColor: cardColor,
            accentColor: accentYellow,
            // URL Promo 2 DIPERBAIKI
            imagePath: 'https://picsum.photos/id/202/300/200',
            title: 'Promo Weekend Special',
            description: 'Potongan harga untuk service di akhir pekan.',
            validUntil: 'Valid hingga 20 Des',
            discountLabel: '-20%',
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard({
    required Color cardColor,
    required Color accentColor,
    required String imagePath,
    required String title,
    required String description,
    required String validUntil,
    required String discountLabel,
  }) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Image.network(
                  imagePath,
                  height: 120,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    discountLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  validUntil,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentYellow,
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
