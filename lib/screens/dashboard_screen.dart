import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haircut_express/components/barber_card.dart';
import 'package:haircut_express/providers/auth_provider.dart';
import 'package:haircut_express/providers/data_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  final Color mainBgColor = const Color(0xFF24344D); 
  final Color accentYellow = const Color(0xFFFFB300);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PERBAIKAN: Gunakan ref.watch
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selamat Datang,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(user?.displayName ?? 'Pelanggan', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  CircleAvatar(radius: 25, backgroundColor: accentYellow, child: const Icon(Icons.person, color: Colors.black)),
                ],
              ),
              // ... Sisa kode UI (Banner, List Barber) sama seperti sebelumnya ...
              // Pastikan tidak ada `Provider.of` di sini
              const SizedBox(height: 24),
              barbersAsyncValue.when(
                data: (barbers) => Column(children: barbers.map((b) => BarberCard(barber: b)).toList()),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text("Error: $e"),
              )
            ],
          ),
        ),
      ),
    );
  }
}