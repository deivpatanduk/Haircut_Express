import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haircut_express/providers/data_provider.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  final Color mainBgColor = const Color(0xFF24344D);
  final Color cardColor = const Color(0xFF1B263B);
  final Color accentYellow = const Color(0xFFFFB300);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil data user booking menggunakan Riverpod (bukan Provider.of)
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      backgroundColor: mainBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Booking History", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: bookingsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                  error: (e, _) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.white))),
                  data: (bookings) {
                    if (bookings.isEmpty) {
                      return const Center(child: Text("Belum ada riwayat booking.", style: TextStyle(color: Colors.white70, fontSize: 16)));
                    }
                    return ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        final isPending = booking['status'] == 'pending';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isPending ? accentYellow : Colors.transparent, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(booking['serviceName'] ?? 'Layanan', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isPending ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      (booking['status'] ?? 'Unknown').toString().toUpperCase(),
                                      style: TextStyle(color: isPending ? Colors.orange : Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text("Stylist: ${booking['barberName']}", style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 4),
                              Text("Rp ${booking['servicePrice']}", style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}