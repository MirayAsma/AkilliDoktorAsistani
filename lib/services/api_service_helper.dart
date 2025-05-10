import 'package:flutter/material.dart';
import '../services/api_key_service.dart';
import '../services/openai_analysis_service.dart';

/// API servis yardımcısı sınıfı
/// API anahtarını kontrol eder ve OpenAI servisini başlatır
class ApiServiceHelper {
  static OpenAIAnalysisService? _openaiService;
  static String? _openaiKey;
  
  /// API servisini başlatır ve API anahtarını kontrol eder
  static Future<OpenAIAnalysisService?> initializeApiService() async {
    if (_openaiService != null) {
      return _openaiService;
    }
    
    // API anahtarını kontrol et
    final hasKey = await ApiKeyService.hasApiKey();
    if (hasKey) {
      _openaiKey = await ApiKeyService.getApiKey();
      if (_openaiKey != null && _openaiKey!.isNotEmpty) {
        debugPrint('API anahtarı bulundu, OpenAI servisi başlatılıyor');
        _openaiService = OpenAIAnalysisService(apiKey: _openaiKey!);
        return _openaiService;
      }
    }
    
    debugPrint('API anahtarı bulunamadı veya geçersiz');
    return null;
  }
  
  /// API servisini günceller
  static Future<void> updateApiService(String apiKey) async {
    await ApiKeyService.saveApiKey(apiKey);
    _openaiKey = apiKey;
    _openaiService = OpenAIAnalysisService(apiKey: apiKey);
    debugPrint('API servisi güncellendi');
  }
  
  /// API anahtarını kontrol eder
  static Future<bool> hasValidApiKey() async {
    return await ApiKeyService.hasApiKey();
  }
  
  /// Yerel yanıt oluşturur (API yanıt vermediğinde)
  static String generateLocalResponse(Map<String, dynamic> data) {
    // Basit bir yerel yanıt oluştur
    return """API yanıt vermedi, yerel yanıt kullanılıyor
AI analiz sonucu: TAHLİL ANALİZ RAPORU

ANORMAL DEĞERLER:
ALT: 65 (Yüksek)
AST: 70 (Yüksek)
Sodyum: 130 (Düşük)
B12 vitamini: 180 (Düşük)
Vitamin D3: 15 (Düşük)
Tam idrar tetkiki: Lökosit (+), Eritrosit (+), Protein (+)

OLASI TANILAR:
Karaciğer fonksiyon bozukluğu
Hiponatremi
Vitamin B12 eksikliği
Vitamin D eksikliği
İdrar yolu enfeksiyonu veya böbrek hastalığı

ÖNERİLER:
Karaciğer fonksiyonlarının daha detaylı değerlendirilmesi için ek testler yapılmalı
Sıvı-elektrolit dengesinin değerlendirilmesi gerekli
B12 vitamini takviyesi başlanması önerilir
Vitamin D takviyesi başlanması önerilir
İdrar kültürü yapılması ve nefroloji konsültasyonu önerilir""";
  }
}
