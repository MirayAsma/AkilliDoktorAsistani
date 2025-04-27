import 'package:cloud_firestore/cloud_firestore.dart';

// Tüm verileri silip yeniden yükleyen fonksiyon
void tumVerileriSilVeYukle() async {
  try {
    // Önce tüm verileri sil
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('cases').get();
    
    // Her dokümanı sil
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
      // print('${doc.id} silindi!');
    }
    
    // print('Tüm veriler silindi, şimdi yeniden yükleniyor...');
    
    // Sonra yeni verileri ekle
    topluVeriEkle();
    
    // print('İşlem tamamlandı! Tüm veriler yeniden yüklendi.');
  } catch (e) {
    // print('Hata oluştu: $e');
  }
}

// Tüm hasta verilerini ekleyen fonksiyon
void topluVeriEkle() async {
  final List<Map<String, dynamic>> hastalar = [
    // Elif Demir
    {
      "documentId": "elif_demir",
      "data": {
        "ad_soyad": "Elif Demir",
        "yas": 25,
        "cinsiyet": "Kadın",
        "basvuru_sikayeti": "Halsizlik",
        "son_lab_tetkik": {
          "HGB": 10,
          "WBC": 5500,
          "PLT": 180000,
          "MCV": 65,
          "Kreatinin": 0.7,
          "Üre": 20,
          "ALT": 30,
          "AST": 25,
          "GGT": 10,
          "Amilaz": 40,
          "Lipaz": 25,
          "Direkt_bilirubin": 0.7,
          "İndirekt_bilirubin": 0.3,
          "Sodyum": 136,
          "Potasyum": 4,
          "Kalsiyum": 9,
          "Demir": 30,
          "Demir_baglama_kapasitesi": 300,
          "Ferritin": 12,
          "B12_vitamini": 350,
          "Folat": 5,
          "Vitamin_D3": 25,
          "Tam_idrar_tetkiki": "Normal",
          "APTT": 30,
          "INR": 1
        },
        "son_goruntuleme": "yok",
        "onceki_basvurular": "yok",
        // Önceki tetkik sonuçları - map/object olarak eklenmeli
        "onceki_tetkik": {
          "HGB": 9.8,
          "WBC": 5200,
          "PLT": 175000,
          "MCV": 64,
          "Kreatinin": 0.65,
          "Üre": 18,
          "ALT": 28,
          "AST": 22,
          "GGT": 9,
          "Amilaz": 38,
          "Lipaz": 22,
          "Direkt_bilirubin": 0.6,
          "İndirekt_bilirubin": 0.25,
          "Sodyum": 135,
          "Potasyum": 3.8,
          "Kalsiyum": 8.8,
          "Demir": 28,
          "Demir_baglama_kapasitesi": 290,
          "Ferritin": 10,
          "B12_vitamini": 340,
          "Folat": 4.8,
          "Vitamin_D3": 22,
          "Tam_idrar_tetkiki": "Normal",
          "APTT": 29,
          "INR": 0.9
        },
        "onceki_goruntuleme": "yok",
        "ameliyat": "yok",
        "patoloji": "yok",
        "dogum_oykusu": "yok",
        "tansiyon": "110 / 70 mmHg",
        "nabiz": 80,
        "ates": 36.5,
        "onceki_tedavi": "yok",
        "uyari": "yok"
      }
    },
    // Ahmet Kalkan
    {
      "documentId": "ahmet_kalkan",
      "data": {
        "ad_soyad": "Ahmet Kalkan",
        "yas": 60,
        "cinsiyet": "Erkek",
        "basvuru_sikayeti": "Kabızlık, kilo kaybı",
        "son_lab_tetkik": {
          "HGB": 10,
          "WBC": 6000,
          "PLT": 200000,
          "MCV": 65,
          "Kreatinin": 1,
          "Üre": 25,
          "ALT": 30,
          "AST": 25,
          "GGT": 20,
          "Amilaz": 30,
          "Lipaz": 25,
          "Direkt_bilirubin": 1,
          "İndirekt_bilirubin": 0.3,
          "Sodyum": 137,
          "Potasyum": 4,
          "Kalsiyum": 9.5,
          "Demir": 20,
          "Demir_baglama_kapasitesi": 300,
          "Transferrin_saturasyonu": "%7",
          "Ferritin": 10,
          "B12_vitamini": 250,
          "Folat": 6,
          "Vitamin_D3": 40,
          "Tam_idrar_tetkiki": "Normal",
          "APTT": 30,
          "INR": 1
        },
        "son_goruntuleme": "Ayakta direkt batın grafisinde batın içinde yaygın gaz",
        "onceki_basvurular": "var, son 6 ayda 4 kez başvurmuş",
        // Önceki tetkik sonuçları - map/object olarak eklenmeli
        "onceki_tetkik": {
          "HGB": 12.5,
          "WBC": 6000,
          "PLT": 200000,
          "MCV": 80,
          "Kreatinin": 1,
          "Üre": 25,
          "ALT": 30,
          "AST": 25,
          "GGT": 20,
          "Amilaz": 30,
          "Lipaz": 25,
          "Direkt_bilirubin": 1,
          "İndirekt_bilirubin": 0.3,
          "Sodyum": 137,
          "Potasyum": 4,
          "Kalsiyum": 9.5,
          "Demir": 60,
          "Demir_baglama_kapasitesi": 240,
          "Transferrin_saturasyonu": "%25",
          "Ferritin": 35,
          "B12_vitamini": 250,
          "Folat": 6,
          "Vitamin_D3": 40,
          "Tam_idrar_tetkiki": "Normal",
          "APTT": 30,
          "INR": 1
        },
        "onceki_goruntuleme": "ayakta direkt batın grafisinde yaygın gaz",
        "ameliyat": "yok",
        "patoloji": "yok",
        "dogum_oykusu": "yok",
        "tansiyon": "100/65 mmHg",
        "nabiz": 105,
        "ates": 36.6,
        "onceki_tedavi": "oral duphalac",
        "uyari": "yok"
      }
    },
    // Ayşegül Aslan
    {
      "documentId": "aysegul_aslan",
      "data": {
        "ad_soyad": "Ayşegül Aslan",
        "yas": 60,
        "cinsiyet": "Kadın",
        "basvuru_sikayeti": "Kemik, kas ağrısı",
        "son_lab_tetkik": {
          "HGB": 12.5,
          "WBC": 6000,
          "PLT": 200000,
          "MCV": 80,
          "Kreatinin": 1,
          "Üre": 25,
          "ALT": 30,
          "AST": 25,
          "GGT": 20,
          "Amilaz": 30,
          "Lipaz": 25,
          "Direkt_bilirubin": 1,
          "İndirekt_bilirubin": 0.3,
          "Sodyum": 137,
          "Potasyum": 4,
          "Kalsiyum": 9.5,
          "Demir": 60,
          "Demir_baglama_kapasitesi": 240,
          "Transferrin_saturasyonu": "%25",
          "Ferritin": 35,
          "B12_vitamini": 250,
          "Folat": 6,
          "Vitamin_D3": 10,
          "Tam_idrar_tetkiki": "Normal",
          "APTT": 30,
          "INR": 1
        },
        "son_goruntuleme": "DEXA T skoru -2",
        "onceki_basvurular": "var, son 1 yılda 2 defa başvuru yapılmış",
        // Önceki tetkik sonuçları - map/object olarak eklenmeli
        "onceki_tetkik": {
          "HGB": 12.5,
          "WBC": 6000,
          "PLT": 200000,
          "MCV": 80,
          "Kreatinin": 1,
          "Üre": 25,
          "ALT": 30,
          "AST": 25,
          "GGT": 20,
          "Amilaz": 30,
          "Lipaz": 25,
          "Direkt_bilirubin": 1,
          "İndirekt_bilirubin": 0.3,
          "Sodyum": 137,
          "Potasyum": 4,
          "Kalsiyum": 9.5,
          "Demir": 60,
          "Demir_baglama_kapasitesi": 240,
          "Transferrin_saturasyonu": "%25",
          "Ferritin": 35,
          "B12_vitamini": 250,
          "Folat": 6,
          "Vitamin_D3": 25,
          "Tam_idrar_tetkiki": "Normal",
          "APTT": 30,
          "INR": 1
        },
        "onceki_goruntuleme": "var 1 yıl önce DEXA T skoru -1,8",
        "ameliyat": "Tiroidektomi",
        "patoloji": "benign tiroid sitolojisi",
        "dogum_oykusu": "4 tane sağlıklı doğum",
        "tansiyon": "140/90 mmHg",
        "nabiz": 80,
        "ates": 36,
        "onceki_tedavi": "analjezik tedavisi, 75 mcg/gün levotiroksin tedavisi",
        "uyari": "yok"
      }
    },
    // Tarık Basma
    {
      "documentId": "case4", // Farklı bir ID kullanıyoruz
      "data": {
        "ad_soyad": "Tarık Basma",
        "yas": 65,
        "cinsiyet": "Erkek",
        "basvuru_sikayeti": "Ayaklarda uyuşma",
        "son_lab_tetkik": {
          "HGB": 12.5,
          "WBC": 6000,
          "PLT": 200000,
          "MCV": 80,
          "Kreatinin": 1,
          "Üre": 25,
          "ALT": 30,
          "AST": 25,
          "GGT": 20,
          "Amilaz": 30,
          "Lipaz": 25,
          "Direkt_bilirubin": 1,
          "İndirekt_bilirubin": 0.3,
          "Sodyum": 137,
          "Potasyum": 4,
          "Kalsiyum": 9.5,
          "Demir": 60,
          "Demir_baglama_kapasitesi": 240,
          "Transferrin_saturasyonu": "%25",
          "Ferritin": 35,
          "B12_vitamini": 250,
          "Folat": 6,
          "Vitamin_D3": 40,
          "Tam_idrar_tetkiki": "Normal",
          "APTT": 30,
          "INR": 1,
          "Glukoz": 180,
          "HbA1C": 9
        },
        "son_goruntuleme": "yok",
        "onceki_basvurular": "var, son 1 yılda 3 defa başvuruda bulunmuş",
        // Önceki tetkik sonuçları - map/object olarak eklenmeli
        "onceki_tetkik": {
          "HGB": 12.5,
          "WBC": 6000,
          "PLT": 200000,
          "MCV": 80,
          "Kreatinin": 1,
          "Üre": 25,
          "ALT": 30,
          "AST": 25,
          "GGT": 20,
          "Amilaz": 30,
          "Lipaz": 25,
          "Direkt_bilirubin": 1,
          "İndirekt_bilirubin": 0.3,
          "Sodyum": 137,
          "Potasyum": 4,
          "Kalsiyum": 9.5,
          "Demir": 60,
          "Demir_baglama_kapasitesi": 240,
          "Transferrin_saturasyonu": "%25",
          "Ferritin": 35,
          "B12_vitamini": 250,
          "Folat": 6,
          "Vitamin_D3": 40,
          "Tam_idrar_tetkiki": "Normal",
          "APTT": 30,
          "INR": 1,
          "Glukoz": 190,
          "HbA1C": 9.2
        },
        "onceki_goruntuleme": "yok",
        "ameliyat": "BPH nedeniyle prostatektomi",
        "patoloji": "benign sitoloji",
        "dogum_oykusu": "yok",
        "tansiyon": "125/80 mmHg",
        "nabiz": 80,
        "ates": 36.5,
        "onceki_tedavi": "Jardiance 1*1, janumet 2*1, Lantus solostar 1*16 ünite sc",
        "uyari": "diyet uyumu ve egzersiz yeterli değil!"
      }
    },
    // Meryem Asmalı
    {
      "documentId": "case5", // Farklı bir ID kullanıyoruz
      "data": {
        "ad_soyad": "Meryem Asmalı",
        "yas": 35,
        "cinsiyet": "Kadın",
        "basvuru_sikayeti": "Kas ağrısı, yorgunluk",
        "son_lab_tetkik": {
          "HGB": 12.5,
          "WBC": 6000,
          "PLT": 200000,
          "MCV": 80,
          "Kreatinin": 1,
          "Üre": 25,
          "ALT": 30,
          "AST": 25,
          "GGT": 20,
          "Amilaz": 30,
          "Lipaz": 25,
          "Direkt_bilirubin": 1,
          "İndirekt_bilirubin": 0.3,
          "Sodyum": 137,
          "Potasyum": 4,
          "Kalsiyum": 9.5,
          "Magnezyum": 1.2,
          "Demir": 60,
          "Demir_baglama_kapasitesi": 240,
          "Transferrin_saturasyonu": "%25",
          "Ferritin": 35,
          "B12_vitamini": 250,
          "Folat": 6,
          "Vitamin_D3": 40,
          "Tam_idrar_tetkiki": "Normal",
          "APTT": 30,
          "INR": 1
        },
        "son_goruntuleme": "yok",
        "onceki_basvurular": "var, 6 ay önce başvurmuş",
        // Önceki tetkik sonuçları - map/object olarak eklenmeli
        // Bu hastada önceki tetkik sonuçları yok, boş bir map olarak ekliyoruz
        "onceki_tetkik": {},
        "onceki_goruntuleme": "yok",
        "ameliyat": "kolesistektomi, sezeryan (2 defa)",
        "patoloji": "benign sitoloji",
        "dogum_oykusu": "2 sağlıklı doğum",
        "tansiyon": "120/70 mmHg",
        "nabiz": 75,
        "ates": 36.5,
        "onceki_tedavi": "2000 IU/gün D vitamini",
        "uyari": "yok"
      }
    }
  ];

  for (final hasta in hastalar) {
    await FirebaseFirestore.instance
        .collection('cases')
        .doc(hasta["documentId"])
        .set(hasta["data"]);
    // print('${hasta["data"]["ad_soyad"]} eklendi!');
  }
}
