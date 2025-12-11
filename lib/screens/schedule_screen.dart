import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haircut_express/providers/data_provider.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  final Color mainBgColor =
      const Color(0xFF24344D); // Warna latar belakang layar (tetap gelap)

  // GANTI BAGIAN INI:
  // final Color cardColor = const Color(0xFF1B263B); // <-- Warna Lama (Navy Gelap)
  final Color cardColor = Colors.blue.shade900; // <-- Warna Baru (Biru Tua)

  // Opsi warna biru lain yang bisa Anda coba:
  // final Color cardColor = Colors.blue;             // Biru Terang (Standard)
  // final Color cardColor = const Color(0xFF1E88E5); // Biru Material Design

  final Color accentYellow = const Color(0xFFFFB300);
  // ...

  // --- FUNGSI INTERAKTIF ---

  Future<void> _handleAction(
      BuildContext context, String docId, String currentStatus) async {
    final isPending = currentStatus == 'pending';
    final actionWord = isPending ? "Membatalkan" : "Menghapus";

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text("$actionWord Booking?",
            style: const TextStyle(color: Colors.white)),
        content: Text(
          isPending
              ? "Apakah Anda yakin ingin membatalkan jadwal ini?\nStatus akan berubah menjadi 'Cancelled'."
              : "Apakah Anda yakin ingin menghapus riwayat ini secara permanen?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Kembali", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: Text(isPending ? "Ya, Batalkan" : "Ya, Hapus",
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (isPending) {
        await _cancelBooking(docId);
      } else {
        await _deleteHistory(docId);
      }
    }
  }

  Future<void> _cancelBooking(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(documentId)
          .update({'status': 'cancelled'});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking berhasil dibatalkan.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteHistory(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(documentId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Riwayat berhasil dihapus.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _formatBookingDateTime(Timestamp? timestamp) {
    if (timestamp == null) return "Tanggal Invalid";
    final dateTime = timestamp.toDate();
    // Menggunakan format jam dan menit dari timestamp
    return DateFormat('d MMM yyyy, HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      backgroundColor: mainBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Booking History",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: bookingsAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                  error: (e, _) => Center(
                      child: Text("Error: $e",
                          style: const TextStyle(color: Colors.white))),
                  data: (bookings) {
                    if (bookings.isEmpty) {
                      return const Center(
                          child: Text("Belum ada riwayat booking.",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)));
                    }
                    return ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];

                        // FIX: Pastikan nama key sesuai dengan AppointmentModel & DataProvider
                        final String docId = booking['id'] ?? '';
                        final String status = booking['status'] ?? 'pending';
                        final String serviceName =
                            booking['serviceName'] ?? 'Layanan';
                        final String employeeName =
                            booking['employeeName'] ?? 'Unknown';

                        // Handling Harga (bisa num atau string)
                        final dynamic rawPrice = booking['price'];
                        final String priceDisplay =
                            rawPrice != null ? rawPrice.toString() : '0';

                        // Handling Tanggal
                        final Timestamp? bookingTimestamp =
                            booking['dateTime'] as Timestamp?;

                        final isPending = status == 'pending';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: _getStatusColor(status).withOpacity(0.5),
                                width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // HEADER KARTU
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(serviceName,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                          color: _getStatusColor(status),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: Colors.white24, height: 1),
                              const SizedBox(height: 12),

                              // DETAIL KARTU
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                size: 16, color: accentYellow),
                                            const SizedBox(width: 8),
                                            Text(
                                                _formatBookingDateTime(
                                                    bookingTimestamp),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text("Stylist: $employeeName",
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text("Price",
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12)),
                                      Text("Rp $priceDisplay",
                                          style: TextStyle(
                                              color: accentYellow,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // TOMBOL AKSI
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  icon: Icon(
                                      isPending
                                          ? Icons.cancel_presentation
                                          : Icons.delete_outline,
                                      color: isPending
                                          ? Colors.orangeAccent
                                          : Colors.redAccent),
                                  label: Text(
                                      isPending
                                          ? 'Batalkan Booking'
                                          : 'Hapus Riwayat',
                                      style: TextStyle(
                                          color: isPending
                                              ? Colors.orangeAccent
                                              : Colors.redAccent,
                                          fontWeight: FontWeight.bold)),
                                  onPressed: docId.isNotEmpty
                                      ? () =>
                                          _handleAction(context, docId, status)
                                      : null,
                                ),
                              )
                            ],
                          ),
                        );
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
