import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haircut_express/providers/auth_provider.dart';
import 'package:haircut_express/screens/login_screen.dart';
import 'package:haircut_express/screens/main_app_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- LOGIKA INISIALISASI FIREBASE (WEB & ANDROID) ---
  if (kIsWeb) {
    // JIKA DIJALANKAN DI WEB (CHROME/EDGE)
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        // SALIN DARI FIREBASE CONSOLE ANDA:
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
    // JIKA DIJALANKAN DI ANDROID/IOS (Otomatis pakai google-services.json)
    await Firebase.initializeApp();
  }
  // ----------------------------------------------------

  runApp(
    const ProviderScope(
      child: HaircutExpressApp(),
    ),
  );
}

class HaircutExpressApp extends ConsumerWidget {
  const HaircutExpressApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Haircut Express',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
      ),
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const MainAppScreen();
          }
          return const LoginScreen();
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