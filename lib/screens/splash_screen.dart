import 'package:flutter/material.dart';
import 'package:akilli_doktor_asistani/screens/login_screen.dart';
import 'package:akilli_doktor_asistani/screens/home_screen.dart' show HomeScreen;
import 'package:akilli_doktor_asistani/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    final isLoggedIn = await _authService.isLoggedIn();
    if (!mounted) return;
    
    if (isLoggedIn) {
      final user = await _authService.getCurrentUser();
      if (!mounted) return;
      _navigateToHome(user!);
    } else {
      _navigateToLogin();
    }
  }
  
  // Context kullanımını ayrı fonksiyonlara taşıyarak async gap sorununu çözüyoruz
  void _navigateToHome(dynamic user) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
    );
  }
  
  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(26),
              Theme.of(context).colorScheme.secondary.withAlpha(26),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withAlpha(26),
                  ),
                  child: Icon(
                    Icons.local_hospital,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Akıllı Doktor Asistanı',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
