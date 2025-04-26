import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrService {
  // Generate a QR code for login
  static Widget generateLoginQR(String userId) {
    final loginData = {
      'type': 'login',
      'userId': userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    final jsonData = jsonEncode(loginData);
    
    return QrImageView(
      data: jsonData,
      version: QrVersions.auto,
      size: 200.0,
      backgroundColor: Colors.white,
    );
  }
  
  // Parse QR code data for login
  static Map<String, dynamic>? parseLoginQR(String qrData) {
    try {
      final data = jsonDecode(qrData);
      
      if (data['type'] == 'login') {
        // Check if QR code is expired (valid for 5 minutes)
        final timestamp = data['timestamp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;
        final diff = now - timestamp;
        
        if (diff > 5 * 60 * 1000) {
          return {
            'success': false,
            'message': 'QR kodu süresi dolmuş',
          };
        }
        
        return {
          'success': true,
          'userId': data['userId'],
        };
      }
      
      return {
        'success': false,
        'message': 'Geçersiz QR kodu',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'QR kodu ayrıştırılamadı',
      };
    }
  }
}
