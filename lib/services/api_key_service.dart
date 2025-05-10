import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyService {
  static const String _apiKeyPrefKey = 'openai_api_key';
  
  // API anahtarını kaydet
  static Future<bool> saveApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_apiKeyPrefKey, apiKey);
    } catch (e) {
      print('API anahtarı kaydedilirken hata: $e');
      return false;
    }
  }
  
  // API anahtarını getir
  static Future<String?> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_apiKeyPrefKey);
    } catch (e) {
      print('API anahtarı alınırken hata: $e');
      return null;
    }
  }
  
  // API anahtarının varlığını kontrol et
  static Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }
  
  // API anahtarını sil
  static Future<bool> deleteApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_apiKeyPrefKey);
    } catch (e) {
      print('API anahtarı silinirken hata: $e');
      return false;
    }
  }
}
