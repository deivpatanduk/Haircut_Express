import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:haircut_express/models/barber.dart';
import 'package:haircut_express/components/barber_card.dart';
import 'package:haircut_express/components/booking_stepper.dart';
import 'package:haircut_express/providers/data_provider.dart';
import 'package:haircut_express/services/notification_service.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Barber? selectedBarber;

  const BookingScreen({super.key, this.selectedBarber});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  // STATE LOKAL
  int _currentStep = 0; 
  Barber? _selectedBarber;
  Map<String, dynamic>? _selectedService;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  bool _isLoading = false;

  // WARNA TEMA
  final Color mainBgColor = const Color(0xFF24344D);
  final Color cardColor = const Color(0xFF1B263B);
  final Color accentYellow = const Color(0xFFFFB300);

  @override
  void initState() {
    super.initState();
    if (widget.selectedBarber != null) {
      _selectedBarber = widget.selectedBarber;
      _currentStep = 1; 
    }
  }

  Future<void> _submitBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user.uid,
        'userEmail': user.email,
        'barberName': _selectedBarber?.name ?? 'Any Barber',
        'serviceName': _selectedService!['name'],
        'servicePrice': _selectedService!['price'],
        'duration': _selectedService!['durationInMinutes'],
        'bookingDate': Timestamp.fromDate(_selectedDate),
        'timeSlot': _selectedTimeSlot,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      
      NotificationService.showNotification(
        title: 'Booking Dikonfirmasi! ✅',
        body: 'Jadwal: ${DateFormat('d MMM').format(_selectedDate)} jam $_selectedTimeSlot.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Berhasil! Cek History.')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
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
        title: const Text("Booking Appointment", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentStep > 0 && widget.selectedBarber == null) {
              setState(() => _currentStep--);
            } else if (_currentStep > 1 && widget.selectedBarber != null) {
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isLoading ? null : _handleNextButton,
            child: _isLoading
                ? const CircularProgressIndicator()
                : Text(
                    _currentStep == 2 ? "CONFIRM BOOKING" : "NEXT STEP",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  void _handleNextButton() {
    if (_currentStep == 0) {
      if (_selectedBarber == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih stylist dulu!")));
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_selectedService == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih layanan dulu!")));
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_selectedTimeSlot == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih jam dulu!")));
        return;
      }
      _submitBooking();
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildBarberStep();
      case 1: return _buildServiceStep();
      case 2: return _buildTimeAndSummaryStep();
      default: return Container();
    }
  }

  Widget _buildBarberStep() {
    final barbersAsync = ref.watch(barbersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Your Stylist", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 15),
        barbersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text("Error: $e", style: const TextStyle(color: Colors.white)),
          data: (barbers) => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: barbers.length,
            separatorBuilder: (c, i) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final barber = barbers[index];
              final isSelected = _selectedBarber?.name == barber.name;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedBarber = barber),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? accentYellow : cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 30, backgroundImage: NetworkImage(barber.photoUrl)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(barber.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? cardColor : Colors.white)),
                            Text(barber.specialty, style: TextStyle(color: isSelected ? cardColor.withOpacity(0.7) : Colors.white70)),
                            Row(
                              children: [
                                Icon(Icons.star, color: isSelected ? cardColor : accentYellow, size: 16),
                                Text(" ${barber.rating}", style: TextStyle(color: isSelected ? cardColor : Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),
                      if (isSelected) Icon(Icons.check_circle, color: cardColor),
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
        const Text("Select Service", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
              final isSelected = _selectedService == service;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedService = service),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? accentYellow : cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? cardColor : Colors.white)),
                          Text("${service['durationInMinutes']} min", style: TextStyle(color: isSelected ? cardColor.withOpacity(0.7) : Colors.white70)),
                        ],
                      ),
                      Text("Rp ${service['price']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? cardColor : accentYellow)),
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
        const Text("Select Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  width: 65,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? accentYellow : cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat('MMM').format(date), style: TextStyle(fontSize: 12, color: isSelected ? cardColor : Colors.white70)),
                      Text(date.day.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? cardColor : Colors.white)),
                      Text(DateFormat('E').format(date), style: TextStyle(fontSize: 12, color: isSelected ? cardColor : Colors.white70)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 25),
        const Text("Available Slots", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
        
        const Text("Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
              _buildSummaryRow("Date", DateFormat("d MMM yyyy").format(_selectedDate)),
              _buildSummaryRow("Time", _selectedTimeSlot ?? "-"),
              const Divider(color: Colors.white24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Price", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("Rp ${_selectedService?['price'] ?? 0}", style: TextStyle(fontWeight: FontWeight.bold, color: accentYellow, fontSize: 16)),
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
      label: Text(time, style: TextStyle(color: isSelected ? cardColor : Colors.white)),
      selected: isSelected,
      selectedColor: accentYellow,
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), 
        side: BorderSide(color: isSelected ? accentYellow : Colors.white24)
      ),
      onSelected: (selected) => setState(() => _selectedTimeSlot = time),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
        ],
      ),
    );
  }
}