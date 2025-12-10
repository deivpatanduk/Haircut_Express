import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_screen.dart';
import 'booking_screen.dart';
import 'schedule_screen.dart';
import 'profile_screen.dart';

class MainAppScreen extends ConsumerStatefulWidget {
  const MainAppScreen({super.key});

  @override
  ConsumerState<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends ConsumerState<MainAppScreen> {
  int _selectedIndex = 0;

  // WARNA TEMA BARU (Sesuai Profil)
  final Color mainBgColor = const Color(0xFF24344D); 
  final Color accentYellow = const Color(0xFFFFA500);

  // Daftar Halaman
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    const BookingScreen(),
    const ScheduleScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBgColor,
      
      // --- APP BAR (LOGO) MUNCUL DI SEMUA HALAMAN ---
      appBar: AppBar(
        backgroundColor: mainBgColor, // Warna biru tua
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.cut_outlined, color: accentYellow, size: 28),
            const SizedBox(width: 10),
            const Text(
              "Haircut Express", 
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                fontSize: 22
              )
            ),
          ],
        ),
        actions: [
           IconButton(
             icon: Icon(Icons.notifications_none, color: accentYellow),
             onPressed: (){},
           ),
           const SizedBox(width: 8),
        ],
      ),

      body: _widgetOptions.elementAt(_selectedIndex),

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
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: accentYellow),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: accentYellow,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: mainBgColor, // Background Nav Bar Biru Tua
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}