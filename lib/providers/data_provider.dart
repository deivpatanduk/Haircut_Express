import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haircut_express/models/barber.dart';
import 'package:haircut_express/models/voucher_model.dart'; // Pastikan import model

// 1. Provider untuk mengambil daftar Stylist/Barber secara Real-time
final barbersProvider = StreamProvider<List<Barber>>((ref) {
  return FirebaseFirestore.instance
      .collection('employees')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();

      return Barber(
        id: doc.id,
        name: data['name'] ?? 'Tanpa Nama',
        specialty: data['specialty'] ?? 'General',
        rating: (data['rating'] ?? 0.0).toDouble(),
        photoUrl: data['photoUrl'] ?? 'https://i.pravatar.cc/150',
      );
    }).toList();
  });
});

// 2. Provider untuk mengambil daftar Services (Layanan)
final servicesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('services')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['serviceId'] = doc.id;
      return data;
    }).toList();
  });
});

// ... imports

// 3. Provider untuk mengambil Booking milik User yang sedang login
final userBookingsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('appointments')
      .where('userId', isEqualTo: user.uid)
      // Tambahkan sort agar booking terbaru muncul di atas
      .orderBy('dateTime', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // <--- PENTING: Tambahkan ID dokumen ke Map
      return data;
    }).toList();
  });
});

// ... provider lainnya

// 4. [ADMIN] Provider untuk mengambil SEMUA Booking (Dashboard Admin)
final adminAllBookingsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('appointments')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Simpan ID dokumen agar admin bisa update status
      return data;
    }).toList();
  });
});

// 5. Provider untuk mengambil daftar Voucher (Admin)
final vouchersProvider = StreamProvider<List<VoucherModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('vouchers')
      .orderBy('expiryDate', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return VoucherModel.fromMap(doc.data(), doc.id);
    }).toList();
  });
});
