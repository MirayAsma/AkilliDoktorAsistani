import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const HospitalApp());
}

class HospitalApp extends StatelessWidget {
  const HospitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akıllı Doktor Asistanı',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.light(
          primary: Color(0xFF1976D2),
          secondary: Color(0xFF26A69A),
          background: Colors.white,
        ),
        textTheme: GoogleFonts.rubikTextTheme(),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF1976D2),
          secondary: Color(0xFF26A69A),
          background: Color(0xFF121212),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isDarkMode = false;
  bool _isLoading = false;
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _idController,
                          decoration: InputDecoration(
                            labelText: 'TC Kimlik No / Hastane ID',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bu alan zorunludur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bu alan zorunludur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Giriş Yap'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _handleForgotPassword,
                        child: const Text('Şifremi Unuttum'),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.fingerprint),
                            onPressed: _handleBiometricLogin,
                            tooltip: 'Biyometrik Giriş',
                          ),
                          IconButton(
                            icon: const Icon(Icons.qr_code),
                            onPressed: _handleQRLogin,
                            tooltip: 'QR Kod ile Giriş',
                          ),
                          IconButton(
                            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                            onPressed: _toggleTheme,
                            tooltip: 'Tema Değiştir',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      // Simüle edilmiş giriş gecikmesi
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() => _isLoading = false);
      // TODO: Implement actual login logic
    }
  }

  Future<void> _handleBiometricLogin() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      if (canAuthenticateWithBiometrics) {
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Giriş yapmak için biyometrik doğrulama kullanın',
        );
        if (didAuthenticate) {
          // TODO: Implement biometric login logic
        }
      }
    } catch (e) {
      // Handle errors
    }
  }

  void _handleQRLogin() {
    // TODO: Implement QR login logic
  }

  void _handleForgotPassword() {
    // TODO: Implement forgot password logic
  }

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
    // TODO: Implement theme persistence
  }
}
