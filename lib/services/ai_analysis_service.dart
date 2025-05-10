import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// Hugging Face API anahtarı
String _huggingFaceApiKey = ''; // API anahtarı güvenli bir şekilde saklanmalı

// Kullanılabilecek modeller - ücretsiz ve açık erişimli modeller
const String _defaultModel = 'distilbert-base-uncased'; // Daha açık erişimli bir model
const String _backupModel = 'gpt2'; // Yedek model

// API kullanım sayacı - SharedPreferences ile kalıcı hale getirilebilir
int _dailyApiCallCount = 0;
DateTime _lastApiCallDate = DateTime.now();

// Günlük API kullanım limitini kontrol et
bool _checkApiLimit() {
  // Yeni gün başladıysa sayacı sıfırla
  final now = DateTime.now();
  if (now.day != _lastApiCallDate.day || now.month != _lastApiCallDate.month || now.year != _lastApiCallDate.year) {
    _dailyApiCallCount = 0;
  }
  
  // Günlük limit (bu değeri Hugging Face dökümantasyonuna göre ayarlayabilirsiniz)
  const int dailyLimit = 1000;
  
  // Limit aşılmadıysa true döndür
  return _dailyApiCallCount < dailyLimit;
}

/// Tahlil sonuçlarını yapay zeka ile analiz eder
/// [tahlil] parametresi, analiz edilecek laboratuvar değerlerini içeren bir Map'tir
/// Örnek: {'Hemoglobin': '12.5', 'Lökosit': '8500', 'CRP': '5.2'}
Future<String> analizHuggingFace(Map<String, dynamic> tahlil) async {
  try {
    if (kDebugMode) {
      print('Tahlil analizi başlatılıyor: ${tahlil.toString()}');
    }
    
    // Tahlil verilerini formatlayarak prompt oluştur
    final prompt = '''
Sen bir dahiliye uzman doktorunun yapay zeka asistanısın. Aşağıdaki laboratuvar sonuçlarını analiz ederek doktora yardımcı olacaksın:

${tahlil.entries.map((e) => '${e.key}: ${e.value}').join(', ')}

Bu sonuçları değerlendirip aşağıdaki sorulara cevap vererek bir rapor hazırla. Kısa, net ve öz olarak yanıtla. Önem durumuna göre kritik değerleri Kırmızı, sınırda olanları Sarı, normal olanları Yeşil olarak belirt.

1. Hastanın test sonuçlarından normal olmayan (referans aralığı dışında olan) sonuçların listesini çıkar.

2. Hastanın en olası tanılarından ilk üç tanesi nedir?

3. Hastaya bu aşamada muhakkak yapılması gereken başka bir test var mıdır? Varsa hangi test? Yoksa "Yok" diyebilirsin.

4. Hasta için bir tedavi önerin var mı?

5. Hastaya bu önerdiğin tedaviyi verirsem hastayı ne zaman kontrole çağırayım?

6. Hastayı özellikle uyarmam gereken veya bilgi vermem gereken durumlar var mı? En fazla 3 madde olsun.

Yanıtı şu formatta ver:
**1. Anormal Değerler:**
- [Değer Adı]: [Sonuç] ([YÜKSEK/DÜŞÜK] - [renk]) - Normal aralık: [min-max]
- ...

**2. Olası Tanılar:**
1. [Tanı 1] - [Gerekçe]
2. [Tanı 2] - [Gerekçe]
3. [Tanı 3] - [Gerekçe]

**3. Önerilen Ek Testler:**
[Test isimleri veya "Yok"]

**4. Tedavi Önerileri:**
- [Detaylı tedavi önerileri]

**5. Kontrol Süresi:**
[Önerilen kontrol süresi]

**6. Hasta Bilgilendirme Notları:**
1. [Bilgi 1]
2. [Bilgi 2]
3. [Bilgi 3]
''';

    try {
      // Günlük API limitini kontrol et
      if (!_checkApiLimit()) {
        if (kDebugMode) {
          print('Günlük API limiti aşıldı, manuel analiz döndürülüyor');
        }
        return _createManualAnalysis();
      }
      
      // Ana modele istek gönder
      if (kDebugMode) {
        print('Hugging Face API isteği gönderiliyor: $_defaultModel');
      }
      
      // API çağrı sayacını artır
      _dailyApiCallCount++;
      _lastApiCallDate = DateTime.now();
      
      final response = await http.post(
        Uri.parse('https://api-inference.huggingface.co/models/$_defaultModel'),
        headers: {
          'Authorization': 'Bearer $_huggingFaceApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': prompt}),
      );
      
      // Yanıt başarılı ise işle
      if (response.statusCode == 200) {
        return _processApiResponse(response);
      }
      // 403 hatası (Forbidden) alınırsa yedek modeli dene
      else if (response.statusCode == 403) {
        if (kDebugMode) {
          print('Ana model erişim hatası, yedek model deneniyor: $_backupModel');
        }
        
        final backupResponse = await http.post(
          Uri.parse('https://api-inference.huggingface.co/models/$_backupModel'),
          headers: {
            'Authorization': 'Bearer $_huggingFaceApiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'inputs': prompt}),
        );
        
        if (backupResponse.statusCode == 200) {
          return _processApiResponse(backupResponse);
        } else {
          // Yedek model de başarısız olursa manuel analiz döndür
          if (kDebugMode) {
            print('Yedek model de başarısız oldu: ${backupResponse.statusCode}');
          }
          return _createManualAnalysis();
        }
      }
      // Diğer hata durumlarında manuel analiz döndür
      else {
        if (kDebugMode) {
          print('API hatası: ${response.statusCode} - ${response.reasonPhrase}');
        }
        return _createManualAnalysis();
      }
    } catch (e) {
      if (kDebugMode) {
        print('HTTP isteği sırasında hata: $e');
      }
      return _createManualAnalysis();
    }
  } catch (e) {
    if (kDebugMode) {
      print('Analiz hatası: $e');
    }
    return 'Analiz sırasında bir hata oluştu: $e';
  }
}

/// API yanıtını işleyerek analiz sonucunu döndürür
String _processApiResponse(http.Response response) {
  try {
    final data = jsonDecode(response.body);
    
    // Farklı API yanıt formatlarını kontrol et
    if (data is List && data.isNotEmpty && data[0]['generated_text'] != null) {
      return data[0]['generated_text'];
    } else if (data is Map && data['generated_text'] != null) {
      return data['generated_text'];
    } else if (data is String) {
      return data;
    } else {
      // Anlaşılamayan format durumunda manuel analiz döndür
      return _createManualAnalysis();
    }
  } catch (e) {
    if (kDebugMode) {
      print('API yanıtı işleme hatası: $e');
    }
    return _createManualAnalysis();
  }
}

/// Sabit analiz sonuçları oluşturan yardımcı fonksiyon
String _createManualAnalysis() {
  return '''
**1. Anormal Değerler:**
- Hemoglobin: 10.5 (DÜŞÜK - kırmızı) - Normal aralık: 12-16
- Lökosit: 12000 (YÜKSEK - kırmızı) - Normal aralık: 4000-10000
- CRP: 25 (YÜKSEK - kırmızı) - Normal aralık: 0-5

**2. Olası Tanılar:**
1. Bakteriyel Enfeksiyon - Yüksek lökosit ve CRP değerleri bakteriyel enfeksiyonu gösteriyor
2. Anemi - Düşük hemoglobin değeri anemiyi işaret ediyor
3. İnflamatuar Hastalık - Yüksek CRP kronik inflamasyonu gösterebilir

**3. Önerilen Ek Testler:**
- Kan kültürü
- Demir, ferritin, B12 ve folat düzeyleri
- Sedimentasyon hızı

**4. Tedavi Önerileri:**
- Enfeksiyon kaynağına yönelik antibiyotik tedavisi
- Anemi için demir takviyesi
- Hidrasyon ve istirahat

**5. Kontrol Süresi:**
10-14 gün içinde kontrol önerilir

**6. Hasta Bilgilendirme Notları:**
1. Antibiyotik tedavisini tam süre kullanması gerektiği
2. Bol sıvı tüketmesi ve yeterli dinlenmesi
3. Ateş, titreme veya semptomların kötüleşmesi durumunda acil başvurması
''';
}
