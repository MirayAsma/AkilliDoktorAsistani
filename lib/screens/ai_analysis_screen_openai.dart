import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:akilli_doktor_asistani/screens/ai_analiz_raporu_page_openai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/openai_api_service.dart';
import '../widgets/openai_api_key_dialog.dart';

// Örnek hasta verileri ve diğer kodlar aynı kalıyor
// ...

// _HastaListesiWidgetState sınıfındaki _baslat metodu güncelleniyor
Future<void> _baslat(Map<String, dynamic> vaka) async {
  try {
    // OpenAI API anahtarını kontrol et
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('openai_api_key');
    
    if (apiKey == null || apiKey.isEmpty) {
      // API anahtarı yoksa dialog göster
      showDialog(
        context: context,
        builder: (context) => OpenAIApiKeyDialog(
          initialValue: null,
          onApiKeySaved: (key) async {
            await prefs.setString('openai_api_key', key);
            Navigator.pop(context);
            
            // API anahtarı kaydedildikten sonra analiz sayfasına yönlendir
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AIAnalizRaporuPage(hastaVerileri: vaka),
              ),
            );
          },
        ),
      );
      return;
    }
    
    // API anahtarı varsa analiz sayfasına yönlendir
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIAnalizRaporuPage(hastaVerileri: vaka),
      ),
    );
    
    // Firestore'a kaydet (opsiyonel - arka planda)
    try {
      await FirebaseFirestore.instance.collection('analysis_requests').add({
        'patient_data': vaka,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed',
        'api_type': 'openai', // API türünü belirt
      });
    } catch (e) {
      if (kDebugMode) {
        print('Firestore kayıt hatası: $e');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Analiz hatası: $e');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Analiz sırasında bir hata oluştu: $e')),
    );
  }
}
