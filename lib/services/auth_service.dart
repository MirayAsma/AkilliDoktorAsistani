import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FlutterSecureStorage _secureStorage = kIsWeb
      ? const FlutterSecureStorage(webOptions: WebOptions(dbName: 'akilli_doktor_storage'))
      : const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  static const String _userKey = 'user_data';
  static const String _credentialsKey = 'credentials';

  // Mock user data for demonstration
  final Map<String, Map<String, dynamic>> _mockUsers = {
    '12345678901': {
      'password': 'password123',
      'name': 'Dr. İdris Baydar',
      'role': 'doctor',
      'department': 'Dahiliye',
    },
    '98765432109': {
      'password': 'password456',
      'name': 'Hemşire Ayşe Kaya',
      'role': 'nurse',
      'department': 'Dahiliye',
    },
    'admin': {
      'password': 'admin123',
      'name': 'Admin Kullanıcı',
      'role': 'admin',
      'department': 'Yönetim',
    },
  };

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final userData = await _secureStorage.read(key: _userKey);
      if (userData != null && userData.isNotEmpty) {
        // Kullanıcı verilerini JSON olarak parse etmeyi dene
        final userMap = jsonDecode(userData);
        // Geçerli bir kullanıcı verisi olduğunu kontrol et
        return userMap != null && userMap.containsKey('id');
      }
      return false;
    } catch (e) {
      // Hata durumunda false döndür
      // Oturum kontrolü sırasında hata
      return false;
    }
  }

  // Login with ID and password
  Future<Map<String, dynamic>> login(String id, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Check if user exists
    if (_mockUsers.containsKey(id)) {
      final user = _mockUsers[id]!;
      
      // Check password
      if (user['password'] == password) {
        // Store user data securely
        final userData = {
          'id': id,
          ...user,
        };
        
        await _secureStorage.write(
          key: _userKey,
          value: jsonEncode(userData),
        );
        
        // Store credentials for biometric login
        await _secureStorage.write(
          key: _credentialsKey,
          value: jsonEncode({
            'id': id,
            'password': password,
          }),
        );
        
        return {
          'success': true,
          'user': userData,
        };
      }
    }
    
    return {
      'success': false,
      'message': 'Geçersiz kimlik numarası veya şifre',
    };
  }

  // Biometric login
  Future<Map<String, dynamic>> biometricLogin() async {
    // Web platformunda biyometrik kimlik doğrulama desteklenmiyor
    if (kIsWeb) {
      return {
        'success': false,
        'message': 'Web tarayıcıda biyometrik doğrulama desteklenmiyor.',
      };
    }
    
    try {
      // Check if device supports biometrics
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = canCheckBiometrics || await _localAuth.isDeviceSupported();
      
      if (!canAuthenticate) {
        return {
          'success': false,
          'message': 'Bu cihaz biyometrik doğrulamayı desteklemiyor',
        };
      }
      
      // Check if we have stored credentials
      final credentialsString = await _secureStorage.read(key: _credentialsKey);
      if (credentialsString == null) {
        return {
          'success': false,
          'message': 'Önce normal giriş yapmalısınız',
        };
      }
      
      // Authenticate with biometrics
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Giriş yapmak için biyometrik doğrulama kullanın',
      );
      
      if (didAuthenticate) {
        // Get stored credentials and login
        final credentials = jsonDecode(credentialsString);
        return await login(credentials['id'], credentials['password']);
      } else {
        return {
          'success': false,
          'message': 'Biyometrik doğrulama başarısız',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Biyometrik doğrulama sırasında bir hata oluştu: ${e.toString()}',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await _secureStorage.delete(key: _userKey);
  }

  // Get current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userData = await _secureStorage.read(key: _userKey);
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Reset password (mock implementation)
  Future<Map<String, dynamic>> resetPassword(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (_mockUsers.containsKey(id)) {
      return {
        'success': true,
        'message': 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi',
      };
    }
    
    return {
      'success': false,
      'message': 'Bu kimlik numarasına sahip bir kullanıcı bulunamadı',
    };
  }
}
