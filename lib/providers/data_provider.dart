import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/barber.dart';
import '../models/service_model.dart';
import '../models/appointment_model.dart';

class DataProvider with ChangeNotifier {
  List<Barber> _barbers = [];
  List<ServiceModel> _services = [];
  List<AppointmentModel> _userAppointments = [];
  
  bool _isLoading = false;

  List<Barber> get barbers => _barbers;
  List<ServiceModel> get services => _services;
  List<AppointmentModel> get userAppointments => _userAppointments;
  bool get isLoading => _isLoading;

  // Fetch Data Awal (Barber & Service)
  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final barberSnapshot = await FirebaseFirestore.instance.collection('employees').get();
      _barbers = barberSnapshot.docs.map((doc) {
        return Barber.fromMap(doc.data(), doc.id);
      }).toList();

      final serviceSnapshot = await FirebaseFirestore.instance.collection('services').get();
      _services = serviceSnapshot.docs.map((doc) {
        return ServiceModel.fromMap(doc.data(), doc.id);
      }).toList();

    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch History Booking User
  Future<void> fetchUserAppointments(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          // .orderBy('dateTime', descending: true) // Aktifkan nanti jika sudah buat Index di Firebase
          .get();

      _userAppointments = querySnapshot.docs.map((doc) {
        return AppointmentModel.fromMap(doc.data(), doc.id);
      }).toList();
      
      notifyListeners(); 
    } catch (e) {
      print("Error fetching appointments: $e"); 
    }
  }
}