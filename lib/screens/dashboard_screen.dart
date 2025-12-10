import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/barber_card.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data saat dashboard dibuka
    Future.microtask(() => 
      Provider.of<DataProvider>(context, listen: false).fetchAllData()
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF24344D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selamat Datang,', style: TextStyle(color: Colors.white70)),
                      Text(user?.displayName ?? 'Pelanggan', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 30),
              
              const Text("Top Stylist", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),

              // List Barber
              if (dataProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (dataProvider.barbers.isEmpty)
                const Text("Belum ada stylist tersedia.", style: TextStyle(color: Colors.white))
              else
                Column(
                  children: dataProvider.barbers.map((b) => BarberCard(barber: b)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}