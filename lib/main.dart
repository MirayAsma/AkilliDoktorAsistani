import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:akilli_doktor_asistani/screens/login_screen.dart';
import 'package:akilli_doktor_asistani/screens/home_screen.dart';
import 'package:akilli_doktor_asistani/services/auth_service.dart';
import 'package:akilli_doktor_asistani/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print('Firebase zaten başlatıldı veya hata oluştu: '
        '[33m$e[0m');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // Kullanıcı oturumunu kontrol edip bilgilerini getiren fonksiyon
  Future<Map<String, dynamic>?> _checkUserAndGetData() async {
    try {
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();
      
      if (isLoggedIn) {
        // Kullanıcı giriş yapmışsa bilgilerini getir
        final userData = await authService.getCurrentUser();
        
        // Kullanıcı verileri geçerli mi kontrol et
        if (userData != null && userData.containsKey('id') && userData.containsKey('name')) {
          // Kullanıcı oturumu aktif
          return userData;
        } else {
          // Kullanıcı verileri eksik veya geçersiz
          // Oturumu temizle ve giriş ekranına yönlendir
          await authService.logout();
          return null;
        }
      } else {
        // Aktif kullanıcı oturumu bulunamadı
        // Kullanıcı giriş yapmamışsa null döndür
        return null;
      }
    } catch (e) {
      // Hata durumunda sessizce null döndür
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akıllı Doktor Asistanı',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      home: FutureBuilder<Map<String, dynamic>?>(
        future: _checkUserAndGetData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.local_hospital,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Akıllı Doktor Asistanı',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const CircularProgressIndicator(color: AppTheme.primaryColor),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            // Kullanıcı oturumu varsa ve bilgileri alındıysa HomeScreen'e yönlendir
            return HomeScreen(user: snapshot.data!);
          } else {
            // Kullanıcı oturumu yoksa LoginScreen'e yönlendir
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
