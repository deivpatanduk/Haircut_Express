import 'package:flutter/material.dart';
import 'booking_screen.dart'; // Untuk model Barber
import 'components/booking_stepper.dart';

class ConfirmationScreen extends StatelessWidget {
  final Barber selectedBarber;
  final String selectedDate;
  final String selectedTime;

  const ConfirmationScreen({
    super.key,
    required this.selectedBarber,
    required this.selectedDate,
    required this.selectedTime,
  });

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
            // STEPPER (Langkah 3 Aktif)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: BookingStepper(currentStep: 3),
            ),

            // JUDUL UTAMA
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Ringkasan Booking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            _buildSummaryCard(context),
            _buildServiceSelection(context),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBookNowButton(context),
    );
  }

  // --- WIDGET: RINGKASAN BARBER & JADWAL ---
  Widget _buildSummaryCard(BuildContext context) {
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
          // Header Ringkasan
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                // Menggunakan URL dari objek Barber yang dipilih
                backgroundImage: NetworkImage(selectedBarber.imagePath),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedBarber.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    selectedBarber.specialization,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 30),

          // Detail Waktu
          _buildDetailRow(
            Icons.calendar_today,
            'Tanggal',
            selectedDate,
            accentYellow,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            Icons.access_time,
            'Waktu',
            selectedTime,
            accentYellow,
          ),
        ],
      ),
    );
  }

  // --- WIDGET: PILIHAN LAYANAN (Statis) ---
  Widget _buildServiceSelection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Layanan Tambahan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          _buildServiceOption('Haircut (Wajib)', 'Rp 50.000', true),
          _buildServiceOption('Shave & Trim', 'Rp 25.000', false),
          _buildServiceOption('Hair Wash & Massage', 'Rp 30.000', false),
        ],
      ),
    );
  }

  Widget _buildServiceOption(String service, String price, bool isChecked) {
    return Card(
      color: mediumBlue,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  price,
                  style: TextStyle(
                    color: accentYellow,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Checkbox(
              value: isChecked,
              onChanged: (bool? newValue) {}, // Statis untuk demo
              activeColor: accentYellow,
              checkColor: darkBlue,
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: BARIS DETAIL PEMBANTU ---
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

  // --- WIDGET: TOMBOL BOOKING FINAL ---
  Widget _buildBookNowButton(BuildContext context) {
    const int total = 80000;

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
                'Total:',
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Proses booking final
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentYellow,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Konfirmasi & Bayar Sekarang',
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
    );
  }
}
