import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haircut_express/models/barber.dart';
import 'package:haircut_express/components/barber_card.dart';
import 'package:haircut_express/components/booking_stepper.dart';
import 'package:haircut_express/providers/data_provider.dart';
import 'package:haircut_express/screens/schedule_screen.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Barber? selectedBarber;

  const BookingScreen({super.key, this.selectedBarber});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int selectedServiceIndex = -1;
  Map<String, dynamic>? selectedServiceData;

  // Warna Tema
  final Color mainBgColor = const Color(0xFF24344D);
  final Color accentYellow = const Color(0xFFFFA500);
  final Color cardColor = const Color(0xFF1B263B); // Warna kartu di dalam booking

  Future<void> _submitBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user.uid,
        'userEmail': user.email,
        'barberName': widget.selectedBarber?.name ?? 'Any Barber',
        'serviceName': selectedServiceData!['name'],
        'servicePrice': selectedServiceData!['price'],
        'duration': selectedServiceData!['durationInMinutes'],
        'status': 'pending',
        'bookingDate': Timestamp.now(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Berhasil Dibuat!')),
      );
      
      // Pindah ke tab History (Schedule) dengan menghapus stack navigasi
      // Cara sederhana: kembali ke MainAppScreen
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: mainBgColor,
      appBar: AppBar(
        title: const Text('Pilih Layanan', style: TextStyle(color: Colors.white)),
        backgroundColor: mainBgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: BookingStepper(currentStep: 1),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (widget.selectedBarber != null) ...[
                  const Text('Barber Pilihan:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  BarberCard(barber: widget.selectedBarber!, isBookingScreen: true),
                  const SizedBox(height: 24),
                ],

                const Text('Daftar Layanan:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                
                servicesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                  error: (err, stack) => Text('Error: $err', style: const TextStyle(color: Colors.white)),
                  data: (services) {
                    if (services.isEmpty) return const Text("Tidak ada layanan.", style: TextStyle(color: Colors.white70));
                    
                    return Column(
                      children: List.generate(services.length, (index) {
                        final service = services[index];
                        final isSelected = selectedServiceIndex == index;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedServiceIndex = index;
                              selectedServiceData = service;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? accentYellow : cardColor, // Kuning jika dipilih, Gelap jika tidak
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service['name'] ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? const Color(0xFF1B263B) : Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${service['durationInMinutes']} Menit',
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFF1B263B).withOpacity(0.7) : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Rp ${service['price']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? const Color(0xFF1B263B) : accentYellow,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedServiceIndex != -1 ? _submitBooking : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: accentYellow,
                  foregroundColor: const Color(0xFF1B263B),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: const Text('KONFIRMASI BOOKING', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}