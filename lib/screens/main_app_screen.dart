import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'booking_screen.dart';
import 'schedule_screen.dart'; 
import 'profile_screen.dart';   

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  // Hapus 'const' dari BookingScreen dan ScheduleScreen di bawah ini
  final List<Widget> _pages = [
    const DashboardScreen(),
    const BookingScreen(), // Jika masih merah, hapus 'const' di depannya
    const ScheduleScreen(), // Jika masih merah, hapus 'const' di depannya
    const ProfileScreen(),
  ];

  // Jika kode di atas masih error, GANTI menjadi ini (tanpa const sama sekali):
  /*
  final List<Widget> _pages = [
    DashboardScreen(),
    BookingScreen(),
    ScheduleScreen(),
    ProfileScreen(),
  ];
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.content_cut, color: Color(0xFFFFA500)), 
            const SizedBox(width: 10),
            const Text(
              "Haircut Express",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      
      body: _pages[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF24344D),
        selectedItemColor: const Color(0xFFFFA500),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}