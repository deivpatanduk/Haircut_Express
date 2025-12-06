import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
// >>> TAMBAHKAN IMPORT BOOKING SCREEN DI SINI <<<
import 'booking_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  // Daftar widget untuk Bottom Navigation Bar (Disesuaikan)
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    // GANTI: Widget Index 1 (Booking) dengan BookingScreen()
    const BookingScreen(),
    const Center(
      child: Text(
        "History/Appointments",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Warna yang konsisten dengan desain
  final Color darkBlue = const Color(0xFF1B263B);
  final Color accentYellow = const Color(0xFFFFA500);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,

      // A. APP BAR (HEADER) - Dibiarkan sesuai permintaan Anda sebelumnya
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,

        title: const Text(
          'Haircut Express',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

        actions: [
          // 1. Ikon Notifikasi
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_none, color: accentYellow),
                // Indikator notifikasi 3
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
            onPressed: () {},
          ),
          // 2. Ikon Profil/Akun
          IconButton(
            icon: Icon(Icons.person_outline, color: accentYellow),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),

      // B. BODY (Konten Halaman)
      body: _widgetOptions.elementAt(_selectedIndex),

      // C. BOTTOM NAVIGATION BAR - Dibiarkan sesuai permintaan Anda sebelumnya
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          // Item 1: Home
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home, color: accentYellow),
            label: 'Home',
          ),
          // Item 2: Calendar/Booking
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month, color: accentYellow),
            label: 'Booking',
          ),
          // Item 3: History/Appointments
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
