import 'package:flutter/material.dart';
import 'package:akilli_doktor_asistani/services/auth_service.dart';
import 'package:akilli_doktor_asistani/screens/home_screen.dart' show HomeScreen;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:akilli_doktor_asistani/screens/qr_scanner_screen.dart';
import 'package:akilli_doktor_asistani/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _errorMessage;
  
  // Context kullanımını ayrı fonksiyonlara taşıyarak async gap sorununu çözüyoruz
  void _navigateToHome(dynamic user) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(user: user),
      ),
    );
  }
  
  void _showResetPasswordSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              AppTheme.primaryLightColor.withAlpha(76), // 0.3 opaklık yerine alfa değeri (0.3 * 255 = 76)
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ve Başlık
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      child: Column(
                        children: [
                          // Logo
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryLightColor.withAlpha(76), // 0.3 * 255 = 76
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withAlpha(51), // 0.2 * 255 = 51
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/saglik_bakanligi_logo.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.local_hospital,
                                size: 60,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Akıllı Doktor Asistanı',
                            style: AppTheme.headingStyle.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontSize: 26,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                  
                          // Error message
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withAlpha(26), // 0.1 * 255 = 26
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.errorColor.withAlpha(76)), // 0.3 * 255 = 76
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppTheme.errorColor),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: AppTheme.errorColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Login Form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _idController,
                                  decoration: InputDecoration(
                                    labelText: 'TC Kimlik No / Hastane ID',
                                    prefixIcon: const Icon(Icons.person, color: AppTheme.primaryColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
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
                                    prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
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
                                    style: AppTheme.primaryButtonStyle,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(color: Colors.white),
                                          )
                                        : const Text('Giriş Yap', style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Alternatif giriş yöntemleri
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (!kIsWeb)
                            _buildLoginOption(
                              icon: Icons.fingerprint,
                              label: 'Biyometrik',
                              onTap: _handleBiometricLogin,
                            ),
                          _buildLoginOption(
                            icon: Icons.qr_code,
                            label: 'QR Kod',
                            onTap: _handleQRLogin,
                          ),
                          _buildLoginOption(
                            icon: Icons.help_outline,
                            label: 'Şifremi Unuttum',
                            onTap: _handleForgotPassword,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Footer
                  Text(
                    '© ${DateTime.now().year} Akıllı Doktor Asistanı',
                    style: AppTheme.smallStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Alternatif giriş seçeneği widgeti
  Widget _buildLoginOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryLightColor.withAlpha(51), // 0.2 * 255 = 51
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTheme.smallStyle.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        final result = await _authService.login(
          _idController.text,
          _passwordController.text,
        );
        
        if (result['success']) {
          if (mounted) {
            _navigateToHome(result['user']);
          }
        } else {
          setState(() {
            _errorMessage = result['message'];
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Giriş sırasında bir hata oluştu: ${e.toString()}';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final result = await _authService.biometricLogin();
      
      if (result['success']) {
        if (mounted) {
          _navigateToHome(result['user']);
        }
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Biyometrik giriş sırasında bir hata oluştu: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleQRLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          onScan: (qrData) async {
            Navigator.of(context).pop();
            
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
            
            try {
              // Handle QR login logic
              // For demonstration, we'll just use the QR data as the user ID
              final result = await _authService.login(qrData, 'qrpassword');
              
              if (result['success']) {
                if (mounted) {
                  _navigateToHome(result['user']);
                }
              } else {
                setState(() {
                  _errorMessage = 'Geçersiz QR kodu';
                });
              }
            } catch (e) {
              setState(() {
                _errorMessage = 'QR giriş sırasında bir hata oluştu: ${e.toString()}';
              });
            } finally {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            }
          },
        ),
      ),
    );
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifremi Unuttum'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('TC Kimlik No veya Hastane ID\'nizi girin:'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'TC Kimlik No / Hastane ID',
              ),
              controller: _idController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              if (_idController.text.isNotEmpty) {
                setState(() {
                  _isLoading = true;
                });
                
                final result = await _authService.resetPassword(_idController.text);
                
                setState(() {
                  _isLoading = false;
                  _errorMessage = result['success'] 
                      ? null 
                      : result['message'];
                });
                
                if (result['success'] && mounted) {
                  _showResetPasswordSuccess(result['message']);
                }
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }
}
