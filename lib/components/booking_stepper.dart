import 'package:flutter/material.dart';

class BookingStepper extends StatelessWidget {
  final int currentStep;

  const BookingStepper({Key? key, required this.currentStep}) : super(key: key);

  static const Color activeColor = Colors.black;
  static final Color inactiveLineColor = Colors.grey.shade200;
  static final Color futureTextColor = Colors.grey.shade600;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepCircle(context, 0, "Stylist"), // Langkah 1 (index 0)
          _buildLine(0), // Garis 1 -> 2
          _buildStepCircle(context, 1, "Service"), // Langkah 2 (index 1)
          _buildLine(1), // Garis 2 -> 3
          _buildStepCircle(context, 2, "Date & Time"), // Langkah 3 (index 2)
        ],
      ),
    );
  }

  Widget _buildStepCircle(BuildContext context, int index, String label) {
    // currentStep: 1, 2, 3 (dari BookingScreen)
    // index: 0, 1, 2 (lokal di Stepper)
    bool isCompleted = currentStep > (index + 1);
    bool isCurrent = currentStep == (index + 1);

    Color circleColor = isCompleted || isCurrent ? activeColor : Colors.white;
    Color circleBorderColor =
        isCompleted || isCurrent ? activeColor : inactiveLineColor;

    Widget circleContent;
    if (isCompleted) {
      circleContent = const Icon(Icons.check, color: Colors.white, size: 18);
    } else {
      circleContent = Text(
        "${index + 1}",
        style: TextStyle(
          color: isCurrent ? Colors.white : futureTextColor,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleColor,
            border: Border.all(color: circleBorderColor, width: 2),
            shape: BoxShape.circle,
          ),
          child: Center(child: circleContent),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCompleted || isCurrent ? activeColor : futureTextColor,
          ),
        )
      ],
    );
  }

  Widget _buildLine(int index) {
    // Logika standar: Garis aktif jika langkah sebelumnya selesai.
    bool isCompletedBeforeLine = currentStep > (index + 1);

    // KASUS KHUSUS: Memaksa Garis 1->2 non-aktif saat Langkah 2 aktif, karena Langkah 1 dilewati saat navigasi dari BarberCard.
    if (currentStep == 2 && index == 0) {
      isCompletedBeforeLine = false;
    }

    return Expanded(
      child: Container(
        height: 2,
        color: isCompletedBeforeLine ? activeColor : inactiveLineColor,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      ),
    );
  }
}
