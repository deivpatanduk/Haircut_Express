import 'package:flutter/material.dart';

class BookingStepper extends StatelessWidget {
  final int currentStep;

  const BookingStepper({Key? key, required this.currentStep}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      color: Colors.white,
      child: Row(
        children: [
          _buildStepCircle(0, "Stylist"), // Langkah 1
          _buildLine(0),
          _buildStepCircle(1, "Service"), // Langkah 2
          _buildLine(1),
          _buildStepCircle(2, "Date & Time"), // Langkah 3
        ],
      ),
    );
  }

  Widget _buildStepCircle(int index, String label) {
    bool isActive = currentStep >= index;
    bool isCurrent = currentStep == index;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.white,
            border: Border.all(color: isActive ? Colors.black : Colors.grey.shade300),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive
                ? Icon(Icons.check, color: Colors.white, size: 18)
                : Text("${index + 1}", style: TextStyle(color: Colors.grey)),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black : Colors.grey,
          ),
        )
      ],
    );
  }

  Widget _buildLine(int index) {
    return Expanded(
      child: Container(
        height: 2,
        color: currentStep > index ? Colors.black : Colors.grey.shade300,
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 15),
      ),
    );
  }
}