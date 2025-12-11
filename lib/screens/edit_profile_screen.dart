import 'dart:io'; // Import untuk File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Storage
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:haircut_express/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Variabel untuk foto
  File? _pickedImage; // Foto yang baru dipilih dari galeri
  String? _currentPhotoUrl; // URL foto lama dari internet

  bool _isLoading = false;

  final Color darkBlue = const Color(0xFF24344D);
  final Color accentYellow = const Color(0xFFFFB300);

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();

      setState(() {
        _nameController.text = data?['displayName'] ?? user.displayName ?? '';
        _phoneController.text = data?['phone'] ?? '';
        // Prioritaskan foto dari Auth, jika tidak ada baru ambil dari Firestore
        _currentPhotoUrl = user.photoURL ?? data?['photoUrl'];
      });
    }
  }

  // --- FUNGSI PILIH FOTO ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Buka galeri
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50 // Kompres kualitas agar upload lebih cepat
        );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // --- FUNGSI UPLOAD FOTO ---
  Future<String?> _uploadImage(String userId) async {
    if (_pickedImage == null) return null;

    try {
      // 1. Buat alamat file di Firebase Storage (users/UID.jpg)
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('$userId.jpg');

      // 2. Upload file
      await ref.putFile(_pickedImage!);

      // 3. Ambil URL download agar bisa disimpan di database
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String? newPhotoUrl = _currentPhotoUrl;

      // 1. Jika ada foto baru dipilih, upload dulu
      if (_pickedImage != null) {
        newPhotoUrl = await _uploadImage(user.uid);
      }

      // 2. Update Profil di Auth Firebase (Nama & Foto)
      if (newPhotoUrl != null) {
        await user.updatePhotoURL(newPhotoUrl);
      }
      await user.updateDisplayName(_nameController.text.trim());

      // 3. Update data lengkap di Firestore Database
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'photoUrl': newPhotoUrl, // Simpan URL foto
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 4. Update state lokal via Riverpod (jika perlu)
      await ref.read(authControllerProvider).updateProfile(
            _nameController.text.trim(),
            _phoneController.text.trim(),
          );

      if (!mounted) return;
      Navigator.pop(context); // Kembali ke halaman profil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- AREA FOTO PROFIL ---
            GestureDetector(
              onTap: _pickImage, // Klik untuk ganti foto
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: accentYellow,
                    // Logika tampilan: Foto Baru > Foto Lama > Icon Default
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!) as ImageProvider
                        : (_currentPhotoUrl != null &&
                                _currentPhotoUrl!.isNotEmpty
                            ? NetworkImage(_currentPhotoUrl!)
                            : null),
                    child: (_pickedImage == null &&
                            (_currentPhotoUrl == null ||
                                _currentPhotoUrl!.isEmpty))
                        ? const Icon(Icons.person,
                            size: 60, color: Colors.black)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 20, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- INPUT NAMA ---
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.person, color: accentYellow),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentYellow)),
              ),
            ),
            const SizedBox(height: 20),

            // --- INPUT HP ---
            TextField(
              controller: _phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'No. Handphone',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.phone, color: accentYellow),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentYellow)),
              ),
            ),
            const SizedBox(height: 40),

            // --- TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentYellow,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2))
                    : const Text('SIMPAN PERUBAHAN',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
