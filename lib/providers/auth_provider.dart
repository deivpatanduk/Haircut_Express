import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

// 1. Provider Auth State
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// 2. Provider Role Checker (PENTING UNTUK ADMIN)
final userRoleProvider = StreamProvider<String>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value('guest');
      }
      // Dengarkan perubahan dokumen user secara real-time
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return 'pelanggan'; // Default jika data belum ada
            return (doc.data()?['role'] ?? 'pelanggan').toString().toLowerCase(); // Pastikan lowercase
          });
    },
    loading: () => Stream.value('guest'), 
    error: (_, __) => Stream.value('guest'),
  );
});

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // REGISTER
  Future<void> register(String email, String password, String name, String phone) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'displayName': name,
          'phone': phone,
          'role': 'pelanggan',
          'createdAt': FieldValue.serverTimestamp(),
        });
        await userCredential.user!.updateDisplayName(name);
      }
    } catch (e) { throw e; }
  }

  // LOGIN
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // GOOGLE LOGIN (DIPERBAIKI)
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Cek apakah dokumen user sudah ada?
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        
        if (!userDoc.exists) {
          // Hanya buat baru jika BELUM ADA. Jangan timpa role admin!
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'uid': userCredential.user!.uid,
            'email': userCredential.user!.email,
            'displayName': userCredential.user!.displayName,
            'phone': '',
            'role': 'pelanggan', // Default user baru
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      throw Exception('Google Sign In Failed: $e');
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // UPDATE PROFILE
  Future<void> updateProfile(String newName, String newPhone) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': newName,
        'phone': newPhone,
      });
      await user.updateDisplayName(newName);
      await user.reload(); 
    }
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});