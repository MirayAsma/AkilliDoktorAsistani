import 'package:flutter/material.dart';
import 'dart:async';

/// Basitleştirilmiş bildirim servisi - sadece uygulama içi bildirimler için
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final StreamController<Map<String, dynamic>> _notificationStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Map<String, dynamic>> get notificationStream => _notificationStreamController.stream;
  
  /// Callback fonksiyonu - bildirim gösterildiğinde çağrılır
  Function(BuildContext context, String title, String message)? onShowNotification;
  
  /// Bildirim servisini başlat
  Future<void> init() async {
    // Basit başlatma işlemleri
    debugPrint('Bildirim servisi başlatıldı');
  }
  
  /// Yeni bir bildirim gönder
  void addNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    // Bildirim stream'ine gönder
    _notificationStreamController.add({
      'type': 'notification',
      'title': title,
      'body': body,
      'data': data ?? {},
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  /// Bildirim göster (overlay widget kullanır)
  void showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    BuildContext? context,
  }) {
    // Bildirim stream'ine gönder
    addNotification(title: title, body: body, data: data);
    
    // Eğer context ve callback varsa, bildirimi göster
    if (context != null && onShowNotification != null) {
      onShowNotification!(context, title, body);
    }
  }
  
  // Bildirim kanalını temizle
  void dispose() {
    _notificationStreamController.close();
  }
}
