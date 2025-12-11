import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:haircut_express/providers/auth_provider.dart';
import 'package:haircut_express/providers/data_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  // Warna Tema Admin
  final Color adminBgColor = const Color(0xFF1B263B);
  final Color accentGold = const Color(0xFFFFB300);
  final Color cardColor = const Color(0xFF24344D);

  // Fungsi Update Status
  Future<void> _updateStatus(BuildContext context, String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .update({'status': newStatus});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diubah: ${newStatus.toUpperCase()}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBookingsAsync = ref.watch(adminAllBookingsProvider);

    return DefaultTabController(
      length: 3, // Tiga Tab
      child: Scaffold(
        backgroundColor: adminBgColor,
        appBar: AppBar(
          backgroundColor: adminBgColor,
          elevation: 0,
          title: const Text("Admin Panel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () => ref.read(authControllerProvider).logout(),
            ),
          ],
          bottom: TabBar(
            indicatorColor: accentGold,
            labelColor: accentGold,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "BARU (Pending)"),
              Tab(text: "JADWAL (Confirmed)"),
              Tab(text: "RIWAYAT (History)"),
            ],
          ),
        ),
        body: allBookingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.white))),
          data: (bookings) {
            // FILTER DATA BERDASARKAN STATUS
            final pendingBookings = bookings.where((b) => b['status'] == 'pending').toList();
            final confirmedBookings = bookings.where((b) => b['status'] == 'confirmed').toList();
            final historyBookings = bookings.where((b) => b['status'] == 'completed' || b['status'] == 'rejected').toList();

            return TabBarView(
              children: [
                _buildBookingList(context, pendingBookings, 'pending'),
                _buildBookingList(context, confirmedBookings, 'confirmed'),
                _buildBookingList(context, historyBookings, 'history'),
              ],
            );
          },
        ),
      ),
    );
  }

  // WIDGET GENERATOR LIST
  Widget _buildBookingList(BuildContext context, List<Map<String, dynamic>> bookings, String listType) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 60, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text("Tidak ada data di sini.", style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final String status = booking['status'] ?? 'pending';
        final Timestamp? timestamp = booking['bookingDate'];
        final DateTime date = timestamp?.toDate() ?? DateTime.now();
        final String formattedDate = DateFormat('dd MMM, HH:mm').format(date);

        return Card(
          color: cardColor,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: status == 'pending' ? accentGold : Colors.transparent, 
              width: 1
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER: Email & Tanggal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        booking['userEmail'] ?? 'User',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusChip(status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate, // TANGGAL BOOKING
                  style: TextStyle(color: accentGold, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                
                const Divider(color: Colors.white24, height: 24),

                // BODY: Detail Layanan
                _buildInfoRow(Icons.cut, booking['serviceName'] ?? '-', Colors.white),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.person, "Stylist: ${booking['barberName']}", Colors.white70),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.access_time, "Slot: ${booking['timeSlot'] ?? '-'}", Colors.white70),

                const SizedBox(height: 16),

                // FOOTER: Tombol Aksi (Hanya muncul jika bukan history)
                if (listType == 'pending') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _updateStatus(context, booking['id'], 'rejected'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          foregroundColor: Colors.redAccent,
                        ),
                        child: const Text("Tolak"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _updateStatus(context, booking['id'], 'confirmed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentGold,
                          foregroundColor: adminBgColor,
                        ),
                        child: const Text("TERIMA PESANAN"),
                      ),
                    ],
                  )
                ] else if (listType == 'confirmed') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(context, booking['id'], 'completed'),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("TANDAI SELESAI"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'confirmed': color = Colors.blue; break;
      case 'completed': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: color, fontSize: 14)),
      ],
    );
  }
}