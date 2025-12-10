import 'package:flutter/material.dart';
import 'booking_screen.dart';
import 'components/booking_stepper.dart';
import 'main_app_screen.dart';

class ConfirmationScreen extends StatefulWidget {
  final Barber selectedBarber;
  final String selectedDate;
  final String selectedTime;

  const ConfirmationScreen({
    super.key,
    required this.selectedBarber,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final Color darkBlue = const Color(0xFF1B263B);
  final Color mediumBlue = const Color(0xFF233044);
  final Color accentYellow = const Color(0xFFFFA500);

  // Total harga statis berdasarkan desain (Rp 75.000)
  final int _currentTotal = 75000;

  @override
  void initState() {
    super.initState();
    // Semua logika inisialisasi layanan dihapus
  }

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
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Konfirmasi Booking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Stepper
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: BookingStepper(currentStep: 3),
            ),

            // Judul
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Konfirmasi Booking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Sub-judul
            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
              child: Text(
                'Periksa kembali detail booking Anda',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),

            // Detail Booking (Ringkasan Utama)
            _buildDetailRingkasan(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBookNowButton(context, _currentTotal),
    );
  }

  Widget _buildDetailRingkasan() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: mediumBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Layanan
          const Text(
            'Detail Booking',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Layanan yang Dipilih (Statis: Haircut)
          _buildServiceRow(
            Icons.content_cut,
            'Haircut',
            'Layanan potong rambut profesional',
            accentYellow,
          ),
          const Divider(color: Colors.white12, height: 30),

          // Detail Barber
          _buildBarberDetailRow(),
          const Divider(color: Colors.white12, height: 30),

          // Detail Waktu & Tanggal
          _buildDetailRow(
            Icons.calendar_today,
            'Tanggal',
            'Rabu, ${widget.selectedDate} Desember 2025',
            accentYellow,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            Icons.access_time,
            'Waktu',
            '${widget.selectedTime} WITA',
            accentYellow,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.person, 'Nama', 'deiv patanduk', accentYellow),
        ],
      ),
    );
  }

  Widget _buildBarberDetailRow() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(widget.selectedBarber.imagePath),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.selectedBarber.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow, size: 14),
                const SizedBox(width: 4),
                Text(
                  '4.9 (${widget.selectedBarber.specialization})',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceRow(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBookNowButton(BuildContext context, int total) {
    return Container(
      color: darkBlue,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              Text(
                'Rp ${total.toStringAsFixed(0)}',
                style: TextStyle(
                  color: accentYellow,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Tombol Edit Booking
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // Kembali ke halaman Jadwal
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Colors.white70),
                  ),
                  child: const Text(
                    'Edit Booking',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Tombol Konfirmasi Booking
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainAppScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentYellow,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Konfirmasi Booking',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
