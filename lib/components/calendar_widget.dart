import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  final Color darkBlue = const Color(0xFF1B263B);
  final Color mediumBlue = const Color(0xFF233044);
  final Color accentYellow = const Color(0xFFFFA500);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kalender Picker
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
      ],
    );
  }

  // --- WIDGET METHOD: KALENDER PICKER ---
  Widget _buildCalendarPicker(BuildContext context) {
    // Konten Kalender Statis
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
              const Text(
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
    // Data Tanggal Fiktif
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

    return Column(
      children: [
        // Nama Hari (Su, Mo, Tu...)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: daysOfWeek
              .map(
                (day) => Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
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
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            String date = dates[index];
            bool isSelected = date == '5';
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
          bool isSelected = time == '14:00';

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
}
