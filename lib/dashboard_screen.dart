// PASTIKAN KODE LENGKAP INI ADA DI FILE lib/dashboard_screen.dart
import 'package:flutter/material.dart';

// --- DATA MODEL (Dibiarkan sama) ---
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

// List data tukang cukur (Barber) fiktif (Dibiarkan sama)
final List<Barber> barbers = [
  Barber(
    'Agus Wijaya',
    'Classic & Modern Cut',
    '4.9',
    '10 tahun',
    true,
    'https://i.pravatar.cc/150?img=1',
  ),
  Barber(
    'Rian Pratama',
    'Fade Expert',
    '4.8',
    '7 tahun',
    true,
    'https://i.pravatar.cc/150?img=2',
  ),
  Barber(
    'Budi Santoso',
    'Traditional Barber',
    '4.9',
    '15 tahun',
    false,
    'https://i.pravatar.cc/150?img=3',
  ),
  Barber(
    'Dedi Kurniawan',
    'Pompadour Specialist',
    '4.7',
    '6 tahun',
    true,
    'https://i.pravatar.cc/150?img=4',
  ),
];

// --- WIDGET UTAMA DASHBOARD ---
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final Color mediumBlue = const Color(0xFF233044);
  final Color accentYellow = const Color(0xFFFFA500);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: <Widget>[
        // Bagian Statistik
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

        _buildPromoSection(mediumBlue, accentYellow),
        const SizedBox(height: 30),

        const Text(
          'Barber Professional Kami',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // Perluas daftar barber di sini
        ...barbers
            .map((barber) => _buildBarberCard(barber, mediumBlue))
            .toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- WIDGET METHOD: STATS SECTION (Dibiarkan sama) ---
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

  // --- WIDGET METHOD: PROMO SECTION ---
  Widget _buildPromoSection(Color cardColor, Color accentColor) {
    return SizedBox(
      height: 300,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _buildPromoCard(
            cardColor: cardColor,
            accentColor: accentYellow,
            imagePath:
                'https://images.unsplash.com/photo-1549419163-f29e1c450c33',
            title: 'Diskon 30% Member Baru',
            description: 'Khusus untuk member yang booking pertama kali.',
            validUntil: 'Valid hingga 23 Des',
            discountLabel: '-30%',
          ),
          const SizedBox(width: 15),
          _buildPromoCard(
            cardColor: cardColor,
            accentColor: accentYellow,
            imagePath:
                'https://images.unsplash.com/photo-1621607567086-a7dc5e2b8600',
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
                    // **********************************
                    // * PERUBAHAN: Ganti 'Detail' menjadi 'Book Now'
                    // **********************************
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

  // --- WIDGET METHOD: BARBER CARD ---
  Widget _buildBarberCard(Barber barber, Color cardColor) {
    // Tombol di desain terakhir Anda adalah 'Book Now' (warna hijau), bukan status.
    final Color statusColor = barber.isAvailable ? Colors.green : Colors.red;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
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
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.star, color: accentYellow, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        '${barber.rating} (${barber.yearsExperience})',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tombol Status Ketersediaan
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green, // Selalu hijau seperti di desain terakhir
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(100, 35),
              ),
              // **********************************
              // * PERUBAHAN: Ganti Teks Status menjadi 'Book Now'
              // **********************************
              child: const Text(
                'gunakan',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
