import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haircut_express/providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'booking_screen.dart';
import 'schedule_screen.dart'; // Pastikan file ini ada atau ganti dengan placeholder

class MainAppScreen extends ConsumerStatefulWidget {
  const MainAppScreen({super.key});

  @override
  ConsumerState<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends ConsumerState<MainAppScreen> {
  int _selectedIndex = 0;

  // Warna Tema (Konsisten dengan desain Anda)
  final Color darkBlue = const Color(0xFF1B263B);
  final Color accentYellow = const Color(0xFFFFA500);

  // Daftar Halaman
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(), // Index 0: Home
    const BookingScreen(), // Index 1: Booking (Langsung ke halaman booking atau schedule)
    const ScheduleScreen(), // Index 2: History/Jadwal (Pastikan file schedule_screen.dart ada)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false, // Hilangkan tombol back default
        
        // Judul dengan Logo Gunting
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cut_outlined, color: accentYellow, size: 28),
            const SizedBox(width: 8),
            const Text(
              'Haircut Express',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        
        // Tombol Aksi di Kanan
        actions: [
          // Tombol Notifikasi (Dummy UI)
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_none, color: accentYellow),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // TODO: Implementasi halaman notifikasi
            },
          ),
          
          // Tombol Logout (Menggunakan Riverpod)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Keluar',
            onPressed: () async {
              // Tampilkan dialog konfirmasi sebelum logout
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                // Panggil fungsi logout dari AuthController
                await ref.read(authControllerProvider).logout();
                // Tidak perlu navigasi manual, authStateChanges di main.dart akan otomatis melempar ke LoginScreen
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // --- BODY ---
      body: _widgetOptions.elementAt(_selectedIndex),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home, color: accentYellow),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month, color: accentYellow),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            activeIcon: Icon(Icons.history, color: accentYellow),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: accentYellow,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: darkBlue,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}