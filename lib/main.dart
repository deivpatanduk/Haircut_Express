import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/data_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_app_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase (Web & Mobile)
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'Haircut Express',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          // 1. BACKGROUND: Set warna background global (Biru Tua)
          scaffoldBackgroundColor: const Color(0xFF1B263B),
          
          // 2. TEXT: Warna teks default jadi putih agar kontras
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
            bodyLarge: TextStyle(color: Colors.white),
          ),
          
          // 3. APPBAR: Warna AppBar global
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1B263B),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          
          // 4. NAVBAR: Warna BottomNavigationBar global (Penyebab error sebelumnya)
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF24344D),
            selectedItemColor: Color(0xFFFFA500),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        // Wrapper untuk cek login status
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.currentUser != null) {
              return const MainAppScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}