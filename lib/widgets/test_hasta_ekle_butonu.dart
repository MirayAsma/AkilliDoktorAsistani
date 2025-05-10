import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../widgets/notification_overlay.dart';

/// Test amaçlı hasta ekleme butonu
class TestHastaEkleButonu extends StatelessWidget {
  final NotificationService _notificationService = NotificationService();
  
  TestHastaEkleButonu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.person_add, color: Colors.white),
      tooltip: 'Test Hasta Ekle',
      onPressed: () => showTestNotification(context),
    );
  }

  /// Test bildirimi göster ve hasta ekle
  void showTestNotification(BuildContext context) {
    // Rastgele hasta bilgileri
    final hastaAdlari = [
      'Ahmet Yılmaz',
      'Ayşe Kaya',
      'Mehmet Demir',
      'Fatma Çelik',
      'Ali Öztürk'
    ];
    
    final sikayetler = [
      'Baş ağrısı, ateş',
      'Karın ağrısı',
      'Sırt ağrısı, öksürük',
      'Halsizlik, yorgunluk',
      'Baş dönmesi, bulantı'
    ];
    
    // Rastgele hasta ve şikayet seç
    final random = DateTime.now().millisecond % 5;
    final hastaAdi = hastaAdlari[random];
    final sikayet = sikayetler[random];
    
    // 1. Overlay bildirim göster
    NotificationOverlay.show(
      context: context,
      title: 'Yeni Test Hasta Eklendi',
      message: '$hastaAdi: $sikayet',
      icon: Icons.person_add,
      backgroundColor: const Color(0xFF00BCD4),
    );
    
    // 2. Bildirim servisine ekle
    _notificationService.addNotification(
      title: 'Yeni Test Hasta',
      body: '$hastaAdi: $sikayet',
      data: {'patient_id': 'test_${DateTime.now().millisecondsSinceEpoch}'},
    );
    
    // 3. Firestore'a ekle
    addTestPatientToFirestore(hastaAdi, sikayet);
  }
  
  /// Test hastasını Firestore'a ekle
  Future<void> addTestPatientToFirestore(String hastaAdi, String sikayet) async {
    try {
      // Rastgele değerler oluştur
      final random = DateTime.now().millisecond;
      final yas = 25 + (random % 40); // 25-64 arası yaş
      
      // Rastgele laboratuvar değerleri
      final Map<String, dynamic> labDegerleri = {
        'HGB': 10 + (random % 6), // 10-15 arası
        'WBC': 4000 + (random % 8000), // 4000-12000 arası
        'PLT': 150000 + (random % 300000), // 150000-450000 arası
        'Kreatinin': (0.6 + (random % 15) / 10).toStringAsFixed(1), // 0.6-2.1 arası
        'Glukoz': 70 + (random % 150), // 70-220 arası
      };
      
      // Rastgele cinsiyet
      final cinsiyet = random % 2 == 0 ? 'Erkek' : 'Kadın';
      
      // Rastgele vital bulgular
      final tansiyon = '${110 + (random % 60)}/${70 + (random % 30)}';
      final nabiz = 60 + (random % 40); // 60-100 arası
      final ates = (36.0 + (random % 20) / 10).toStringAsFixed(1); // 36.0-38.0 arası
      
      // Detaylı hasta verilerini oluştur
      await FirebaseFirestore.instance.collection('cases').add({
        'ad_soyad': hastaAdi,
        'basvuru_sikayeti': sikayet,
        'yas': yas,
        'cinsiyet': cinsiyet,
        'son_lab_tetkik': labDegerleri,
        'tansiyon': tansiyon,
        'nabiz': nabiz,
        'ates': ates,
        'onceki_tedavi': random % 3 == 0 ? 'Parasetamol, 3x1' : null,
        'uyari': random % 5 == 0 ? 'Penisilin alerjisi mevcut' : null,
        'timestamp': FieldValue.serverTimestamp(),
        'test_data': true, // Bu bir test verisi olduğunu belirt
      });
      
      debugPrint('Test hastası Firestore\'a eklendi: $hastaAdi');
    } catch (e) {
      debugPrint('Firestore\'a test hastası eklenirken hata: $e');
      // Hata olsa bile bildirim gösterildi, sorun yok
    }
  }
}
