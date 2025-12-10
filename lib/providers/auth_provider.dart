import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Provider untuk memantau status Login User (Stream)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// 2. Controller untuk menangani logika Login/Register/Logout
class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi Register
  Future<void> register(String email, String password, String name, String phone) async {
    try {
      // 1. Buat akun di Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Simpan data tambahan ke Firestore (Sesuai Proposal)
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'displayName': name,
          'phone': phone,
          'role': 'pelanggan', // Default role
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Update display name di Auth profile juga
        await userCredential.user!.updateDisplayName(name);
      }
    } catch (e) {
      throw e;
    }
  }

  // Fungsi Login
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e;
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}

// 3. Provider untuk mengakses AuthController
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});