import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/barber.dart';
import '../models/service_model.dart';
import '../models/appointment_model.dart';

class BookingProvider with ChangeNotifier {
  // State Tahapan Booking
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // State Data Pilihan
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  ServiceModel? _selectedService;
  Barber? _selectedBarber;
  
  bool _isLoading = false;

  // Getters
  DateTime get selectedDate => _selectedDate;
  String? get selectedTimeSlot => _selectedTimeSlot;
  ServiceModel? get selectedService => _selectedService;
  Barber? get selectedBarber => _selectedBarber;
  bool get isLoading => _isLoading;

  // --- Step Navigation Logic ---
  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  // --- Selection Logic ---
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void selectTimeSlot(String time) {
    _selectedTimeSlot = time;
    notifyListeners();
  }

  void selectService(ServiceModel service) {
    _selectedService = service;
    notifyListeners();
  }

  void selectBarber(Barber barber) {
    _selectedBarber = barber;
    notifyListeners();
  }

  // Reset Booking
  void clearBooking() {
    _currentStep = 0;
    _selectedDate = DateTime.now();
    _selectedTimeSlot = null;
    _selectedService = null;
    _selectedBarber = null;
    notifyListeners();
  }

  // --- Core Logic: Save to Firebase ---
  Future<bool> confirmBooking(String userName) async {
    if (_selectedBarber == null || _selectedService == null || _selectedTimeSlot == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final timeParts = _selectedTimeSlot!.split(':');
      final finalDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final docRef = FirebaseFirestore.instance.collection('appointments').doc();

      final newAppointment = AppointmentModel(
        appointmentId: docRef.id,
        userId: user.uid,
        userName: userName,
        employeeId: _selectedBarber!.id,
        employeeName: _selectedBarber!.name,
        serviceId: _selectedService!.id,
        serviceName: _selectedService!.name,
        dateTime: finalDateTime,
        price: _selectedService!.price,
        status: 'pending',
      );

      await docRef.set(newAppointment.toMap());

      clearBooking();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error booking: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}