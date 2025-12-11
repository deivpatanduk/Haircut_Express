import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haircut_express/providers/auth_provider.dart';
import 'package:haircut_express/screens/login_screen.dart';
import 'package:haircut_express/screens/main_app_screen.dart';
import 'package:haircut_express/screens/admin/admin_dashboard_screen.dart'; // Import Admin Screen
import 'package:haircut_express/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    // Inisialisasi Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCfRN7PQDXSLUhfDQHwDqOGgkw6ahCPVds", 
        authDomain: "haircut-express-c8307.firebaseapp.com",
        projectId: "haircut-express-c8307",
        storageBucket: "haircut-express-c8307.firebasestorage.app",
        messagingSenderId: "821057101080",
        appId: "1:821057101080:web:28a5abce84e2b802cc126d",
        measurementId: "G-PVHN02FB0J"
      ),
    );
 } else {
    await Firebase.initializeApp();
  }

  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: HaircutExpressApp(),
    ),
  );
}

class HaircutExpressApp extends ConsumerWidget { // <-- Typo cclass diperbaiki menjadi class
  const HaircutExpressApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau ROLE user secara real-time
    final roleAsync = ref.watch(userRoleProvider);

    return MaterialApp(
      title: 'Haircut Express',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
      ),
      home: roleAsync.when(
        data: (role) {
          // Debugging: Cetak role ke konsol biar tahu
          print("Current User Role: $role");

          if (role == 'admin') {
            return const AdminDashboardScreen();
          } else if (role == 'pelanggan') {
            return const MainAppScreen();
          } else {
            // Guest atau belum login
            return const LoginScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, trace) => Scaffold(
          body: Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}