import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../widgets/notification_overlay.dart';
import 'notification_service.dart';

/// Basitleştirilmiş hasta bildirim servisi - sadece uygulama içi bildirimler için
class PatientNotificationService {
  static final PatientNotificationService _instance = PatientNotificationService._internal();
  factory PatientNotificationService() => _instance;
  PatientNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  
  // Son alınan hasta ID'lerini takip etmek için
  final Set<String> _processedPatientIds = {};
  StreamSubscription<QuerySnapshot>? _subscription;
  
  // Bildirim servisini başlat
  Future<void> init() async {
    // Notification service'i başlat
    await _notificationService.init();
    
    // Callback fonksiyonunu ayarla
    _notificationService.onShowNotification = _showOverlayNotification;
    
    // Firestore'dan hasta verilerini dinle
    _listenToNewPatients();
    
    return Future.value();
  }
  
  // Overlay bildirim göster
  void _showOverlayNotification(BuildContext context, String title, String message) {
    NotificationOverlay.show(
      context: context,
      title: title,
      message: message,
      icon: Icons.health_and_safety,
      backgroundColor: const Color(0xFF00BCD4),
    );
  }
  
  // Yeni hasta raporlarını dinle
  void _listenToNewPatients() {
    try {
      // Önce mevcut hastaları işaretle
      _firestore.collection('cases').get().then((snapshot) {
        for (var doc in snapshot.docs) {
          _processedPatientIds.add(doc.id);
        }
        
        // Şimdi yeni gelen hastaları dinle
        _subscription = _firestore.collection('cases')
            .snapshots()
            .listen(_handlePatientsSnapshot);
      });
    } catch (e) {
      debugPrint('Firestore dinleme hatası: $e');
    }
  }
  
  // Firestore snapshot'ını işle
  void _handlePatientsSnapshot(QuerySnapshot snapshot) {
    for (var change in snapshot.docChanges) {
      // Sadece yeni eklenen hastaları kontrol et
      if (change.type == DocumentChangeType.added) {
        final String patientId = change.doc.id;
        
        // Bu hastayı daha önce işlemedik mi?
        if (!_processedPatientIds.contains(patientId)) {
          _processedPatientIds.add(patientId);
          
          // Hasta verilerini al
          final data = change.doc.data() as Map<String, dynamic>?;
          if (data != null) {
            _showNewPatientNotification(patientId, data);
          }
        }
      }
    }
  }
  
  // Yeni hasta bildirimi göster
  void _showNewPatientNotification(String patientId, Map<String, dynamic> patientData) {
    final String patientName = patientData['ad_soyad'] ?? 'Yeni Hasta';
    final String complaint = patientData['basvuru_sikayeti'] ?? 'Yeni rapor';
    
    // Bildirim servisi aracılığıyla bildirim gönder
    _notificationService.addNotification(
      title: 'Yeni Hasta Raporu',
      body: '$patientName: $complaint',
      data: {'patient_id': patientId},
    );
  }
  
  // Uygulama içi bildirim göster (overlay)
  void showInAppNotification(BuildContext context, String patientId, Map<String, dynamic> patientData) {
    final String patientName = patientData['ad_soyad'] ?? 'Yeni Hasta';
    final String complaint = patientData['basvuru_sikayeti'] ?? 'Yeni rapor';
    
    NotificationOverlay.show(
      context: context,
      title: 'Yeni Hasta Raporu',
      message: '$patientName: $complaint',
      icon: Icons.person_add,
      onTap: () {
        // Hasta detay sayfasına yönlendir
        // Navigator.push(...);
      },
    );
  }
  
  // Servis durdurulduğunda aboneliği iptal et
  void dispose() {
    _subscription?.cancel();
  }
}
