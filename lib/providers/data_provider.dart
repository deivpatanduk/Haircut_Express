import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haircut_express/models/barber.dart';

// 1. Ambil data Stylist
final barbersProvider = StreamProvider<List<Barber>>((ref) {
  return FirebaseFirestore.instance.collection('employees').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Barber(
        name: data['name'] ?? 'Tanpa Nama',
        specialty: data['specialty'] ?? 'General',
        rating: (data['rating'] ?? 0.0).toDouble(),
        photoUrl: data['photoUrl'] ?? 'https://i.pravatar.cc/150',
      );
    }).toList();
  });
});

// 2. Ambil data Services
final servicesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance.collection('services').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['serviceId'] = doc.id; 
      return data;
    }).toList();
  });
});

// 3. (BARU) Ambil Booking User untuk Statistik
final userBookingsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) return Stream.value([]); 

  return FirebaseFirestore.instance
      .collection('appointments')
      .where('userId', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});