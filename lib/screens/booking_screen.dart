import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:haircut_express/models/barber.dart';
import 'package:haircut_express/models/voucher_model.dart'; // Pastikan import model voucher
import 'package:haircut_express/components/booking_stepper.dart';
import 'package:haircut_express/providers/data_provider.dart';
import 'package:haircut_express/services/notification_service.dart';
import 'package:haircut_express/screens/main_app_screen.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Barber? selectedBarber;

  const BookingScreen({
    super.key,
    this.selectedBarber,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  // STATE LOKAL
  int _currentStep = 0; // 0=Stylist, 1=Service, 2=Date&Time
  Barber? _selectedBarber;
  Map<String, dynamic>? _selectedService;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  bool _isLoading = false;

  // STATE VOUCHER
  final TextEditingController _voucherController = TextEditingController();
  double _discountAmount = 0; // Menggunakan Nominal (Rp), bukan Persentase
  String? _appliedVoucherCode;
  bool _isValidatingVoucher = false;

  // WARNA TEMA
  final Color mainBgColor = const Color(0xFF24344D);
  final Color cardColor = const Color(0xFF1B263B);
  final Color accentYellow = const Color(0xFFFFB300);

  @override
  void initState() {
    super.initState();
    if (widget.selectedBarber != null) {
      _selectedBarber = widget.selectedBarber;
      _currentStep = 1; // Lompat ke step Service jika barber sudah dipilih
    }
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  // --- LOGIKA VOUCHER ---
  Future<void> _checkVoucher() async {
    final code = _voucherController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() => _isValidatingVoucher = true);

    // Reset diskon sebelumnya saat mengecek kode baru
    setState(() {
      _discountAmount = 0;
      _appliedVoucherCode = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('vouchers')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _showSnack("Kode voucher tidak ditemukan.", Colors.redAccent);
      } else {
        final doc = snapshot.docs.first;
        final voucher = VoucherModel.fromMap(doc.data(), doc.id);

        // Cek Kadaluarsa
        if (DateTime.now()
            .isAfter(voucher.expiryDate.add(const Duration(days: 1)))) {
          _showSnack("Voucher sudah kadaluarsa.", Colors.redAccent);
        } else {
          // Voucher Valid
          setState(() {
            _discountAmount = voucher.discountAmount;
            _appliedVoucherCode = voucher.code;
          });
          _showSnack(
              "Voucher berhasil dipasang! Hemat Rp ${_discountAmount.toInt()}",
              Colors.green);
        }
      }
    } catch (e) {
      _showSnack("Gagal mengecek voucher: $e", Colors.redAccent);
    } finally {
      setState(() => _isValidatingVoucher = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // --- PERHITUNGAN HARGA ---
  int _calculateFinalPrice() {
    final price = (_selectedService?['price'] ?? 0);
    final finalPrice = price - _discountAmount;
    // Harga tidak boleh negatif
    return finalPrice < 0 ? 0 : finalPrice.toInt();
  }

  Future<void> _submitBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final int originalPrice = (_selectedService!['price'] as num).toInt();
    final int finalPrice = _calculateFinalPrice();

    try {
      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user.uid,
        'userName': user.displayName ?? 'Customer', // Simpan nama user juga
        'userEmail': user.email,
        'employeeId': _selectedBarber?.id ?? '', // Simpan ID Barber
        'employeeName': _selectedBarber?.name ?? 'Any Barber',
        'serviceId': _selectedService!['serviceId'],
        'serviceName': _selectedService!['name'],

        // --- HARGA & DISKON ---
        'price': finalPrice, // Field utama yang dipakai history
        'originalPrice': originalPrice,
        'discount': _discountAmount,
        'voucherCode': _appliedVoucherCode,
        // ----------------------

        'duration': _selectedService!['durationInMinutes'] ?? 30,
        'dateTime': Timestamp.fromDate(DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            int.parse(_selectedTimeSlot!.split(":")[0]),
            0)), // Gabungkan tanggal & jam jadi satu Timestamp
        'timeSlot':
            _selectedTimeSlot, // Simpan juga string jam-nya buat display
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      NotificationService.showNotification(
        title: 'Booking Dikonfirmasi! ✅',
        body:
            'Jadwal: ${DateFormat('d MMM').format(_selectedDate)} jam $_selectedTimeSlot.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Berhasil! Cek History.')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainAppScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBgColor,
      appBar: AppBar(
        backgroundColor: mainBgColor,
        elevation: 0,
        title: const Text("Booking Appointment",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            final int minStep = widget.selectedBarber != null ? 1 : 0;
            if (_currentStep > minStep) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          BookingStepper(currentStep: _currentStep + 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: cardColor,
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentYellow,
              foregroundColor: cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isLoading ? null : _handleNextButton,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.black))
                : Text(
                    _currentStep == 2 ? "CONFIRM BOOKING" : "NEXT STEP",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  void _handleNextButton() {
    if (_currentStep == 0) {
      if (_selectedBarber == null) {
        _showSnack("Pilih stylist dulu!", Colors.orange);
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_selectedService == null) {
        _showSnack("Pilih layanan dulu!", Colors.orange);
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_selectedTimeSlot == null) {
        _showSnack("Pilih jam dulu!", Colors.orange);
        return;
      }
      _submitBooking();
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBarberStep();
      case 1:
        return _buildServiceStep();
      case 2:
        return _buildTimeAndSummaryStep();
      default:
        return Container();
    }
  }

  Widget _buildBarberStep() {
    final barbersAsync = ref.watch(barbersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Your Stylist",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 15),
        barbersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Text("Error: $e", style: const TextStyle(color: Colors.white)),
          data: (barbers) => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: barbers.length,
            separatorBuilder: (c, i) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final barber = barbers[index];
              final isSelected = _selectedBarber?.id == barber.id;

              return GestureDetector(
                onTap: () => setState(() => _selectedBarber = barber),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? accentYellow : cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(barber.photoUrl)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(barber.name,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isSelected ? cardColor : Colors.white)),
                            Text(barber.specialty,
                                style: TextStyle(
                                    color: isSelected
                                        ? cardColor.withOpacity(0.7)
                                        : Colors.white70)),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    color:
                                        isSelected ? cardColor : accentYellow,
                                    size: 16),
                                Text(" ${barber.rating}",
                                    style: TextStyle(
                                        color: isSelected
                                            ? cardColor
                                            : Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: cardColor),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceStep() {
    final servicesAsync = ref.watch(servicesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Service",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 15),
        servicesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text("Error: $e"),
          data: (services) => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            separatorBuilder: (c, i) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final service = services[index];
              final isSelected = _selectedService?['name'] == service['name'];

              return GestureDetector(
                onTap: () => setState(() => _selectedService = service),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? accentYellow : cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service['name'],
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? cardColor : Colors.white)),
                          Text(
                              "${service['duration'] ?? 30} min", // Menggunakan 'duration'
                              style: TextStyle(
                                  color: isSelected
                                      ? cardColor.withOpacity(0.7)
                                      : Colors.white70)),
                        ],
                      ),
                      Text("Rp ${service['price']}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isSelected ? cardColor : accentYellow)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeAndSummaryStep() {
    final morningSlots = ["09:00", "10:00", "11:00"];
    final afternoonSlots = ["13:00", "14:00", "15:00", "16:00", "17:00"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- PILIH TANGGAL ---
        const Text("Select Date",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = date.day == _selectedDate.day &&
                  date.month == _selectedDate.month;
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  width: 65,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? accentYellow : cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat('MMM').format(date),
                          style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? cardColor : Colors.white70)),
                      Text(date.day.toString(),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? cardColor : Colors.white)),
                      Text(DateFormat('E').format(date),
                          style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? cardColor : Colors.white70)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 25),

        // --- PILIH JAM ---
        const Text("Available Slots",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...morningSlots.map((time) => _buildTimeChip(time)),
            ...afternoonSlots.map((time) => _buildTimeChip(time)),
          ],
        ),

        const SizedBox(height: 30),
        const Divider(color: Colors.white24),
        const SizedBox(height: 10),

        // --- INPUT VOUCHER (INTEGRATED) ---
        const Text("Promo Code",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _voucherController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter Voucher Code",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: cardColor,
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _isValidatingVoucher ? null : _checkVoucher,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentYellow,
                foregroundColor: cardColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _isValidatingVoucher
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                  : const Text("APPLY"),
            )
          ],
        ),
        if (_appliedVoucherCode != null)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text("Kode $_appliedVoucherCode terpasang!",
                style: const TextStyle(color: Colors.green, fontSize: 12)),
          ),

        const SizedBox(height: 20),

        // --- SUMMARY ---
        const Text("Summary",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: [
              _buildSummaryRow("Stylist", _selectedBarber?.name ?? "-"),
              _buildSummaryRow("Service", _selectedService?['name'] ?? "-"),
              _buildSummaryRow(
                  "Date", DateFormat("d MMM yyyy").format(_selectedDate)),
              _buildSummaryRow("Time", _selectedTimeSlot ?? "-"),

              const Divider(color: Colors.white24),

              // Harga Normal
              _buildSummaryRow(
                  "Service Price", "Rp ${_selectedService?['price'] ?? 0}"),

              // Tampilkan Diskon jika ada
              if (_discountAmount > 0) ...[
                _buildSummaryRow("Voucher ($_appliedVoucherCode)",
                    "- Rp ${_discountAmount.toInt()}",
                    isDiscount: true),
                const Divider(color: Colors.white24),
              ],

              // Harga Akhir
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Final Price",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("Rp ${_calculateFinalPrice()}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: accentYellow,
                          fontSize: 18)),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeChip(String time) {
    final isSelected = _selectedTimeSlot == time;
    return ChoiceChip(
      label: Text(time,
          style: TextStyle(color: isSelected ? cardColor : Colors.white)),
      selected: isSelected,
      selectedColor: accentYellow,
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: isSelected ? accentYellow : Colors.white24)),
      onSelected: (selected) => setState(() => _selectedTimeSlot = time),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDiscount ? Colors.greenAccent : Colors.white)),
        ],
      ),
    );
  }
}
