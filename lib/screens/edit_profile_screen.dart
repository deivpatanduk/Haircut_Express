import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haircut_express/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  final Color darkBlue = const Color(0xFF24344D); // Sesuaikan tema
  final Color accentYellow = const Color(0xFFFFB300);

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      setState(() {
        _nameController.text = data?['displayName'] ?? user.displayName ?? '';
        _phoneController.text = data?['phone'] ?? '';
      });
    }
  }

  void _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider).updateProfile(
        _nameController.text.trim(),
        _phoneController.text.trim(),
      );
      
      if (!mounted) return;
      Navigator.pop(context); // Kembali ke profil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.person, color: accentYellow),
                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentYellow)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'No. Handphone',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.phone, color: accentYellow),
                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentYellow)),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentYellow,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text('SIMPAN PERUBAHAN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}