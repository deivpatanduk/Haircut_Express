import 'package:flutter/material.dart';
import 'package:haircut_express/models/barber.dart'; // Import Model
import 'package:haircut_express/components/barber_card.dart'; // Import Komponen
import 'package:haircut_express/components/booking_stepper.dart'; // Import Stepper
import 'package:haircut_express/screens/schedule_screen.dart'; // Import Schedule

class BookingScreen extends StatefulWidget {
  final Barber? selectedBarber; // Parameter opsional

  const BookingScreen({super.key, this.selectedBarber});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Data Dummy Layanan
  final List<Map<String, dynamic>> services = [
    {'name': 'Premium Haircut', 'price': 'Rp 80.000', 'duration': '45 min'},
    {'name': 'Basic Cut', 'price': 'Rp 70.000', 'duration': '30 min'},
    {'name': 'Beard Trim', 'price': 'Rp 50.000', 'duration': '20 min'},
  ];

  int selectedServiceIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Layanan'),
      ),
      body: Column(
        children: [
          // Step Indicator
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: BookingStepper(currentStep: 1),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Jika Barber sudah dipilih dari Dashboard, tampilkan infonya
                if (widget.selectedBarber != null) ...[
                  const Text(
                    'Barber Pilihan Anda:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  BarberCard(barber: widget.selectedBarber!, isBookingScreen: true),
                  const SizedBox(height: 24),
                ],

                const Text(
                  'Pilih Layanan:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // List Layanan
                ...List.generate(services.length, (index) {
                  final service = services[index];
                  final isSelected = selectedServiceIndex == index;
                  
                  return Card(
                    color: isSelected ? Colors.orange[50] : Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.orange : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => setState(() => selectedServiceIndex = index),
                      title: Text(service['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(service['duration']),
                      trailing: Text(
                        service['price'],
                        style: const TextStyle(
                          color: Color(0xFFFFA500),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // Tombol Lanjut
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedServiceIndex != -1
                    ? () {
                        // Lanjut ke ScheduleScreen (Step 2)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScheduleScreen(),
                          ),
                        );
                      }
                    : null, // Disable jika belum pilih layanan
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF1B263B),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Lanjut Pilih Jadwal'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}