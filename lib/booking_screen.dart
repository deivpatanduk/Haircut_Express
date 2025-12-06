import 'package:flutter/material.dart';
// >>> TAMBAHKAN IMPORT SCHEDULE SCREEN DI SINI <<<
import 'schedule_screen.dart';

// --- DATA MODEL (Data yang sama dari dashboard_screen.dart) ---
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

// List data tukang cukur (Barber) fiktif (Data dari Dashboard)
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
            // STEPPER/PROSES LANGKAH
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 16.0,
              ),
              child: _buildStepper(context),
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

            // DAFTAR BARBER
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: barbers.length,
              itemBuilder: (context, index) {
                return _buildBarberCard(
                  barbers[index],
                  mediumBlue,
                  context,
                ); // Kirim context
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET METHOD: STEPPER/PROSES LANGKAH (KODE FIX GARIS) ---
  Widget _buildStepper(BuildContext context) {
    // Lingkaran angka memiliki lebar 30. Radius = 15.
    const double circleRadius = 15.0;

    return SizedBox(
      height: 60, // Ketinggian tetap untuk Stepper
      child: Stack(
        children: [
          // 1. GARIS PEMISAH LATAR BELAKANG
          Positioned(
            top: 15, // Sejajarkan dengan titik tengah lingkaran (tinggi 30/2)
            left: 0,
            right: 0,
            child: Row(
              children: [
                // Margin kiri yang memastikan garis dimulai setelah setengah lingkaran pertama
                SizedBox(width: circleRadius),

                // Garis 1 (Aktif/kuning, di antara langkah 1 dan 2)
                Expanded(
                  child: Container(
                    height: 2,
                    color: accentYellow,
                    // Memberi ruang agar garis tidak menabrak lingkaran berikutnya
                    margin: const EdgeInsets.symmetric(
                      horizontal: circleRadius,
                    ),
                  ),
                ),

                // Garis 2 (Tidak aktif/abu-abu, di antara langkah 2 dan 3)
                Expanded(
                  child: Container(
                    height: 2,
                    color: Colors.grey.shade700,
                    // Memberi ruang di kedua sisi garis
                    margin: const EdgeInsets.symmetric(
                      horizontal: circleRadius,
                    ),
                  ),
                ),

                // Margin kanan untuk menyeimbangkan layout
                const SizedBox(width: circleRadius),
              ],
            ),
          ),

          // 2. WIDGET LANGKAH (Angka dan Teks)
          // Ini harus diletakkan DI ATAS garis
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep(1, 'Pilih Barber', true), // Langkah 1: Aktif
              _buildStep(2, 'Jadwal', false), // Langkah 2: Belum Aktif
              _buildStep(3, 'Konfirmasi', false), // Langkah 3: Belum Aktif
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET METHOD: STEP (Dibiarkan sama) ---
  Widget _buildStep(int stepNumber, String title, bool isActive) {
    return Column(
      children: [
        // Lingkaran Angka Langkah
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? accentYellow : mediumBlue,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? accentYellow : Colors.grey.shade700,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: TextStyle(
                color: isActive ? darkBlue : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        // Judul Langkah
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? accentYellow : Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // --- WIDGET METHOD: BARBER CARD (DENGAN FUNGSI NAVIGASI) ---
  Widget _buildBarberCard(
    Barber barber,
    Color cardColor,
    BuildContext context,
  ) {
    final Color statusColor = barber.isAvailable ? accentGreen : Colors.red;
    final String statusText = barber.isAvailable
        ? 'Tersedia'
        : 'Tidak Tersedia';

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gambar Barber
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(barber.imagePath),
              backgroundColor: mediumBlue,
            ),
            const SizedBox(height: 10),

            // Nama dan Spesialisasi
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

            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: accentYellow, size: 18),
                const SizedBox(width: 5),
                Text(
                  '${barber.rating} (${barber.yearsExperience})',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tombol Status (DENGAN NAVIGASI)
            SizedBox(
              width: 150,
              child: ElevatedButton(
                // >>> IMPLEMENTASI NAVIGASI DI SINI <<<
                onPressed: barber.isAvailable
                    ? () {
                        // Navigasi ke ScheduleScreen dan KIRIM objek barber yang dipilih
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ScheduleScreen(selectedBarber: barber),
                          ),
                        );
                      }
                    : null, // Menonaktifkan tombol jika tidak tersedia
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
