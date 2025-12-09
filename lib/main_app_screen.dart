import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'booking_screen.dart'; // Digunakan untuk tab Booking

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  // Daftar widget untuk Bottom Navigation Bar (3 item: Home, Booking, History)
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(), // Index 0: Home
    const BookingScreen(), // Index 1: Booking
    const Center(
      child: Text(
        "History/Appointments",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ), // Index 2: History
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final Color darkBlue = const Color(0xFF1B263B);
  final Color accentYellow = const Color(0xFFFFA500);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,

      // A. APP BAR (HEADER) - Dengan Logo Gunting
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        // Hapus Leading
        leading: null,
        automaticallyImplyLeading: false,

        // MENGGANTI JUDUL DENGAN LOGO GUNTING DAN TEKS
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon Logo Gunting
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
        centerTitle: false,

        // Actions (Ikon Kanan) - Notifikasi dan Profil
        actions: [
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
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: accentYellow),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),

      // B. BODY (Konten Halaman)
      body: _widgetOptions.elementAt(_selectedIndex),

      // C. BOTTOM NAVIGATION BAR
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
