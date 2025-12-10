import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haircut_express/components/barber_card.dart';
import 'package:haircut_express/providers/auth_provider.dart';
import 'package:haircut_express/providers/data_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // Warna Tema Baru
  final Color mainBgColor = const Color(0xFF24344D); 
  final Color accentYellow = const Color(0xFFFFA500);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final barbersAsyncValue = ref.watch(barbersProvider);

    return Scaffold(
      backgroundColor: mainBgColor, // Background Biru Tua
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat Datang,',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        user?.displayName ?? 'Pelanggan',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Teks Putih
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: accentYellow,
                    child: const CircleAvatar(
                      radius: 23,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- BANNER ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF1B263B), const Color(0xFF1B263B).withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Potongan Pertama?', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text('Diskon 20%', style: TextStyle(color: accentYellow, fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Gunakan kode: HEMAT20', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Icon(Icons.cut, size: 70, color: Colors.white.withOpacity(0.1)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- TITLE ---
              const Text(
                "Top Stylist",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),

              // --- LIST BARBER ---
              barbersAsyncValue.when(
                data: (barbers) {
                  if (barbers.isEmpty) {
                    return const Center(child: Text("Belum ada data stylist.", style: TextStyle(color: Colors.white70)));
                  }
                  return Column(
                    children: barbers.map((b) => BarberCard(barber: b)).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}