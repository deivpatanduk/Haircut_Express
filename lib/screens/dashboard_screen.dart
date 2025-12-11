import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import untuk Clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haircut_express/components/barber_card.dart';
import 'package:haircut_express/providers/auth_provider.dart';
import 'package:haircut_express/providers/data_provider.dart';
import 'package:haircut_express/screens/booking_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  final Color mainBgColor = const Color(0xFF24344D);
  final Color cardColor = const Color(0xFF1B263B);
  final Color accentYellow = const Color(0xFFFFB300);

  // Metode untuk membangun banner voucher
  Widget _buildPromoBanner(
      BuildContext context, String title, String subtitle, String voucherCode) {
    return GestureDetector(
      onTap: () {
        // 1. Salin Kode ke Clipboard
        Clipboard.setData(ClipboardData(text: voucherCode));

        // 2. Tampilkan Info
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Kode '$voucherCode' disalin! Tempel saat booking."),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ));

        // 3. Navigasi ke BookingScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const BookingScreen(), // Tidak perlu kirim parameter diskon lagi
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: accentYellow.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Tiket / Voucher
            Icon(Icons.confirmation_number_outlined,
                color: accentYellow, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: accentYellow,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tampilan Kode Voucher Kecil
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border:
                            Border.all(color: accentYellow.withOpacity(0.5))),
                    child: Text(
                      "KODE: $voucherCode",
                      style: TextStyle(
                          color: accentYellow,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            const Icon(Icons.copy, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final barbersAsyncValue = ref.watch(barbersProvider);

    return Scaffold(
      backgroundColor: mainBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Greeting)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selamat Datang,',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(user?.displayName ?? 'Pelanggan',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                  CircleAvatar(
                      radius: 25,
                      backgroundColor: accentYellow,
                      child: const Icon(Icons.person, color: Colors.black)),
                ],
              ),

              const SizedBox(height: 24),

              // 2. PROMO BANNER (Hardcoded Contoh)
              // Pastikan Anda membuat kode "DISKON20" dan "HEMAT10" ini di Admin Panel
              // agar bisa digunakan user!
              _buildPromoBanner(
                  context,
                  'DISKON SPESIAL!',
                  'Potongan harga spesial untuk pengguna baru.',
                  'DISKON20' // Kode Voucher
                  ),

              _buildPromoBanner(context, 'PROMO WEEKEND',
                  'Lebih hemat cukur di akhir pekan.', 'HEMAT10' // Kode Voucher
                  ),

              const SizedBox(height: 12),

              // 4. BARBER LIST HEADER
              const Text('Stylist Pilihan',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 15),

              // 5. BARBER LIST
              barbersAsyncValue.when(
                data: (barbers) {
                  if (barbers.isEmpty) {
                    return const Center(
                        child: Text("Belum ada stylist tersedia.",
                            style: TextStyle(color: Colors.white70)));
                  }
                  return Column(
                    children: barbers
                        .map((b) => Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: BarberCard(barber: b),
                            ))
                        .toList(),
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
                error: (e, _) => Text("Error loading barbers: $e",
                    style: const TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
