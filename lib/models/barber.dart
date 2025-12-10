class Barber {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final String photoUrl;

  Barber({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.photoUrl,
  });

  // Factory Method untuk convert dari Firestore
  factory Barber.fromMap(Map<String, dynamic> data, String docId) {
    return Barber(
      id: docId,
      name: data['name'] ?? 'Unknown',
      specialty: data['specialty'] ?? 'General',
      rating: (data['rating'] ?? 5.0).toDouble(),
      photoUrl: data['photoUrl'] ?? 'https://i.pravatar.cc/150', // Default image
    );
  }
}