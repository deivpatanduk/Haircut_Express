import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../models/appointment_model.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  final Color mainBgColor = const Color(0xFF24344D);
  final Color cardColor = const Color(0xFF1B263B);
  final Color accentYellow = const Color(0xFFFFA500);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Silakan login terlebih dahulu")),
      );
    }

    // DEBUG: Cetak UID user di console
    print("Mencari data booking untuk User ID: ${user.uid}");

    return Scaffold(
      backgroundColor: mainBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Booking History",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('appointments')
                      .where('userId', isEqualTo: user.uid) 
                      // .orderBy('dateTime', descending: true) // <--- SAYA MATIKAN SEMENTARA AGAR TIDAK BUTUH INDEX
                      .snapshots(),
                  builder: (context, snapshot) {
                    
                    // 1. Cek Error
                    if (snapshot.hasError) {
                      print("Error Firebase: ${snapshot.error}");
                      return Center(
                        child: Text("Error: ${snapshot.error}", 
                        style: const TextStyle(color: Colors.red)),
                      );
                    }

                    // 2. Cek Loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // 3. Cek Data Kosong
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      print("Data booking KOSONG di Firebase.");
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history, size: 60, color: Colors.white24),
                            const SizedBox(height: 10),
                            const Text(
                              "Belum ada riwayat booking.",
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Text("User ID: ${user.uid}", style: const TextStyle(color: Colors.white24, fontSize: 10)),
                          ],
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;
                    print("Ditemukan ${docs.length} data booking."); // DEBUG

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        try {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final booking = AppointmentModel.fromMap(data, docs[index].id);
                          final isPending = booking.status == 'pending';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isPending ? accentYellow : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      booking.serviceName,
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPending ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        booking.status.toUpperCase(),
                                        style: TextStyle(
                                          color: isPending ? Colors.orange : Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Stylist: ${booking.employeeName}",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy, HH:mm').format(booking.dateTime),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Rp ${booking.price.toStringAsFixed(0)}",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          return Text("Error menampilkan data: $e", style: const TextStyle(color: Colors.red));
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}