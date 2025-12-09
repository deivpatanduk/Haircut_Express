import 'package:flutter/material.dart';

class BookingStepper extends StatelessWidget {
  final int currentStep;

  const BookingStepper({super.key, required this.currentStep});

  final Color darkBlue = const Color(0xFF1B263B);
  final Color mediumBlue = const Color(0xFF233044);
  final Color accentYellow = const Color(0xFFFFA500);

  @override
  Widget build(BuildContext context) {
    const double circleRadius = 15.0;
    final double availableWidth = MediaQuery.of(context).size.width - 32;

    return SizedBox(
      width: availableWidth,
      height: 60,
      child: Stack(
        children: [
          // GARIS PEMISAH LATAR BELAKANG
          Positioned(
            top: 15,
            width: availableWidth,
            height: 2,

            child: Row(
              children: [
                const SizedBox(width: circleRadius),

                // Garis 1 (Dipilih Barber -> Jadwal)
                Expanded(
                  child: Container(
                    height: 2,
                    color: currentStep >= 2
                        ? accentYellow
                        : Colors.grey.shade700,
                    margin: const EdgeInsets.symmetric(
                      horizontal: circleRadius,
                    ),
                  ),
                ),

                // Garis 2 (Jadwal -> Konfirmasi)
                Expanded(
                  child: Container(
                    height: 2,
                    color: currentStep >= 3
                        ? accentYellow
                        : Colors.grey.shade700,
                    margin: const EdgeInsets.symmetric(
                      horizontal: circleRadius,
                    ),
                  ),
                ),

                const SizedBox(width: circleRadius),
              ],
            ),
          ),

          // WIDGET LANGKAH (Angka dan Teks)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep(1, 'Pilih Barber', currentStep),
              _buildStep(2, 'Jadwal', currentStep),
              _buildStep(3, 'Konfirmasi', currentStep),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int stepNumber, String title, int current) {
    bool isActive = stepNumber == current;
    bool isCompleted = stepNumber <= current;

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? accentYellow : mediumBlue,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? accentYellow : Colors.grey.shade700,
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
            color: isCompleted ? accentYellow : Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
