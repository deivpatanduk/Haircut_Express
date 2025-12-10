import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/booking_provider.dart';
import '../providers/data_provider.dart';
import '../providers/auth_provider.dart';
import '../components/booking_stepper.dart';

class BookingScreen extends StatefulWidget {
  // Hapus const jika menyebabkan masalah di parent, tapi biasanya aman
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  
  @override
  void initState() {
    super.initState();
    // Pastikan data ter-load saat layar dibuka
    Future.microtask(() => 
      Provider.of<DataProvider>(context, listen: false).fetchAllData()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, booking, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          // Tombol back manual di AppBar agar bisa mundur step
          appBar: AppBar(
            title: const Text("Booking Appointment", style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                if (booking.currentStep > 0) {
                  booking.previousStep();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          body: Column(
            children: [
              BookingStepper(currentStep: booking.currentStep),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildStepContent(context, booking),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: booking.isLoading ? null : () => _handleNextButton(context, booking),
                child: booking.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        booking.currentStep == 2 ? "Confirm Booking" : "Next Step",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleNextButton(BuildContext context, BookingProvider booking) async {
    if (booking.currentStep == 0) {
      if (booking.selectedBarber == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a stylist!")));
        return;
      }
      booking.nextStep();
    } else if (booking.currentStep == 1) {
      if (booking.selectedService == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a service!")));
        return;
      }
      booking.nextStep();
    } else if (booking.currentStep == 2) {
      if (booking.selectedTimeSlot == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a time slot!")));
        return;
      }
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      bool success = await booking.confirmBooking(user?.displayName ?? 'Guest');
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking Confirmed!")));
        Navigator.popUntil(context, (route) => route.isFirst);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking Failed.")));
      }
    }
  }

  Widget _buildStepContent(BuildContext context, BookingProvider booking) {
    switch (booking.currentStep) {
      case 0:
        return _buildBarberStep(context, booking);
      case 1:
        return _buildServiceStep(context, booking);
      case 2:
        return _buildTimeAndSummaryStep(booking);
      default:
        return Container();
    }
  }

  // STEP 1: PILIH BARBER
  Widget _buildBarberStep(BuildContext context, BookingProvider booking) {
    final dataProvider = Provider.of<DataProvider>(context);
    
    if (dataProvider.isLoading) return const Center(child: CircularProgressIndicator());
    if (dataProvider.barbers.isEmpty) return const Center(child: Text("No stylists available"));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Your Stylist", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dataProvider.barbers.length,
          separatorBuilder: (c, i) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final barber = dataProvider.barbers[index];
            final isSelected = booking.selectedBarber?.id == barber.id;
            
            return GestureDetector(
              onTap: () => booking.selectBarber(barber),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(barber.photoUrl),
                      onBackgroundImageError: (_,__) => const Icon(Icons.person),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(barber.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                          Text(barber.specialty, style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey)),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              Text(" ${barber.rating}", style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, color: Colors.white),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // STEP 2: PILIH SERVICE
  Widget _buildServiceStep(BuildContext context, BookingProvider booking) {
    final dataProvider = Provider.of<DataProvider>(context);

    if (dataProvider.isLoading) return const Center(child: CircularProgressIndicator());
    if (dataProvider.services.isEmpty) return const Center(child: Text("No services available"));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Service", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dataProvider.services.length,
          separatorBuilder: (c, i) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final service = dataProvider.services[index];
            // Fix: Menggunakan .id untuk komparasi karena objek bisa berbeda referensi
            final isSelected = booking.selectedService?.id == service.id;
            
            return GestureDetector(
              onTap: () => booking.selectService(service), // Kirim ServiceModel, bukan Map
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[50] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("${service.duration} min", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Text("Rp ${service.price.toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[800])),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // STEP 3: TANGGAL & SUMMARY
  Widget _buildTimeAndSummaryStep(BookingProvider booking) {
    final morningSlots = ["09:00", "10:00", "11:00"];
    final afternoonSlots = ["13:00", "14:00", "15:00", "16:00", "17:00"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = date.day == booking.selectedDate.day && date.month == booking.selectedDate.month;
              return GestureDetector(
                onTap: () => booking.selectDate(date),
                child: Container(
                  width: 65,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat('MMM').format(date), style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : Colors.grey)),
                      Text(date.day.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                      Text(DateFormat('E').format(date), style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 25),
        const Text("Available Slots", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...morningSlots.map((time) => _buildTimeChip(time, booking)),
            ...afternoonSlots.map((time) => _buildTimeChip(time, booking)),
          ],
        ),

        const SizedBox(height: 30),
        const Divider(thickness: 1),
        const SizedBox(height: 10),
        
        const Text("Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSummaryRow("Stylist", booking.selectedBarber?.name ?? "-"),
              _buildSummaryRow("Service", booking.selectedService?.name ?? "-"),
              _buildSummaryRow("Date", DateFormat("d MMM yyyy").format(booking.selectedDate)),
              _buildSummaryRow("Time", booking.selectedTimeSlot ?? "-"),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Price", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Rp ${booking.selectedService?.price.toStringAsFixed(0) ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeChip(String time, BookingProvider booking) {
    final isSelected = booking.selectedTimeSlot == time;
    return ChoiceChip(
      label: Text(time, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
      selected: isSelected,
      selectedColor: Colors.black,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? Colors.black : Colors.grey.shade300)),
      onSelected: (selected) => booking.selectTimeSlot(time),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}