import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// API anahtarını güvenlik nedeniyle kaldırdık
// API anahtarını .env dosyasında saklayın ve Flutter dotenv paketi ile yükleyin
// Örnek: final apiKey = dotenv.env['HUGGING_FACE_API_KEY'] ?? '';

// Hata yönetimi ve telemetri için yardımcı fonksiyon
void _logError(String errorId, Map<String, dynamic> errorDetails) {
  // Debug modunda detaylı log
  debugPrint('HATA: $errorId - ${errorDetails.toString()}');
  
  try {
    // Firebase Analytics ile hata takibi
    FirebaseAnalytics.instance.logEvent(
      name: 'error_$errorId',
      parameters: errorDetails,
    );
  } catch (e) {
    // Analytics hatası durumunda en azından debug log
    debugPrint('Analytics hatası: $e');
  }
}

Future<String> analizHuggingFace(Map<String, dynamic> tahlil) async {
  final prompt = '''
Aşağıdaki laboratuvar sonuçlarına göre, olası ilk 3 tanıyı ve her biri için kısa bir gerekçe belirtir misin?
${tahlil.entries.map((e) => '${e.key}: ${e.value}').join(', ')}
Yanıtı tablo şeklinde ver: Sıra | Tanı | Gerekçe
''';

  try {
    final response = await http.post(
      Uri.parse('https://api-inference.huggingface.co/models/meta-llama/Llama-2-7b-chat-hf'),
      headers: {
        // API anahtarını güvenli bir şekilde yönetmek için environment değişkenleri kullanın
        // 'Authorization': 'Bearer ${dotenv.env['HUGGING_FACE_API_KEY']}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inputs': prompt}),
    );
    // Hata yönetimi ve telemetri
    if (response.statusCode != 200) {
      final errorMessage = 'HuggingFace API hatası: ${response.statusCode} - ${response.reasonPhrase}';
      // Telemetri için hata kaydı
      _logError('huggingface_api_error', {
        'status_code': response.statusCode,
        'reason': response.reasonPhrase,
        'body_preview': response.body.length > 100 ? response.body.substring(0, 100) : response.body
      });
      throw Exception(errorMessage);
    }
    
    // Debug modunda detaylı log
    assert(() {
      debugPrint('HuggingFace API yanıtı başarılı');
      return true;
    }());
    final data = jsonDecode(response.body);
    // Farklı olası anahtarları kontrol et
    if (data is List && data.isNotEmpty && data[0]['generated_text'] != null) {
      return data[0]['generated_text'];
    } else if (data is Map && data['generated_text'] != null) {
      return data['generated_text'];
    } else if (data is Map && data['error'] != null) {
      return 'API Hatası: ${data['error']}';
    }
    return 'Yanıt alınamadı';
  } catch (e) {
    return 'Hata: $e';
  }
}
