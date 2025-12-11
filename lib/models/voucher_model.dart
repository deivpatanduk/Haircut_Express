import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String code; // Contoh: "DISKON10"
  final double discountAmount; // Contoh: 10000
  final DateTime expiryDate; // Tanggal kadaluarsa

  VoucherModel({
    required this.id,
    required this.code,
    required this.discountAmount,
    required this.expiryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discountAmount': discountAmount,
      'expiryDate': Timestamp.fromDate(expiryDate),
    };
  }

  factory VoucherModel.fromMap(Map<String, dynamic> map, String id) {
    return VoucherModel(
      id: id,
      code: map['code'] ?? '',
      discountAmount: (map['discountAmount'] ?? 0).toDouble(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
    );
  }
}
