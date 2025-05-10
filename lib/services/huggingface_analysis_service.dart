import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:akilli_doktor_asistani/services/api_key_service.dart';

class HuggingFaceAnalysisService {
  String? apiKey;
  final String modelUrl;

  HuggingFaceAnalysisService({
    this.apiKey,
    this.modelUrl = 'https://api.openai.com/v1/chat/completions',
  }) {
    _initApiKey();
  }
  
  // API anahtarını başlat
  Future<void> _initApiKey() async {
    if (apiKey == null || apiKey!.isEmpty) {
      apiKey = await ApiKeyService.getApiKey();
    }
  }

  Future<String> analyze(Map<String, dynamic> tahlil) async {
    try {
      // Önce API ile dene
      final apiResponse = await _callAPI(tahlil);
      if (apiResponse != null && !apiResponse.contains('Hata')) {
        return apiResponse;
      }
      
      // API başarısız olursa yerel yanıt kullan
      if (kDebugMode) {
        print('API yanıt vermedi, yerel yanıt kullanılıyor');
      }
      if (tahlil.containsKey('soru')) {
        return _mockChatbotResponse(tahlil['soru']);
      } else {
        return _mockAnalysisResponse(tahlil);
      }
    } catch (e) {
      if (kDebugMode) {
        print('API hatası: $e');
      }
      // Hata durumunda yerel yanıt kullan
      if (tahlil.containsKey('soru')) {
        return _mockChatbotResponse(tahlil['soru']);
      } else {
        return _mockAnalysisResponse(tahlil);
      }
    }
  }
  
  Future<String?> _callAPI(Map<String, dynamic> tahlil) async {
    // API anahtarını kontrol et
    await _initApiKey();
    if (apiKey == null || apiKey!.isEmpty) {
      return 'API anahtarı bulunamadı. Lütfen ayarlardan API anahtarınızı ekleyin.';
    }
    
    final prompt = _formatPrompt(tahlil);
    try {
      if (kDebugMode) {
        print('API istek gönderiliyor: OpenAI');
        print('API prompt: $prompt');
      }
      
      // OpenAI API formatında istek gönder
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'Sen yardımcı bir doktor asistanısın. Tıbbi bilgiler ve tavsiyeler veriyorsun.'},
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 500,
          'temperature': 0.7
        }),
      );
      if (kDebugMode) {
        print('HuggingFace yanıt kodu: ${response.statusCode}');
        print('HuggingFace yanıt gövdesi: ${response.body}');
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // OpenAI API yanıt formatı
        if (data != null && data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          return content;
        }
        return 'Yanıt alınamadı: ' + response.body;
      } else {
        return 'API Hatası: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'API çağrısı sırasında hata oluştu: $e';
    }
  }

  String _formatPrompt(Map<String, dynamic> tahlil) {
    String promptText = "";
    
    if (tahlil.containsKey('soru')) {
      // Eğer soru varsa, chatbot modu
      promptText = "Soru: ${tahlil['soru']}\nYanıt:";
    } else {
      // Tahlil analizi modu
      promptText = "Bir doktor asistanı olarak aşağıdaki laboratuvar sonuçlarını analiz et ve kısa, net bir tıbbi rapor hazırla. Anormal değerleri belirt, olası tanıları ve önerileri listele:\n";
      
      // Tahlil verilerini ekle
      promptText += tahlil.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    }
    
    return promptText;
  }
  
  // Geçici mock yanıtlar - API çalışana kadar kullanılacak
  String _mockChatbotResponse(String soru) {
    // Soru içeriğine göre basit yanıtlar
    soru = soru.toLowerCase();
    
    if (soru.contains('merhaba') || soru.contains('selam')) {
      return 'Merhaba! Size nasıl yardımcı olabilirim?';
    } else if (soru.contains('nasılsın')) {
      return 'Ben bir yapay zeka asistanıyım, duygularım yok ama size yardımcı olmak için buradayım!';
    } else if (soru.contains('teşekkür')) {
      return 'Rica ederim! Başka bir sorunuz var mı?';
    } else if (soru.contains('baş ağrısı') || soru.contains('başım ağrıyor')) {
      return 'Baş ağrısı birçok nedenden kaynaklanabilir: stres, yorgunluk, dehidratasyon, migren, tansiyon sorunları vb. Şiddetli veya sürekli baş ağrılarında mutlaka bir doktora görünmenizi öneririm. Ağrı kesiciler geçici rahatlama sağlayabilir, ancak altta yatan nedeni tedavi etmez.';
    } else if (soru.contains('ateş') || soru.contains('ateşim var')) {
      return '38°C üzerindeki ateş, vücudunuzun bir enfeksiyonla savaştığını gösterir. Bol sıvı tüketin, dinlenin ve ateş düşürücü ilaçlar kullanabilirsiniz. 39°C üzerinde ateş, 3 günden uzun süren ateş veya diğer ciddi belirtilerle birlikte görülen ateş durumunda mutlaka doktora başvurun.';
    } else if (soru.contains('öksürük') || soru.contains('öksürüyorum')) {
      return 'Öksürük; soğuk algınlığı, grip, bronşit, astım, alerji gibi birçok durumda görülebilir. Kuru öksürük için bal ve ılık içecekler faydalı olabilir. Balgamlı öksürük, nefes darlığı, göğüs ağrısı veya 2 haftadan uzun süren öksürük varsa doktora görünmelisiniz.';
    } else {
      return 'Bu konuda size yardımcı olmak için daha fazla bilgiye ihtiyacım var. Lütfen sorunuzu daha detaylı açıklayabilir misiniz?';
    }
  }
  
  String _mockAnalysisResponse(Map<String, dynamic> tahlil) {
    // Gelen tahlil verilerine göre anlamlı bir yanıt oluştur
    List<String> anormalDegerler = [];
    List<String> olasiTanilar = [];
    List<String> oneriler = [];
    
    // Tahlil değerlerini kontrol et
    tahlil.forEach((key, value) {
      String normalizeKey = key.toLowerCase();
      
      // ALT ve AST yüksekliği
      if ((normalizeKey.contains('alt') && value is num && value > 40) ||
          (normalizeKey.contains('ast') && value is num && value > 40)) {
        anormalDegerler.add('$key: $value (Yüksek)');
        if (!olasiTanilar.contains('Karaciğer fonksiyon bozukluğu')) {
          olasiTanilar.add('Karaciğer fonksiyon bozukluğu');
          oneriler.add('Karaciğer fonksiyonlarının daha detaylı değerlendirilmesi için ek testler yapılmalı');
        }
      }
      
      // Sodyum düşüklüğü
      if (normalizeKey.contains('sodyum') && value is num && value < 135) {
        anormalDegerler.add('$key: $value (Düşük)');
        olasiTanilar.add('Hiponatremi');
        oneriler.add('Sıvı-elektrolit dengesinin değerlendirilmesi gerekli');
      }
      
      // Vitamin D3 düşüklüğü
      if ((normalizeKey.contains('vitamin d') || normalizeKey.contains('d3')) && value is num && value < 20) {
        anormalDegerler.add('$key: $value (Düşük)');
        olasiTanilar.add('Vitamin D eksikliği');
        oneriler.add('Vitamin D takviyesi başlanması önerilir');
      }
      
      // B12 düşüklüğü
      if (normalizeKey.contains('b12') && value is num && value < 200) {
        anormalDegerler.add('$key: $value (Düşük)');
        olasiTanilar.add('Vitamin B12 eksikliği');
        oneriler.add('B12 vitamini takviyesi başlanması önerilir');
      }
      
      // Üre yüksekliği
      if (normalizeKey.contains('ure') && value is num && value > 40) {
        anormalDegerler.add('$key: $value (Yüksek)');
        olasiTanilar.add('Böbrek fonksiyon bozukluğu');
        oneriler.add('Böbrek fonksiyonlarının daha detaylı değerlendirilmesi için ek testler yapılmalı');
      }
      
      // İdrar tetkikinde anormallik
      if (normalizeKey.contains('idrar') && value.toString().contains('+')) {
        anormalDegerler.add('$key: $value');
        olasiTanilar.add('İdrar yolu enfeksiyonu veya böbrek hastalığı');
        oneriler.add('İdrar kültürü yapılması ve nefroloji konsültasyonu önerilir');
      }
    });
    
    // Raporu oluştur
    String rapor = "";
    
    if (anormalDegerler.isNotEmpty) {
      rapor += "\n\nANORMAL DEĞERLER:\n" + anormalDegerler.join('\n');
    } else {
      rapor += "\n\nTüm değerler normal sınırlar içindedir.";
    }
    
    if (olasiTanilar.isNotEmpty) {
      rapor += "\n\nOLASI TANILAR:\n" + olasiTanilar.join('\n');
    }
    
    if (oneriler.isNotEmpty) {
      rapor += "\n\nÖNERİLER:\n" + oneriler.join('\n');
    }
    
    return "TAHLİL ANALİZ RAPORU" + rapor;
  }
}
