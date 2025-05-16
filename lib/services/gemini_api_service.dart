import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

/// Gemini API ile iletişim kurmak için servis sınıfı
class GeminiApiService {
  // Sabit API anahtarı - Gemini için güncel anahtar
  static const String defaultApiKey = 'AIzaSyAvE0Zu5w15oB02VmpfQ24eCjQk8Af6qXw';
  static const String _apiKeyPrefKey = 'gemini_api_key';
  
  final String apiKey;
  final GenerativeModel? _model;
  final int maxOutputTokens;
  final int timeoutSeconds;

  GeminiApiService(
    this.apiKey, {
    this.maxOutputTokens = 2048, // Daha uzun yanıtlar için token sınırını artırdık
    this.timeoutSeconds = 60,
  }) : _model = apiKey.isNotEmpty
          ? GenerativeModel(
              model: 'gemini-2.0-flash',
              apiKey: apiKey,
              generationConfig: GenerationConfig(
                temperature: 0.3,
                topK: 1,
                topP: 0.8,
                maxOutputTokens: maxOutputTokens,
              ),
            )
          : null;
          
  /// API anahtarını kaydet
  static Future<bool> saveApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyPrefKey, apiKey);
      return true;
    } catch (e) {
      debugPrint('GeminiApiService: API anahtarı kaydetme hatası: $e');
      return false;
    }
  }
  
  /// Kayıtlı API anahtarını getir
  static Future<String?> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_apiKeyPrefKey) ?? defaultApiKey;
    } catch (e) {
      debugPrint('GeminiApiService: API anahtarı alma hatası: $e');
      return defaultApiKey;
    }
  }

  /// Gemini API'ye mesaj gönderir ve yanıt alır
  Future<String> sendMessage(String prompt) async {
    try {
      if (_model == null) {
        debugPrint('Gemini API modeli başlatılamadı: API anahtarı geçersiz veya boş');
        return 'Gemini API anahtarı geçerli değil veya ayarlanmamış';
      }
      debugPrint('Gemini API isteği gönderiliyor...');
      final shortPrompt = prompt.length > 100 ? prompt.substring(0, 100) + '...' : prompt;
      debugPrint('Prompt: $shortPrompt');
      final content = Content.text(prompt);
      debugPrint('Gemini API isteği başlıyor, prompt uzunluğu: ${prompt.length}');
      debugPrint('Gemini API gönderilen prompt: $prompt');
      try {
        final response = await _model!.generateContent([content])
            .timeout(Duration(seconds: timeoutSeconds), onTimeout: () {
          debugPrint('Gemini API zaman aşımına uğradı ($timeoutSeconds saniye)');
          throw TimeoutException('Gemini API yanıt vermedi');
        });
        debugPrint('Gemini API yanıtı alındı');
        
        // Yanıtı kontrol et
        if (response.text == null || response.text!.isEmpty) {
          debugPrint('Gemini API yanıtı boş döndü');
          return '<p>Analiz tamamlanamadı. Lütfen daha kısa bir hasta verisi ile tekrar deneyin.</p>';
        }
        
        // Yanıtı logla
        debugPrint('Gemini API dönen yanıt: ${response.text}');
        
        // HTML yanıtı temizle ve döndür
        String cleanedResponse = cleanHtmlResponse(response.text!);
        
        // Eğer temizlenmiş yanıt boşsa, orijinal yanıtı döndür
        if (cleanedResponse.trim().isEmpty) {
          debugPrint('Temizlenmiş yanıt boş, orijinal yanıt döndürülüyor');
          return '<div>${response.text!.replaceAll('\n', '<br>')}</div>';
        }
        
        return cleanedResponse;
      } catch (innerError) {
        debugPrint('API çağrısı sırasında hata: $innerError');
        throw innerError;
      }
    } on TimeoutException {
      debugPrint('Gemini API zaman aşımı hatası');
      return 'Gemini API yanıt vermedi. Lütfen daha kısa bir hasta verisi ile tekrar deneyin.';
    } catch (e, stackTrace) {
      debugPrint('Gemini API hatası: $e');
      debugPrint('Stack trace: $stackTrace');
      if (e.toString().contains('API key expired')) {
        return 'API anahtarınızın süresi dolmuş. Lütfen yeni bir API anahtarı edinin.';
      }
      if (e.toString().contains('API key not valid')) {
        return 'API anahtarı geçerli değil. Lütfen geçerli bir API anahtarı girin.';
      }
      
      // Ağ hatası için özel mesaj
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection') || 
          e.toString().contains('network')) {
        return 'İnternet bağlantısı hatası. Lütfen bağlantınızı kontrol edin.';
      }
      
      // Genel hata durumunda kısa bir yanıt döndür
      return 'Analiz tamamlanamadı: ${e.toString().split(':').first}';
    }
  }

  /// Tıbbi verileri analiz eder
  Future<String> analyzeMedicalData(String prompt) async {
    return sendMessage(prompt);
  }
  
  /// Hasta verilerini Gemini ile analiz eder
  Future<String> analyzePatientData(Map<String, dynamic> patientData, {String? additionalInfo}) async {
    try {
      if (kDebugMode) {
        print('analyzePatientData çağrıldı');
      }
      
      // API anahtarını test et ve sonucu logla
      bool isApiKeyValid = await GeminiApiService.testApiKey(apiKey);
      debugPrint('GeminiApiService: API anahtarı geçerli mi? $isApiKeyValid');
      // Tahlil verilerini string formatına çevir
      String labResults = '';
      dynamic tahlilVerileri = patientData['son_lab_tetkik'];
      // Eğer 'son_lab_tetkik' yoksa veya boşsa, doğrudan patientData'nın kendisini kullan
      if (tahlilVerileri == null || (tahlilVerileri is String && tahlilVerileri.trim().isEmpty)) {
        // Ad, yaş, cinsiyet, şikayet gibi anahtarları çıkar, kalanları lab verisi olarak al
        final excludeKeys = {'ad_soyad', 'name', 'yas', 'age', 'cinsiyet', 'gender', 'basvuru_sikayeti', 'complaint'};
        final labMap = Map<String, dynamic>.from(patientData)
          ..removeWhere((key, value) => excludeKeys.contains(key));
        if (labMap.isNotEmpty) {
          // Tüm anahtar/değerleri kullan
          tahlilVerileri = labMap;
        }
      }
      if (tahlilVerileri != null) {
        if (tahlilVerileri is Map) {
          labResults = tahlilVerileri.entries.map((e) => "${e.key}: ${e.value}").join('\n');
        } else if (tahlilVerileri is String) {
          labResults = tahlilVerileri.length > 100 ? tahlilVerileri.substring(0, 100) + '...' : tahlilVerileri;
        } else if (tahlilVerileri is List) {
          labResults = tahlilVerileri.take(5).map((item) => item.toString()).join('\n');
        }
      }
      if (labResults.isEmpty) {
        labResults = "Laboratuvar sonuçları bulunamadı";
      }
      
      // Hasta bilgilerini güvenli bir şekilde al
      String adSoyad = patientData['ad_soyad']?.toString() ?? patientData['name']?.toString() ?? 'Bilinmiyor';
      String yas = patientData['yas']?.toString() ?? patientData['age']?.toString() ?? 'Bilinmiyor';
      String cinsiyet = patientData['cinsiyet']?.toString() ?? patientData['gender']?.toString() ?? 'Bilinmiyor';
      String sikayet = patientData['basvuru_sikayeti']?.toString() ?? patientData['complaint']?.toString() ?? 'Bilinmiyor';
      
      // Gelişmiş HTML ve renkli tablo isteyen prompt başlığı
      String promptPrefix = '''Sevgili yapay zekâ robotu,
Ben Mardin/Türkiye’de çalışan bir dahiliye uzman doktoruyum. Bana başvuruda bulunan bir hastamın bilgilerini hayali bir isimle paylaşacağım. Bu hastamı değerlendirip bana aşağıdaki sorulara cevap olacak şekilde bir özet sunmanı istiyorum. 
Bunu hazırlarken sana vereceğim başvuru sırasındaki ve önceki başvurulardaki laboratuvar tetkik sonuçları, verilen tedaviler, görüntüleme sonuçları gibi tüm bilgileri kullanmanı istiyorum. 
Bana sunacağın özetin kısa ve net olmasını istiyorum. 
Yanıtı sadece <table> etiketiyle başlat, başında ve sonunda açıklama veya kod bloğu ekleme. Tabloda önemli hücrelerde <span style=\"color:green\">, <span style=\"color:yellow\"> ve <span style=\"color:red\"> ile renklendir. Sadece tabloyu ve başlıkları döndür, açıklama metni ekleme. Başlıkları <b> ile kalınlaştır.

1. Hastanın test sonuçlarından normal olmayan (referans aralığı dışında olan) sonuçların listesini çıkar.
2. Hastanın en olası tanılarından ilk üç tanesi nedir?
3. Hastaya bu aşamada muhakkak yapılması gereken başka bir test var mıdır? Varsa hangi test? Yoksa “Yok” diyebilirsin.
4. Hasta için bir tedavi önerin var mı?
5. Hastaya bu önerdiğin tedaviyi verirsem hastayı ne zaman kontrole çağırayım?
6. Hastayı özellikle uyarmam gereken veya bilgi vermem gereken durumlar var mı? En fazla 3 madde olsun.
''';

      String prompt = '''$promptPrefix\nLaboratuvar: $labResults\nHasta: $adSoyad, $yas yaş, $cinsiyet\nŞikayet: $sikayet''';
      
      if (kDebugMode) {
        print('Gönderilen prompt uzunluğu: ${prompt.length}');
      }
      
      // Gemini API'ye gönder
      return sendMessage(prompt);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('analyzePatientData hatası: $e');
        print('Stack trace: $stackTrace');
      }
      return 'Hasta verilerini analiz ederken bir hata oluştu: $e';
    }
  }
  
  /// Gemini API'ye analiz isteği gönderir
  Future<String> analyze(String prompt) async {
    return sendMessage(prompt);
  }
  
  /// Tıbbi görüntü analizi yapar
  Future<String> analyzeMedicalImage(Uint8List imageBytes, String description) async {
    try {
      if (_model == null) {
        debugPrint('Gemini API modeli başlatılamadı: API anahtarı geçersiz veya boş');
        throw Exception('Gemini API anahtarı geçerli değil veya ayarlanmamış');
      }
      
      debugPrint('GeminiApiService: Tıbbi görüntü analizi yapılıyor...');
      
      final prompt = '''
      Sen bir tıbbi görüntü analiz uzmanısın. Bu tıbbi görüntüyü detaylı olarak analiz et ve kapsamlı bir rapor oluştur. 
      Görüntü hakkında bilgi: $description
      
      Lütfen aşağıdaki formatta yanıt ver:
      1. Görüntü Türü ve Genel Değerlendirme
      2. Gözlemlenen Bulgular (en önemli 3-5 bulgu)
      3. Olası Tanılar (en olası 3 tanı)
      4. Önerilen İleri Tetkikler
      5. Tedavi Önerileri
      ''';
      
      // Not: Görüntü işleme özelliği geçici olarak devre dışı bırakıldı
      // Sadece metin tabanlı analiz yapılıyor
      final content = Content.text(prompt + '\n\nNot: Bu analiz, görüntü olmadan sadece metin tabanlı bilgilerle yapılmıştır.');
      
      // Gemini modeliyle içerik oluştur
      final response = await _model!.generateContent([content]);
      
      if (response.text == null || response.text!.isEmpty) {
        debugPrint('GeminiApiService: Boş yanıt alındı');
        return 'Görüntü analiz edilemedi. Lütfen daha sonra tekrar deneyin.';
      }
      
      debugPrint('GeminiApiService: Başarılı analiz tamamlandı');
      return response.text!;
    } catch (e) {
      debugPrint('GeminiApiService: Görüntü analizi hatası: $e');
      
      if (e.toString().contains('API key expired')) {
        return 'API anahtarınızın süresi dolmuş. Lütfen yeni bir API anahtarı girin.';
      } else if (e.toString().contains('API key not valid')) {
        return 'API anahtarı geçerli değil. Lütfen geçerli bir API anahtarı girin.';
      } else if (e.toString().contains('INVALID_ARGUMENT')) {
        return 'Görüntü formatı desteklenmiyor veya görüntü çok büyük olabilir.';
      }
      
      return 'Tıbbi görüntü analizi sırasında hata: $e';
    }
  }
  
  /// Multimodal içerik oluşturma
  Future<String> generateMultimodalContent(String prompt, List<Map<String, dynamic>> multimodalData) async {
    try {
      if (_model == null) {
        debugPrint('Gemini API modeli başlatılamadı: API anahtarı geçersiz veya boş');
        throw Exception('Gemini API anahtarı geçerli değil veya ayarlanmamış');
      }
      debugPrint('GeminiApiService: Multimodal istek gönderiliyor...');
      int imageCount = multimodalData.where((data) => data['type'] == 'image' && data['bytes'] is Uint8List).length;
      String enhancedPrompt = prompt.trim();
      if (imageCount > 0) {
        enhancedPrompt = 'Aşağıda $imageCount adet tıbbi görüntü referansı bulunuyor, ancak şu anda sadece metin tabanlı analiz yapılacaktır.\n\n$enhancedPrompt';
      }
      final content = Content.text(enhancedPrompt);
      final response = await _model!.generateContent([content]);
      if (response.text == null || response.text!.isEmpty) {
        debugPrint('GeminiApiService: Boş yanıt alındı');
        return 'Yanıt alınamadı. Lütfen daha sonra tekrar deneyin.';
      }
      debugPrint('GeminiApiService: Başarılı yanıt alındı');
      return response.text!;
    } catch (e) {
      debugPrint('GeminiApiService: Multimodal hata: $e');
      if (e.toString().contains('API key expired')) {
        return 'API anahtarınızın süresi dolmuş. Lütfen yeni bir API anahtarı girin.';
      } else if (e.toString().contains('API key not valid')) {
        return 'API anahtarı geçerli değil. Lütfen geçerli bir API anahtarı girin.';
      } else if (e.toString().contains('INVALID_ARGUMENT')) {
        return 'Geçersiz istek. Lütfen farklı bir soru sorun veya resim formatını kontrol edin.';
      }
      return 'Gemini API ile iletişim kurulamadı: $e';
    }
  }

  /// API anahtarını doğrudan test eder, geçerli ise true döner.
  static Future<bool> testApiKey(String apiKey) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.1,
          topK: 1,
          topP: 0.8,
          maxOutputTokens: 8,
        ),
      );
      // Çok basit bir prompt kullan
      final content = Content.text('Hello');
      final response = await model.generateContent([content]).timeout(const Duration(seconds: 10));
      debugPrint('API anahtarı test yanıtı: ${response.text}');
      return response.text != null && response.text!.isNotEmpty;
    } catch (e) {
      debugPrint('GeminiApiService: API anahtarı test başarısız: $e');
      return false;
    }
  }
  
  /// HTML yanıtını temizler ve düzgün bir HTML yanıtı döndürür
  static String cleanHtmlResponse(String htmlResponse) {
    // Debug için orijinal yanıtı yazdır
    debugPrint('Orijinal HTML yanıtı: $htmlResponse');
    
    // Kod bloğu işaretlerini temizle
    String cleanedResponse = htmlResponse.replaceAll(RegExp(r'```html|```|~~~html|~~~'), '');
    
    // HTML yanıtını düzenle
    cleanedResponse = cleanedResponse.trim();
    
    // Eğer yanıt boşsa veya HTML içermiyorsa, basit bir HTML yapısı oluştur
    if (cleanedResponse.isEmpty || 
        (!cleanedResponse.contains('<table') && 
         !cleanedResponse.contains('<tr') && 
         !cleanedResponse.contains('<td'))) {
      // HTML etiketleri içermiyorsa, yanıtı HTML olarak formatla
      if (!cleanedResponse.contains('<') || !cleanedResponse.contains('>')) {
        cleanedResponse = '<div>${cleanedResponse.replaceAll('\n', '<br>')}</div>';
      }
    }
    
    // Debug için temizlenmiş yanıtı yazdır
    debugPrint('Temizlenmiş HTML yanıtı: $cleanedResponse');
    
    return cleanedResponse;
  }
}

