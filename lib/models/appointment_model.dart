import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String appointmentId;
  final String userId;
  final String userName;
  final String employeeId;
  final String employeeName;
  final String serviceId;
  final String serviceName;
  final DateTime dateTime;
  final double price;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'

  AppointmentModel({
    required this.appointmentId,
    required this.userId,
    required this.userName,
    required this.employeeId,
    required this.employeeName,
    required this.serviceId,
    required this.serviceName,
    required this.dateTime,
    required this.price,
    this.status = 'pending',
  });

  // Konversi ke Map untuk disimpan di Firebase
  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'userId': userId,
      'userName': userName,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'dateTime': Timestamp.fromDate(dateTime), // Simpan sebagai Timestamp
      'price': price,
      'status': status,
    };
  }

  // Factory untuk membaca dari Firebase (LEBIH AMAN)
  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    
    // 1. Handle Tanggal (Bisa Timestamp atau String)
    DateTime parsedDate = DateTime.now();
    if (map['dateTime'] != null) {
      if (map['dateTime'] is Timestamp) {
        parsedDate = (map['dateTime'] as Timestamp).toDate();
      } else if (map['dateTime'] is String) {
        parsedDate = DateTime.tryParse(map['dateTime']) ?? DateTime.now();
      }
    }

    // 2. Handle Harga (Bisa Int, Double, atau String)
    double parsedPrice = 0.0;
    if (map['price'] != null) {
      if (map['price'] is num) {
        parsedPrice = (map['price'] as num).toDouble();
      } else if (map['price'] is String) {
        parsedPrice = double.tryParse(map['price']) ?? 0.0;
      }
    }

    return AppointmentModel(
      appointmentId: id,
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? 'Guest',
      employeeId: map['employeeId']?.toString() ?? '',
      employeeName: map['employeeName']?.toString() ?? 'Unknown Stylist',
      serviceId: map['serviceId']?.toString() ?? '',
      serviceName: map['serviceName']?.toString() ?? 'Unknown Service',
      dateTime: parsedDate,
      price: parsedPrice,
      status: map['status']?.toString() ?? 'pending',
    );
  }
}