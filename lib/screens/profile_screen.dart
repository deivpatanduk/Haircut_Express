import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haircut_express/providers/auth_provider.dart';
import 'package:haircut_express/providers/data_provider.dart';
import 'package:haircut_express/screens/edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  final Color profileBgColor = const Color(0xFF24344D);
  final Color accentYellow = const Color(0xFFFFB300);
  final Color cardColor = const Color(0xFF1B263B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reload user untuk memastikan data terbaru (foto profil) terambil
    FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    final bookingAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      backgroundColor: profileBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER USER ---
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: accentYellow,
                          child: CircleAvatar(
                            radius: 50,
                            // LOGIKA FOTO PROFIL:
                            // 1. Cek apakah ada user.photoURL
                            // 2. Jika tidak ada, pakai gambar dummy dari pravatar.cc
                            backgroundImage: (user?.photoURL != null &&
                                    user!.photoURL!.isNotEmpty)
                                ? NetworkImage(user.photoURL!)
                                : const NetworkImage(
                                    'https://i.pravatar.cc/300'),
                            onBackgroundImageError: (_, __) {
                              // Jika gagal load gambar (misal tidak ada internet), tidak error
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              // Navigasi ke Edit Profile
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const EditProfileScreen()),
                              ).then((_) {
                                // Refresh tampilan setelah kembali dari edit (opsional)
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit,
                                  size: 20, color: Colors.black),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName ?? 'Pengguna',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- STATISTIK ---
              const Text(
                "My Activity",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              bookingAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text("Error: $e",
                    style: const TextStyle(color: Colors.white)),
                data: (bookings) {
                  final upcoming = bookings
                      .where((b) =>
                          b['status'] == 'pending' ||
                          b['status'] == 'confirmed')
                      .length;
                  final history = bookings.length;

                  return Row(
                    children: [
                      _buildStatCard('Upcoming', upcoming.toString(),
                          Icons.calendar_today_outlined),
                      const SizedBox(width: 16),
                      _buildStatCard(
                          'Total Visits', history.toString(), Icons.history),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // --- KUPON PROMO ---
              const Text("Special Promo",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentYellow.withOpacity(0.8), accentYellow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: accentYellow.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_offer,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DISKON MEMBER BARU',
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          Text('POTONG20',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                    const Icon(Icons.copy, color: Colors.black54),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // --- TOMBOL LOGOUT ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Yakin ingin keluar akun?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Batal")),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Ya, Keluar")),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref.read(authControllerProvider).logout();
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("KELUAR APLIKASI",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: accentYellow, size: 28),
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
