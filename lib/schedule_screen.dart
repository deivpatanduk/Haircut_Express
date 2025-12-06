import 'package:flutter/material.dart';
import 'booking_screen.dart'; // Untuk menggunakan model Barber

class ScheduleScreen extends StatelessWidget {
  // Terima objek Barber yang dikirim dari BookingScreen
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
          'Booking: ${selectedBarber.name}', // Tampilkan nama Barber yang dipilih
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
              child: _buildStepper(context),
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

            // >>> KALENDER PICKER (Konten Utama) <<<
            _buildCalendarPicker(context),
            const SizedBox(height: 20),

            // JUDUL PILIH WAKTU
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Text(
                'Pilih Waktu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // GRID SLOT WAKTU
            _buildTimeSlotGrid(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      // Tombol Lanjutkan di bagian bawah layar
      bottomSheet: _buildContinueButton(context),
    );
  }

  // --- WIDGET METHOD: STEPPER UNTUK SCHEDULE SCREEN (Langkah 2 Aktif) ---
  Widget _buildStepper(BuildContext context) {
    const double circleRadius = 15.0;

    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          // GARIS PEMISAH LATAR BELAKANG
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            child: Row(
              children: [
                SizedBox(width: circleRadius),
                // Garis 1 (Selesai/Aktif)
                Expanded(
                  child: Container(
                    height: 2,
                    color: accentYellow,
                    margin: const EdgeInsets.only(right: circleRadius),
                  ),
                ),
                // Garis 2 (Aktif ke Konfirmasi)
                Expanded(
                  child: Container(
                    height: 2,
                    color: accentYellow, // Garis 2 juga sudah aktif (kuning)
                    margin: const EdgeInsets.only(
                      left: circleRadius,
                      right: circleRadius,
                    ),
                  ),
                ),
                SizedBox(width: circleRadius),
              ],
            ),
          ),
          // WIDGET LANGKAH (Angka dan Teks)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep(1, 'Pilih Barber', true), // Langkah 1: Selesai
              _buildStep(2, 'Jadwal', true), // Langkah 2: Aktif
              _buildStep(3, 'Konfirmasi', false), // Langkah 3: Belum Aktif
            ],
          ),
        ],
      ),
    );
  }

  // Fungsi _buildStep yang sama (hanya perlu dicopy dari booking_screen.dart)
  Widget _buildStep(int stepNumber, String title, bool isActive) {
    return Column(
      children: [
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

  // --- WIDGET METHOD: KALENDER PICKER ---
  Widget _buildCalendarPicker(BuildContext context) {
    // Menggunakan package table_calendar (asumsi), di sini menggunakan container statis
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: mediumBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Header Bulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 16),
              Text(
                'December 2025',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Grid Hari
          _buildDayGrid(context),
        ],
      ),
    );
  }

  Widget _buildDayGrid(BuildContext context) {
    // Array Hari (Su, Mo, Tu, We, Th, Fr, Sa)
    final List<String> daysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    // Data Tanggal Fiktif (30 Nov - 3 Jan)
    final List<String> dates = [
      '30',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15',
      '16',
      '17',
      '18',
      '19',
      '20',
      '21',
      '22',
      '23',
      '24',
      '25',
      '26',
      '27',
      '28',
      '29',
      '30',
      '31',
      '1',
      '2',
      '3',
    ];

    // Ukuran cell (diasumsikan 7 kolom)
    final double cellSize =
        (MediaQuery.of(context).size.width - 32 - 32 - 10) / 7;

    return Column(
      children: [
        // Nama Hari (Su, Mo, Tu...)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: daysOfWeek
              .map(
                (day) => Container(
                  width: cellSize,
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),

        // Angka Tanggal
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: dates.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            String date = dates[index];
            bool isSelected =
                date == '5'; // Tanggal 5 adalah tanggal yang dipilih
            bool isCurrentMonth = index >= 1 && index <= 32;

            return Center(
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: isSelected ? accentYellow : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    date,
                    style: TextStyle(
                      color: isSelected
                          ? darkBlue
                          : isCurrentMonth
                          ? Colors.white
                          : Colors.white54,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- WIDGET METHOD: TIME SLOT GRID ---
  Widget _buildTimeSlotGrid() {
    final List<String> timeSlots = [
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
      '18:00',
      '19:00',
      '20:00',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: timeSlots.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          String time = timeSlots[index];
          bool isSelected = time == '14:00'; // Slot waktu yang dipilih

          return InkWell(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? accentYellow : mediumBlue,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? accentYellow : Colors.transparent,
                ),
              ),
              child: Center(
                child: Text(
                  time,
                  style: TextStyle(
                    color: isSelected ? darkBlue : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET METHOD: CONTINUE BUTTON ---
  Widget _buildContinueButton(BuildContext context) {
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
