import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../widgets/notification_overlay.dart';

/// Test amaçlı bildirim gönderme butonu
class TestBildirimButonu extends StatelessWidget {
  final NotificationService _notificationService = NotificationService();
  
  TestBildirimButonu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF00BCD4),
      onPressed: () => _showTestNotification(context),
      child: const Icon(Icons.notifications_active, color: Colors.white),
      tooltip: 'Test Bildirimi Gönder',
    );
  }

  /// Test bildirimi göster
  void _showTestNotification(BuildContext context) {
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
      title: 'Yeni Hasta Raporu',
      message: '$hastaAdi: $sikayet',
      icon: Icons.person_add,
      backgroundColor: const Color(0xFF00BCD4),
    );
    
    // 2. Bildirim servisine ekle
    _notificationService.addNotification(
      title: 'Yeni Hasta Raporu',
      body: '$hastaAdi: $sikayet',
      data: {'patient_id': 'test_${DateTime.now().millisecondsSinceEpoch}'},
    );
    
    // 3. Opsiyonel: Gerçekten Firestore'a eklemek için
    _addTestPatientToFirestore(hastaAdi, sikayet);
  }
  
  /// Test hastasını Firestore'a ekle - Elif Demir formatında
  Future<void> _addTestPatientToFirestore(String hastaAdi, String sikayet) async {
    try {
      // Belge ID'si oluştur
      final String documentId = 'test_${DateTime.now().millisecondsSinceEpoch}';
      
      // Rastgele değerler oluştur
      final random = DateTime.now().millisecond;
      final yas = 25 + (random % 50); // 25-74 arası yaş
      
      // Rastgele cinsiyet
      final cinsiyet = random % 2 == 0 ? 'Erkek' : 'Kadın';
      
      // Son laboratuvar tetkik sonuçları - Elif Demir formatında
      final Map<String, dynamic> sonLabTetkik = {
        'HGB': (9 + (random % 7)).toDouble(), // 9-15 arası
        'WBC': 4000 + (random % 8000), // 4000-12000 arası
        'PLT': 150000 + (random % 300000), // 150000-450000 arası
        'MCV': 65 + (random % 35), // 65-100 arası
        'Kreatinin': (0.6 + (random % 15) / 10).toDouble(), // 0.6-2.1 arası
        'Üre': 15 + (random % 40), // 15-55 arası
        'ALT': 10 + (random % 60), // 10-70 arası
        'AST': 10 + (random % 60), // 10-70 arası
        'GGT': 10 + (random % 60), // 10-70 arası
        'Amilaz': 20 + (random % 80), // 20-100 arası
        'Lipaz': 15 + (random % 65), // 15-80 arası
        'Direkt_bilirubin': (0.1 + (random % 20) / 10).toDouble(), // 0.1-2.1 arası
        'İndirekt_bilirubin': (0.2 + (random % 10) / 10).toDouble(), // 0.2-1.2 arası
        'Sodyum': 130 + (random % 15), // 130-145 arası
        'Potasyum': (3.5 + (random % 15) / 10).toDouble(), // 3.5-5.0 arası
        'Kalsiyum': (8.5 + (random % 15) / 10).toDouble(), // 8.5-10.0 arası
        'Demir': 20 + (random % 140), // 20-160 arası
        'Demir_baglama_kapasitesi': 240 + (random % 160), // 240-400 arası
        'Ferritin': 10 + (random % 290), // 10-300 arası
        'B12_vitamini': 150 + (random % 650), // 150-800 arası
        'Folat': 3 + (random % 14), // 3-17 arası
        'Vitamin_D3': 10 + (random % 60), // 10-70 arası
        'Tam_idrar_tetkiki': random % 4 == 0 ? 'Lökosit (+), Eritrosit (+)' : 
                             random % 4 == 1 ? 'Protein (+)' : 
                             random % 4 == 2 ? 'Lökosit (+)' : 'Normal',
        'APTT': 25 + (random % 10), // 25-35 arası
        'INR': (0.8 + (random % 8) / 10).toDouble(), // 0.8-1.6 arası
      };
      
      // Önceki tetkik sonuçları - Elif Demir formatında
      final Map<String, dynamic> oncekiTetkik = {};
      
      // Önceki değerleri biraz farklı oluştur
      sonLabTetkik.forEach((key, value) {
        if (value is int) {
          oncekiTetkik[key] = value + (random % 2 == 0 ? (random % 20) : -(random % 20));
        } else if (value is double) {
          oncekiTetkik[key] = (value + (random % 2 == 0 ? (random % 10) / 10 : -(random % 10) / 10)).toDouble();
        } else {
          oncekiTetkik[key] = value;
        }
      });
      
      // Görüntüleme sonuçları
      final List<String> goruntulemeSecenekleri = [
        'Ayakta direkt batin grafisinde batin icinde yaygin gaz',
        'Akciger grafisinde sag alt lobda infiltrasyon',
        'Kranial BT normal',
        'Batin USG normal, karaciger normal boyutlarda',
        'Toraks BT normal',
        'Batin MR normal',
        'Normal sinus grafisi',
      ];
      final String sonGoruntuleme = goruntulemeSecenekleri[random % goruntulemeSecenekleri.length];
      final String oncekiGoruntuleme = random % 3 == 0 ? goruntulemeSecenekleri[random % goruntulemeSecenekleri.length] : 'yok';
      
      // Önceki başvurular
      final int oncekiBasvuruSayisi = random % 6; // 0-5 arası
      final String oncekiBasvurular = oncekiBasvuruSayisi > 0 ? 
                                     'var, son ${random % 12 + 1} ayda $oncekiBasvuruSayisi kez başvurmuş' : 'yok';
      
      // Tedavi bilgileri
      final List<String> tedaviSecenekleri = [
        'Parasetamol, 3x1',
        'Amoksisilin+klavulanat, 2x1',
        'Metoklopramid, 3x1',
        'Pantoprazol, 1x1',
        'Oral duphalac',
        'Metformin 2x1',
        'Enalapril 1x1',
        'Furosemid 1x1',
        'Atorvastatin 1x1',
        'Levotiroksin 1x1',
      ];
      final String oncekiTedavi = oncekiBasvuruSayisi > 0 ? 
                                 tedaviSecenekleri[random % tedaviSecenekleri.length] : 'yok';
      
      // Ameliyat, patoloji ve doğum öyküsü
      String ameliyat = 'yok';
      if (random % 10 == 0) {
        ameliyat = random % 2 == 0 ? 'apendektomi' : 'kolesistektomi';
        if (cinsiyet == 'Kadın' && random % 3 == 0) {
          ameliyat += ', sezeryan';
        }
      }
      
      String patoloji = 'yok';
      if (random % 10 == 0) {
        patoloji = 'benign sitoloji';
      }
      
      String dogumOykusu = 'yok';
      if (cinsiyet == 'Kadın' && random % 5 == 0) {
        dogumOykusu = '${random % 3 + 1} sağlıklı doğum';
      }
      
      // Vital bulgular
      final String tansiyon = '${100 + (random % 60)}/${60 + (random % 30)} mmHg';
      final int nabiz = 60 + (random % 60); // 60-120 arası
      final double ates = 36.0 + (random % 25) / 10; // 36.0-38.5 arası
      
      // Uyarı
      final List<String> uyariSecenekleri = [
        'Immunosupresif hasta',
        'Organ nakli oykusu mevcut',
        'Kanama diyatezi mevcut',
        'Gebelik suphesi',
        'Bulaşıcı hastalik (Hepatit B)',
        'Bulaşıcı hastalik (Hepatit C)',
        'Bulaşıcı hastalik (HIV)',
        'Malignite oykusu mevcut',
        'Yakın zamanda operasyon gecirmis',
        'Yakın zamanda hastane yatisi',
      ];
      final String uyari = random % 10 == 0 ? uyariSecenekleri[random % uyariSecenekleri.length] : 'yok';
      
      // Hasta verilerini Elif Demir formatına uygun olarak oluştur
      await FirebaseFirestore.instance.collection('cases').doc(documentId).set({
        'ad_soyad': hastaAdi,
        'yas': yas,
        'cinsiyet': cinsiyet,
        'basvuru_sikayeti': sikayet,
        'son_lab_tetkik': sonLabTetkik,
        'son_goruntuleme': sonGoruntuleme,
        'onceki_basvurular': oncekiBasvurular,
        'onceki_tetkik': oncekiTetkik,
        'onceki_goruntuleme': oncekiGoruntuleme,
        'ameliyat': ameliyat,
        'patoloji': patoloji,
        'dogum_oykusu': dogumOykusu,
        'tansiyon': tansiyon,
        'nabiz': nabiz,
        'ates': ates,
        'onceki_tedavi': oncekiTedavi,
        'uyari': uyari,
        'timestamp': FieldValue.serverTimestamp(),
        'test_data': true, // Bu bir test verisi olduğunu belirt
      });
      
      debugPrint('Detaylı test hastası Firestore\'a eklendi: $hastaAdi');
    } catch (e) {
      debugPrint('Firestore\'a test hastası eklenirken hata: $e');
      // Hata olsa bile bildirim gösterildi, sorun yok
    }
  }
}
