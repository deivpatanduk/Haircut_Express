import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DbSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Data Layanan (Services) sesuai Proposal
  final List<Map<String, dynamic>> _services = [
    {
      'name': 'Premium Haircut',
      'price': 80000,
      'durationInMinutes': 45,
      'description': 'Potongan detail + cuci rambut + styling pomade.',
    },
    {
      'name': 'Kids Haircut',
      'price': 70000,
      'durationInMinutes': 30,
      'description': 'Potongan ramah anak dengan penanganan sabar.',
    },
    {
      'name': 'Basic Cut',
      'price': 70000,
      'durationInMinutes': 30,
      'description': 'Potongan rapi standar tanpa cuci rambut.',
    },
    {
      'name': 'Hot Towel Shave',
      'price': 60000,
      'durationInMinutes': 30,
      'description': 'Cukur jenggot bersih dengan handuk hangat.',
    },
    {
      'name': 'Hair Coloring',
      'price': 150000,
      'durationInMinutes': 90,
      'description': 'Pewarnaan rambut profesional (Hitam / Fashion).',
    },
  ];

  // Data Stylist (Employees) sesuai Proposal
  final List<Map<String, dynamic>> _employees = [
    {
      'name': 'Budi Santoso',
      'specialty': 'Classic Cut',
      'rating': 4.8,
      'photoUrl': 'https://i.pravatar.cc/150?u=budi', // Gambar dummy
    },
    {
      'name': 'Andi Pratama',
      'specialty': 'Fade & Modern',
      'rating': 4.9,
      'photoUrl': 'https://i.pravatar.cc/150?u=andi',
    },
    {
      'name': 'Siti Aminah',
      'specialty': 'Kids & Coloring',
      'rating': 4.7,
      'photoUrl': 'https://i.pravatar.cc/150?u=siti',
    },
  ];

  // FUNGSI UTAMA: Menjalankan Seeding
  Future<void> seedDatabase(BuildContext context) async {
    try {
      // 1. Seed Services
      // Cek dulu agar tidak duplikat (opsional, tapi bagus untuk safety)
      var serviceSnapshot = await _db.collection('services').get();
      if (serviceSnapshot.docs.isEmpty) {
        for (var service in _services) {
          await _db.collection('services').add(service);
        }
        print('✅ Data Services Berhasil Ditambahkan!');
      } else {
        print('ℹ️ Data Services sudah ada, melewati proses ini.');
      }

      // 2. Seed Employees
      var empSnapshot = await _db.collection('employees').get();
      if (empSnapshot.docs.isEmpty) {
        for (var emp in _employees) {
          await _db.collection('employees').add(emp);
        }
        print('✅ Data Employees Berhasil Ditambahkan!');
      } else {
        print('ℹ️ Data Employees sudah ada, melewati proses ini.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database berhasil diisi (Seeding Completed)!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error Seeding: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengisi database: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}