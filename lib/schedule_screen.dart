import 'package:flutter/material.dart';
import 'booking_screen.dart';
import 'components/booking_stepper.dart';
import 'components/calendar_widget.dart';
import 'confirmation_screen.dart';

// IMPORTS API BARU
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

// KONSTANTA API ANDA (WAJIB DIGANTI)
const String googleApiKey = "AIzaSyAyzk9foZ4M9PA0lmWe-3tt7NAchWL1Lfs";
const String barberCalendarId = 'deiv.patanduk13@gmail.com';

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

  List<calendar.Event> _loadedEvents = [];
  bool _isLoadingEvents = false;

  // --- FUNGSI FETCH API ---
  Future<List<calendar.Event>> fetchCalendarEvents(DateTime day) async {
    final client = auth.clientViaApiKey(googleApiKey);
    final calendarService = calendar.CalendarApi(client);

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

  // --- LOGIKA UTAMA STATE & EVENT LOADING ---
  @override
  void initState() {
    super.initState();
    _selectedDate = '5';
    _loadEventsForCurrentDate();
  }

  void _loadEventsForCurrentDate() async {
    if (_selectedDate == null) return;

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
    _loadEventsForCurrentDate();
  }

  void _handleTimeSelection(String time) {
    setState(() {
      _selectedTimeSlot = time;
    });
  }

  // --- BUILD METHOD ---
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

            // TAMPILAN API DI FRONTEND
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Jadwal Sibuk (Status Koneksi API):',
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
              ..._loadedEvents.map(
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
            // Hapus .toList() di sini untuk menghilangkan warning
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Tidak ada event sibuk. (API berhasil dihubungkan)",
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
