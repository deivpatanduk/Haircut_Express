import 'package:flutter/material.dart';

typedef DateSelectedCallback = void Function(String date);
typedef TimeSelectedCallback = void Function(String time);

class CalendarWidget extends StatelessWidget {
  final String? selectedDate;
  final String? selectedTimeSlot;

  final DateSelectedCallback onDateSelected;
  final TimeSelectedCallback onTimeSelected;

  CalendarWidget({
    // <<< HAPUS 'const' DI SINI
    super.key,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  final Color darkBlue = const Color(0xFF1B263B);
  final Color mediumBlue = const Color(0xFF233044);
  final Color accentYellow = const Color(0xFFFFA500);

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCalendarPicker(context),
        const SizedBox(height: 20),

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

        _buildTimeSlotGrid(),
      ],
    );
  }

  Widget _buildCalendarPicker(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: mediumBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
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

          _buildDayGrid(context),
        ],
      ),
    );
  }

  Widget _buildDayGrid(BuildContext context) {
    final List<String> daysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Column(
      children: [
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
            bool isCurrentMonth = index >= 1 && index <= 32;
            bool isSelected = selectedDate == date;

            return Center(
              child: InkWell(
                onTap: isCurrentMonth ? () => onDateSelected(date) : null,
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
                        // PERBAIKAN: Gunakan FontWeight.w400 (normal)
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w400,
                      ),
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

  Widget _buildTimeSlotGrid() {
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
          bool isSelected = selectedTimeSlot == time;

          return InkWell(
            onTap: () => onTimeSelected(time),
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
                    // PERBAIKAN: Gunakan FontWeight.w400 (normal)
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
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
