import 'package:flutter/material.dart';
import 'booking_screen.dart';
import 'components/booking_stepper.dart';
import 'components/calendar_widget.dart';
import 'confirmation_screen.dart';

import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http; // <<< PERBAIKAN IMPORT HTTP

const String googleApiKey = "AIzaSyAyzk9foZ4M9PA0lmWe-3tt7NAchWL1Lfs";
const String barberCalendarId = 'primary';
// ...

class ScheduleScreen extends StatefulWidget {
  final Barber selectedBarber;

  const ScheduleScreen({super.key, required this.selectedBarber});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final Color darkBlue = const Color(0xFF1B263B);
  final Color mediumBlue = const Color(0xFF233044);
  final Color accentYellow = const Color(0xFFFFA500);

  String? _selectedDate;
  String? _selectedTimeSlot;

  // Variabel baru untuk menyimpan event API yang dimuat
  List<calendar.Event> _loadedEvents = [];
  // Status loading API
  bool _isLoadingEvents = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = '5';
    // Panggil API saat halaman dimuat pertama kali untuk tanggal default (tanggal 5)
    _loadEventsForCurrentDate();
  }

  // Fungsi untuk memanggil API
  Future<List<calendar.Event>> fetchCalendarEvents(DateTime day) async {
    final client = auth.clientViaApiKey(googleApiKey);
    final calendarService = calendar.CalendarApi(client);

    // Tentukan rentang waktu untuk hari yang dipilih
    final DateTime timeMin = DateTime(day.year, day.month, day.day, 0, 0, 0);
    final DateTime timeMax = timeMin.add(const Duration(days: 1));

    try {
      final eventsList = await calendarService.events.list(
        barberCalendarId,
        timeMin: timeMin,
        timeMax: timeMax,
        singleEvents: true,
        orderBy: 'startTime',
      );

      client.close();
      return eventsList.items ?? [];
    } catch (e) {
      client.close();
      print('Error fetching calendar events: $e');
      return [];
    }
  }

  // Fungsi wrapper untuk memuat event dan mengupdate state
  void _loadEventsForCurrentDate() async {
    if (_selectedDate == null) return;

    // Simulasikan konversi '5' menjadi DateTime (asumsi bulan Desember)
    // Dalam aplikasi nyata, Anda akan menggunakan objek DateTime yang sebenarnya
    final today = DateTime.now();
    final targetDate = DateTime(
      today.year,
      today.month,
      int.parse(_selectedDate!),
    );

    setState(() {
      _isLoadingEvents = true;
      _loadedEvents = [];
    });

    final events = await fetchCalendarEvents(targetDate);

    setState(() {
      _loadedEvents = events;
      _isLoadingEvents = false;
    });
  }

  void _handleDateSelection(String date) {
    setState(() {
      _selectedDate = date;
    });
    // Panggil API setiap kali tanggal berubah
    _loadEventsForCurrentDate();
  }

  void _handleTimeSelection(String time) {
    setState(() {
      _selectedTimeSlot = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isContinueEnabled =
        _selectedDate != null && _selectedTimeSlot != null;

    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Booking: ${widget.selectedBarber.name}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 16.0,
              ),
              child: BookingStepper(currentStep: 2),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Pilih Tanggal & Waktu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
              child: Text(
                'Tentukan jadwal appointment Anda',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),

            CalendarWidget(
              selectedDate: _selectedDate,
              selectedTimeSlot: _selectedTimeSlot,
              onDateSelected: _handleDateSelection,
              onTimeSelected: _handleTimeSelection,
            ),

            // >>> OUTPUT DARI API KALENDER (Jadwal Sibuk) <<<
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Jadwal Sibuk (API Status):',
                style: TextStyle(
                  color: accentYellow,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (_isLoadingEvents)
              Center(child: CircularProgressIndicator(color: accentYellow))
            else if (_loadedEvents.isNotEmpty)
              ..._loadedEvents
                  .map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 4.0,
                      ),
                      child: Text(
                        'SIBUK: ${event.summary ?? "Event"} (${event.start?.dateTime?.hour}:${event.start?.dateTime?.minute} - ${event.end?.dateTime?.hour}:${event.end?.dateTime?.minute})',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList()
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Tidak ada event sibuk yang dimuat untuk tanggal ini. (API Terhubung)",
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: _buildContinueButton(context, isContinueEnabled),
    );
  }

  Widget _buildContinueButton(BuildContext context, bool isEnabled) {
    return Container(
      color: darkBlue,
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmationScreen(
                      selectedBarber: widget.selectedBarber,
                      selectedDate: _selectedDate!,
                      selectedTime: _selectedTimeSlot!,
                    ),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentYellow,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Lanjutkan ke Konfirmasi',
          style: TextStyle(
            fontSize: 18,
            color: isEnabled ? darkBlue : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
