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
      child: const Icon(Icons.person_add, color: Colors.white),
      tooltip: 'Hasta Ekle',
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
    
    // 1. Overlay bildirim göster - Daha belirgin ve uzun süreli
    NotificationOverlay.show(
      context: context,
      title: 'Yeni Hasta Eklendi',
      message: '$hastaAdi: $sikayet',
      icon: Icons.person_add,
      backgroundColor: const Color(0xFF00BCD4),
      duration: const Duration(seconds: 4), // Daha uzun süre görünsün
      onTap: () {
        // Bildirime tıklandığında yeni eklenen hastayı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$hastaAdi başarıyla eklendi!')),
        );
      },
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
        'HGB': 10,
        'WBC': 5500,
        'PLT': 180000,
        'MCV': 65,
        'Kreatinin': 0.7,
        'Üre': 20,
        'ALT': 30,
        'AST': 25,
        'GGT': 10,
        'Amilaz': 40,
        'Lipaz': 25,
        'Direkt_bilirubin': 0.7,
        'İndirekt_bilirubin': 0.3,
        'Sodyum': 136,
        'Potasyum': 4,
        'Kalsiyum': 9,
        'Demir': 30,
        'Demir_baglama_kapasitesi': 300,
        'Ferritin': 12,
        'B12_vitamini': 350,
        'Folat': 5,
        'Vitamin_D3': 25,
        'Tam_idrar_tetkiki': 'Normal',
        'APTT': 30,
        'INR': 1
      };
      
      // Önceki tetkik sonuçları - Elif Demir formatında (her zaman dolu olacak)
      final Map<String, dynamic> oncekiTetkik = {
        'HGB': 9.8,
        'WBC': 5200,
        'PLT': 175000,
        'MCV': 64,
        'Kreatinin': 0.65,
        'Üre': 18,
        'ALT': 28,
        'AST': 22,
        'GGT': 9,
        'Amilaz': 38,
        'Lipaz': 22,
        'Direkt_bilirubin': 0.6,
        'İndirekt_bilirubin': 0.25,
        'Sodyum': 135,
        'Potasyum': 3.8,
        'Kalsiyum': 8.8,
        'Demir': 28,
        'Demir_baglama_kapasitesi': 290,
        'Ferritin': 10,
        'B12_vitamini': 340,
        'Folat': 4.8,
        'Vitamin_D3': 22,
        'Tam_idrar_tetkiki': 'Normal',
        'APTT': 29,
        'INR': 0.9
      };
      
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
      final String oncekiGoruntuleme = goruntulemeSecenekleri[(random + 1) % goruntulemeSecenekleri.length]; // Her zaman bir önceki görüntüleme olacak
      
      // Önceki başvurular - her zaman var olacak
      final int oncekiBasvuruSayisi = 1 + (random % 5); // 1-5 arası, en az 1 önceki başvuru
      final String oncekiBasvurular = 'var, son ${random % 12 + 1} ayda $oncekiBasvuruSayisi kez başvurmuş';
      
      // Tedavi bilgileri - her zaman önceki tedavi olacak
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
      final String oncekiTedavi = tedaviSecenekleri[random % tedaviSecenekleri.length];
      
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
      
      // Kronik hastalıklar, ilaçlar ve alerjiler
      final List<String> kronikHastaliklar = [
        'Diyabet',
        'Hipertansiyon',
        'Astım',
        'KOAH',
        'Koroner Arter Hastalığı',
        'Hipotiroidi',
        'Epilepsi',
        'Romatoid Artrit',
        'Osteoporoz',
        'Kronik Böbrek Hastalığı'
      ];
      
      final List<String> surekliIlaclar = [
        'Metformin 1000mg 2x1',
        'Enalapril 10mg 1x1',
        'Salbutamol inh. 2x1',
        'Tiotropium inh. 1x1',
        'ASA 100mg 1x1',
        'Levotiroksin 50mcg 1x1',
        'Levetirasetam 500mg 2x1',
        'Metotreksat 15mg/hafta',
        'Alendronat 70mg/hafta',
        'Furosemid 40mg 1x1'
      ];
      
      final List<String> alerjiler = [
        'Penisilin',
        'Sulfonamidler',
        'NSAİİ',
        'Kontrast madde',
        'Latex',
        'Polen',
        'Arı sokması',
        'Fındık',
        'Deniz ürünleri',
        'Yumurta'
      ];
      
      // Aile öyküsü ve sosyal bilgiler
      final List<String> aileOykusu = [
        'Babada diyabet',
        'Annede hipertansiyon',
        'Kardeşte astım',
        'Babada koroner arter hastalığı',
        'Annede meme kanseri',
        'Ailede erken yaşta kalp hastalığı öyküsü',
        'Ailede kolon kanseri öyküsü',
        'Ailede inme öyküsü',
        'Ailede diyabet öyküsü',
        'Ailede tiroid hastalığı öyküsü'
      ];
      
      final List<String> meslekler = [
        'Öğretmen',
        'Mühendis',
        'Doktor',
        'Hemşire',
        'Avukat',
        'Muhasebeci',
        'İşçi',
        'Memur',
        'Emekli',
        'Serbest meslek'
      ];
      
      final List<String> medeniDurum = [
        'Evli',
        'Bekar',
        'Boşanmış',
        'Dul'
      ];
      
      final List<String> sigaraKullanimi = [
        'Yok',
        'Günde 1 paket, 10 yıldır',
        'Günde 2 paket, 20 yıldır',
        'Bırakmış, 5 yıl önce',
        'Pasif içici'
      ];
      
      final List<String> alkolKullanimi = [
        'Yok',
        'Sosyal içici',
        'Haftada 1-2 kez',
        'Her gün'
      ];
      
      final List<String> maddeKullanimi = [
        'Yok',
        'Esrar, ara sıra',
        'Kokain, geçmişte',
        'Eroin, tedavi görüyor'
      ];
      
      // Rastgele seçimler
      final String kronikHastalik = random % 3 == 0 ? kronikHastaliklar[random % kronikHastaliklar.length] : 'Yok';
      final String surekliIlac = random % 3 == 0 ? surekliIlaclar[random % surekliIlaclar.length] : 'Yok';
      final String alerji = random % 5 == 0 ? alerjiler[random % alerjiler.length] : 'Yok';
      final String aile = random % 2 == 0 ? aileOykusu[random % aileOykusu.length] : 'Yok';
      final String meslek = meslekler[random % meslekler.length];
      final String medeni = medeniDurum[random % medeniDurum.length];
      final String sigara = sigaraKullanimi[random % sigaraKullanimi.length];
      final String alkol = alkolKullanimi[random % alkolKullanimi.length];
      final String madde = maddeKullanimi[0]; // Genellikle "Yok" olsun
      
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
        'kronik_hastaliklar': kronikHastalik,
        'surekli_ilaclar': surekliIlac,
        'alerjiler': alerji,
        'aile_oykusu': aile,
        'meslek': meslek,
        'medeni_durum': medeni,
        'sigara_kullanimi': sigara,
        'alkol_kullanimi': alkol,
        'madde_kullanimi': madde,
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
