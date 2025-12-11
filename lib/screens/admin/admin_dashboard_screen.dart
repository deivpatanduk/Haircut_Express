import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haircut_express/models/voucher_model.dart'; // Import Model Voucher
import 'package:haircut_express/providers/data_provider.dart';
import 'package:haircut_express/screens/login_screen.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final Color mainBgColor = const Color(0xFF24344D);
  final Color cardColor = const Color(0xFF1B263B);

  // --- FUNGSI LOGOUT ---
  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout Admin"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // 1. Sign out dari Firebase
      await FirebaseAuth.instance.signOut();

      // 2. Reset semua data provider agar bersih (PENTING)
      // Ini mencegah data admin 'menempel' saat login user biasa
      ref.invalidate(barbersProvider);
      ref.invalidate(userBookingsProvider);
      ref.invalidate(adminAllBookingsProvider);

      if (!mounted) return;

      // 3. Arahkan ke Login Screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // UBAH MENJADI 4 TAB
      child: Scaffold(
        backgroundColor: mainBgColor,
        appBar: AppBar(
          backgroundColor: cardColor,
          title: const Text("Admin Dashboard",
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () => _handleLogout(context),
              tooltip: "Logout",
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFFFB300),
            isScrollable: true, // Agar muat di layar kecil
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: "Bookings"),
              Tab(icon: Icon(Icons.people), text: "Stylists"),
              Tab(icon: Icon(Icons.content_cut), text: "Services"),
              Tab(
                  icon: Icon(Icons.confirmation_number),
                  text: "Vouchers"), // TAB BARU
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AdminBookingsTab(), // Tab 1
            _AdminStylistsTab(), // Tab 2
            _AdminServicesTab(), // Tab 3
            _AdminVouchersTab(), // Tab 4 (Baru)
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TAB 1: MANAJEMEN BOOKING (Approve & Cancel)
// ==========================================
class _AdminBookingsTab extends ConsumerWidget {
  const _AdminBookingsTab();

  Future<void> _approveBooking(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(docId)
        .update({'status': 'confirmed'});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Booking Disetujui!"), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _cancelBooking(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Batalkan Booking?"),
        content: const Text("Status akan berubah menjadi 'Cancelled'."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Ya, Batalkan",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .update({'status': 'cancelled'});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking Dibatalkan.")),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(adminAllBookingsProvider);

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
      data: (bookings) {
        if (bookings.isEmpty) {
          return const Center(
              child: Text("Tidak ada data booking.",
                  style: TextStyle(color: Colors.white)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (ctx, index) {
            final data = bookings[index];
            final status = data['status'] ?? 'pending';
            final id = data['id'];

            DateTime date = DateTime.now();
            if (data['dateTime'] is Timestamp) {
              date = (data['dateTime'] as Timestamp).toDate();
            }

            return Card(
              color: const Color(0xFF1B263B),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['serviceName'] ?? 'Service',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                  "${data['userName']} • ${DateFormat('dd MMM HH:mm').format(date)}",
                                  style:
                                      const TextStyle(color: Colors.white70)),
                              Text("Stylist: ${data['employeeName']}",
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _getStatusColor(status)),
                          ),
                          child: Text(status.toUpperCase(),
                              style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (status == 'pending' || status == 'confirmed')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _cancelBooking(context, id),
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text("Batalkan",
                                style: TextStyle(color: Colors.red)),
                          ),
                          if (status == 'pending')
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                onPressed: () => _approveBooking(context, id),
                                icon: const Icon(Icons.check,
                                    color: Colors.white),
                                label: const Text("Setujui",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                        ],
                      )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ==========================================
// TAB 2: MANAJEMEN STYLIST (Tambah & Edit)
// ==========================================
class _AdminStylistsTab extends ConsumerWidget {
  const _AdminStylistsTab();

  void _showStylistDialog(BuildContext context,
      {Map<String, dynamic>? barber}) {
    final isEdit = barber != null;
    final nameController =
        TextEditingController(text: isEdit ? barber['name'] : '');
    final specialtyController =
        TextEditingController(text: isEdit ? barber['specialty'] : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? "Edit Stylist" : "Tambah Stylist Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nama Stylist"),
            ),
            TextField(
              controller: specialtyController,
              decoration: const InputDecoration(labelText: "Spesialisasi"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              if (isEdit) {
                await FirebaseFirestore.instance
                    .collection('employees')
                    .doc(barber['id'])
                    .update({
                  'name': nameController.text,
                  'specialty': specialtyController.text,
                });
              } else {
                await FirebaseFirestore.instance.collection('employees').add({
                  'name': nameController.text,
                  'specialty': specialtyController.text,
                  'rating': 5.0,
                  'photoUrl': 'https://i.pravatar.cc/150',
                });
              }
              Navigator.pop(ctx);
            },
            child: Text(isEdit ? "Simpan" : "Tambah"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barbersAsync = ref.watch(barbersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFB300),
        onPressed: () => _showStylistDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: barbersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (barbers) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: barbers.length,
            itemBuilder: (ctx, index) {
              final barberObj = barbers[index];
              final barberMap = {
                'id': barberObj.id,
                'name': barberObj.name,
                'specialty': barberObj.specialty,
              };

              return Card(
                color: const Color(0xFF1B263B),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(barberObj.photoUrl),
                    backgroundColor: Colors.grey,
                  ),
                  title: Text(barberObj.name,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(barberObj.specialty,
                      style: const TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () =>
                        _showStylistDialog(context, barber: barberMap),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// TAB 3: MANAJEMEN SERVICES (Tambah & Edit)
// ==========================================
class _AdminServicesTab extends ConsumerWidget {
  const _AdminServicesTab();

  void _showServiceDialog(BuildContext context,
      {Map<String, dynamic>? service}) {
    final isEdit = service != null;
    final nameController =
        TextEditingController(text: isEdit ? service['name'] : '');
    final priceController =
        TextEditingController(text: isEdit ? service['price'].toString() : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? "Edit Layanan" : "Tambah Layanan Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nama Layanan"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Harga (Rp)", prefixText: "Rp "),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              final priceVal = double.tryParse(priceController.text) ?? 0;

              if (isEdit) {
                await FirebaseFirestore.instance
                    .collection('services')
                    .doc(service['serviceId'])
                    .update({
                  'name': nameController.text,
                  'price': priceVal,
                });
              } else {
                await FirebaseFirestore.instance.collection('services').add({
                  'name': nameController.text,
                  'price': priceVal,
                  'duration': 30,
                });
              }
              Navigator.pop(ctx);
            },
            child: Text(isEdit ? "Simpan" : "Tambah"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFB300),
        onPressed: () => _showServiceDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (services) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (ctx, index) {
              final service = services[index];
              final price = service['price'] ?? 0;

              return Card(
                color: const Color(0xFF1B263B),
                child: ListTile(
                  title: Text(service['name'] ?? 'No Name',
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text("Rp $price",
                      style: const TextStyle(
                          color: Color(0xFFFFB300),
                          fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () =>
                        _showServiceDialog(context, service: service),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// TAB 4: MANAJEMEN VOUCHER (KODE PROMO) - BARU!
// ==========================================
class _AdminVouchersTab extends ConsumerStatefulWidget {
  const _AdminVouchersTab();

  @override
  ConsumerState<_AdminVouchersTab> createState() => _AdminVouchersTabState();
}

class _AdminVouchersTabState extends ConsumerState<_AdminVouchersTab> {
  // Fungsi Cek & Hapus Voucher Kadaluarsa Otomatis
  Future<void> _cleanupExpiredVouchers(List<VoucherModel> vouchers) async {
    final now = DateTime.now();
    for (var voucher in vouchers) {
      // Jika hari ini sudah melewati tanggal expiry (dan bukan hari yang sama)
      if (now.isAfter(voucher.expiryDate.add(const Duration(days: 1)))) {
        await FirebaseFirestore.instance
            .collection('vouchers')
            .doc(voucher.id)
            .delete();
        debugPrint("Voucher ${voucher.code} expired and deleted.");
      }
    }
  }

  void _showVoucherDialog(BuildContext context, {VoucherModel? voucher}) {
    final isEdit = voucher != null;
    final codeController =
        TextEditingController(text: isEdit ? voucher.code : '');
    final discountController = TextEditingController(
        text: isEdit ? voucher.discountAmount.toInt().toString() : '');
    DateTime selectedDate = isEdit
        ? voucher.expiryDate
        : DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? "Edit Voucher" : "Buat Voucher Baru"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: "Kode Voucher (Unik)",
                  hintText: "CONTOH: HEMAT10",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Nominal Diskon (Rp)",
                  prefixText: "Rp ",
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("Berlaku Sampai: "),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Text(DateFormat('dd MMM yyyy').format(selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                if (codeController.text.isEmpty ||
                    discountController.text.isEmpty) return;

                final code = codeController.text.toUpperCase().trim();
                final amount = double.tryParse(discountController.text) ?? 0;

                if (isEdit) {
                  await FirebaseFirestore.instance
                      .collection('vouchers')
                      .doc(voucher.id)
                      .update({
                    'code': code,
                    'discountAmount': amount,
                    'expiryDate': Timestamp.fromDate(selectedDate),
                  });
                } else {
                  await FirebaseFirestore.instance.collection('vouchers').add({
                    'code': code,
                    'discountAmount': amount,
                    'expiryDate': Timestamp.fromDate(selectedDate),
                  });
                }
                if (mounted) Navigator.pop(ctx);
              },
              child: Text(isEdit ? "Simpan" : "Buat"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vouchersAsync = ref.watch(vouchersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFB300),
        onPressed: () => _showVoucherDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: vouchersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (vouchers) {
          // Panggil fungsi pembersih otomatis setiap kali data dimuat
          // Gunakan Future.microtask agar tidak error saat build widget
          Future.microtask(() => _cleanupExpiredVouchers(vouchers));

          if (vouchers.isEmpty) {
            return const Center(
                child: Text("Belum ada voucher aktif.",
                    style: TextStyle(color: Colors.white70)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vouchers.length,
            itemBuilder: (ctx, index) {
              final voucher = vouchers[index];
              final isExpired = DateTime.now()
                  .isAfter(voucher.expiryDate.add(const Duration(days: 1)));

              return Card(
                color: const Color(0xFF1B263B),
                child: ListTile(
                  title: Text(voucher.code,
                      style: const TextStyle(
                          color: Color(0xFFFFB300),
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  subtitle: Text(
                    "Diskon: Rp ${voucher.discountAmount.toInt()}\nExp: ${DateFormat('dd MMM yyyy').format(voucher.expiryDate)}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () =>
                            _showVoucherDialog(context, voucher: voucher),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('vouchers')
                              .doc(voucher.id)
                              .delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
