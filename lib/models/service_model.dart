class ServiceModel {
  final String id;
  final String name;
  final double price;
  final int duration; // dalam menit

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
  });

  // Factory untuk mengubah data dari Firestore (Map) ke Object Dart
  factory ServiceModel.fromMap(Map<String, dynamic> data, String docId) {
    return ServiceModel(
      id: docId,
      name: data['name'] ?? 'Unknown Service',
      price: (data['price'] ?? 0).toDouble(),
      duration: data['durationInMinutes'] ?? 30, // Default 30 menit jika null
    );
  }
}