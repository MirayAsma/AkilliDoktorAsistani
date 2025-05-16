import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'package:akilli_doktor_asistani/services/api_key_service.dart';
import 'package:akilli_doktor_asistani/widgets/api_key_dialog.dart';
import 'package:akilli_doktor_asistani/services/gemini_analysis_service.dart';

String normalizeKey(String key) {
  return key
      .toLowerCase()
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('ı', 'i')
      .replaceAll('ş', 's')
      .replaceAll('ç', 'c')
      .replaceAll('ğ', 'g')
      .replaceAll('_', '')
      .replaceAll(' ', '');
}

final Map<String, Map<String, num>> referansAraliklari = {
  'vitamind3': {'min': 20, 'max': 50},
  'mcv': {'min': 80, 'max': 100},
  'kalsiyum': {'min': 8.5, 'max': 10.5},
  'sodyum': {'min': 135, 'max': 145},
  'ferritin': {'min': 15, 'max': 200},
  'magnezyum': {'min': 1.6, 'max': 2.6},
  'alt': {'min': 0, 'max': 40},
  'inr': {'min': 0.8, 'max': 1.2},
  'ure': {'min': 10, 'max': 50},
  'lipaz': {'min': 8, 'max': 78},
  'hgb': {'min': 12, 'max': 16},
  'wbc': {'min': 4000, 'max': 10000},
  'plt': {'min': 150000, 'max': 450000},
  'kreatinin': {'min': 0.6, 'max': 1.2},
  'glukoz': {'min': 70, 'max': 110},
  'potasyum': {'min': 3.5, 'max': 5.1},
  'ast': {'min': 0, 'max': 40},
  'amilaz': {'min': 28, 'max': 100},
  'ggt': {'min': 9, 'max': 48},
  'demir': {'min': 60, 'max': 160},
  'b12vitamini': {'min': 200, 'max': 900},
  'folat': {'min': 3, 'max': 17},
  'transferrinsaturasyonu': {'min': 20, 'max': 50},
  'direktbilirubin': {'min': 0, 'max': 0.3},
  'indirektbilirubin': {'min': 0.2, 'max': 0.8},
  'aptt': {'min': 25, 'max': 35},
  'demirbaglamakapasitesi': {'min': 250, 'max': 400},
  'hba1c': {'min': 4, 'max': 6},
  // 'tamidrartetkiki' için referans yok, metinsel kontrol yapılabilir.
};

String analizEt(String param, dynamic deger) {
  final key = normalizeKey(param);
  
  // Metin tabanlı değerler için özel kontroller
  if (key == 'tamidrartetkiki' || key.contains('idrar') || param.toLowerCase().contains('idrar')) {
    if (deger == null) return 'Bilinmiyor';
    
    final degerStr = deger.toString().toLowerCase();
    
    // Normal durumlar
    if (degerStr.contains('normal') || 
        (degerStr.contains('negatif') && !degerStr.contains('pozitif'))) {
      return 'Normal';
    }
    
    // Anormal durumlar - pozitif bulgular varsa
    if (degerStr.contains('pozitif') || 
        degerStr.contains('+') || 
        degerStr.contains('eritrosit') || 
        degerStr.contains('lökosit') && !degerStr.contains('negatif')) {
      return 'Anormal';
    }
    
    return 'Bilinmiyor';
  }
  if (deger == null) return 'Bilinmiyor';
  final ref = referansAraliklari[key];
  if (ref == null) return '';
  final min = ref['min']!;
  final max = ref['max']!;
  final delta = (max - min) * 0.1;

  if (deger >= min && deger <= max) return 'Normal';
  if ((deger >= min - delta && deger < min) || (deger > max && deger <= max + delta)) return 'Sınırda';
  if (deger < min - delta) return 'Çok Düşük';
  if (deger > max + delta) return 'Çok Yüksek';
  return 'Bilinmiyor';
}

class TahlilAnalizSonuclariPage extends StatefulWidget {
  final Map<String, dynamic> tahlil;
  const TahlilAnalizSonuclariPage({Key? key, required this.tahlil}) : super(key: key);

  @override
  State<TahlilAnalizSonuclariPage> createState() => _TahlilAnalizSonuclariPageState();
}

class _TahlilAnalizSonuclariPageState extends State<TahlilAnalizSonuclariPage> {
  bool _isLoading = true;
  String _aiAnalysisResult = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }
  
  // API anahtarını kontrol et ve gerekirse dialog göster
  Future<void> _checkApiKey() async {
    final hasKey = await ApiKeyService.hasApiKey();
    if (!hasKey && mounted) {
      _showApiKeyDialog();
    } else {
      // API anahtarı varsa, otomatik olarak yapay zeka analizi yap
      _getAIAnalysis();
    }
  }
  
  // API anahtarı giriş dialog'unu göster
  void _showApiKeyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ApiKeyDialog(
        onApiKeySaved: (apiKey) async {
          await ApiKeyService.saveApiKey(apiKey);
          // Dialog kapandıktan sonra analizi tekrar başlat
          setState(() {
            _isLoading = true;
            _errorMessage = '';
          });
          _getAIAnalysis();
        },
      ),
    );
  }
  
  // Tahlil verilerini Gemini API için metin formatına dönüştür
  String _createAnalysisPrompt(Map<String, dynamic> tahlil) {
    final StringBuffer prompt = StringBuffer();
    
    // Hasta bilgilerini ekle
    final hastaAdi = tahlil['hasta_adi'] ?? 'Bilinmiyor';
    final hastaYasi = tahlil['hasta_yasi'] ?? 'Bilinmiyor';
    final hastaCinsiyet = tahlil['hasta_cinsiyet'] ?? 'Bilinmiyor';
    final hastaSikayet = tahlil['sikayet'] ?? 'Bilinmiyor';
    
    prompt.writeln('Hasta Adı: $hastaAdi');
    prompt.writeln('Yaş: $hastaYasi');
    prompt.writeln('Cinsiyet: $hastaCinsiyet');
    prompt.writeln('Ana Şikayet: $hastaSikayet');
    prompt.writeln('\nTAHLİL SONUÇLARI:');
    
    // JSON formatında tahlil sonuçlarını hazırla
    Map<String, dynamic> tahlilSonuclari = {};
    
    // Tahlil sonuçlarını ekle
    if (tahlil.containsKey('sonuclar') && tahlil['sonuclar'] is Map) {
      final sonuclar = tahlil['sonuclar'] as Map;
      sonuclar.forEach((parametre, deger) {
        prompt.writeln('$parametre: $deger');
        tahlilSonuclari[parametre] = deger;
      });
    } else {
      // Eski format için doğrudan tahlil map'ini kullan
      tahlil.forEach((parametre, deger) {
        if (parametre != 'hasta_adi' && parametre != 'hasta_yasi' && 
            parametre != 'hasta_cinsiyet' && parametre != 'sikayet') {
          prompt.writeln('$parametre: $deger');
          tahlilSonuclari[parametre] = deger;
        }
      });
    }
    
    // Yapay zeka için talimatları ekle
    prompt.writeln('\nLütfen bu tahlil sonuçlarını analiz et ve aşağıdaki bilgileri sağla:');
    prompt.writeln('1. Her tahlil değerinin durumunu belirt (Normal, Sınırda, Çok Düşük, Çok Yüksek)');
    prompt.writeln('2. Anormal değerler ve bunların anlamı');
    prompt.writeln('3. Olası tanılar veya sağlık sorunları');
    prompt.writeln('4. Önerilen ek testler veya kontroller');
    prompt.writeln('5. Genel sağlık durumu değerlendirmesi');
    prompt.writeln('\nAyrıca, her tahlil değerinin durumunu JSON formatında da döndür. Örnek format:');
    prompt.writeln('{"tahlil_durumlari": {"HGB": "Normal", "WBC": "Yüksek", "PLT": "Düşük"}}');
    prompt.writeln('\nYanıtını HTML formatında düzenle, böylece uygulama içinde daha iyi görüntülenebilir.');
    
    return prompt.toString();
  }

  // Tahlil durumlarını saklamak için map
  Map<String, String> _tahlilDurumlari = {};
  
  Future<void> _getAIAnalysis() async {
    if (kDebugMode) {
      print('AI analiz fonksiyonu BAŞLADI');
    }
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        // Tahlil durumlarını sıfırla
        _tahlilDurumlari = {};
      });

      // Gemini API'yi çağır
      String result = '';
      try {
        // 35 saniye zaman aşımı ile analiz fonksiyonunu çağır
        // Doğrudan GeminiAnalysisService'in API anahtarını kullan
        final apiKey = GeminiAnalysisService.defaultApiKey;
        final geminiService = GeminiAnalysisService(apiKey: apiKey);
        
        if (kDebugMode) {
          print('Kullanılan API anahtarı: $apiKey');
        }
        
        // Tahlil verilerini string'e dönüştür
        String tahlilPrompt = _createAnalysisPrompt(widget.tahlil);
        
        final response = await geminiService.analyze(tahlilPrompt).timeout(const Duration(seconds: 35), onTimeout: () => 'AI analiz zaman aşımına uğradı. Lütfen tekrar deneyin.');
        
        // HTML yanıtını temizle
        result = _cleanHtmlResponse(response);
        
        // JSON formatındaki tahlil durumlarını çıkar
        _extractTahlilDurumlari(result);
        
        if (kDebugMode) {
          print('AI analiz sonucu: $result');
          print('Tahlil durumları: $_tahlilDurumlari');
        }
      } catch (e) {
        result = 'AI analiz sırasında beklenmeyen bir hata oluştu: $e';
        if (kDebugMode) {
          print('AI analiz HATA: $e');
        }
      }
      if (mounted) {
        setState(() {
          if (result.startsWith('AI analiz zaman aşımına uğradı') || result.startsWith('AI analiz sırasında beklenmeyen bir hata oluştu')) {
            _errorMessage = result;
            _aiAnalysisResult = '';
          } else {
            _aiAnalysisResult = result;
            _errorMessage = '';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('AI analiz hatası: $e');
      }
      if (mounted) {
        setState(() {
          _errorMessage = 'Analiz sırasında bir hata oluştu: $e';
          _isLoading = false;
        });
      }
    }
    // Fallback: Eğer 40 saniye sonra hala _isLoading true ise kullanıcıya uyarı göster
    Future.delayed(const Duration(seconds: 40), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'AI analizden yanıt alınamadı. Lütfen internet bağlantınızı ve API anahtarınızı kontrol edin.';
        });
      }
    });
    if (kDebugMode) {
      print('AI analiz fonksiyonu BİTTİ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.tahlil.entries.toList();


    return Scaffold(
      appBar: AppBar(
        title: const Text('Son Tahlil Sonuçları', style: TextStyle(fontWeight: FontWeight.w600)), 
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
            ),
          ),
        ),
        elevation: 2,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF00ACC1),
                elevation: 3,
                shadowColor: Colors.black38,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              icon: const Icon(Icons.analytics, size: 18),
              label: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00ACC1)),
                    )
                  : const Text('AI ile Analiz Et', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.3)),
              onPressed: _isLoading ? null : () async {
                // Yeniden analiz yap
                await _getAIAnalysis();
                
                // Analiz işlemi tamamlandı, UI güncellemesi için mounted kontrolü
                if (!mounted) return;
                
                // Hata durumunu ve sonucu yerel değişkenlere al
                final errorMessage = _errorMessage;
                final isError = errorMessage.isNotEmpty;
                
                // Sadece hata durumunda dialog göster
                if (isError) {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('Hata', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      content: Text(errorMessage),
                      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Tamam'))],
                    ),
                  );
                } else {
                  // Başarılı analiz durumunda sadece bir bildirim göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tahlil analizi başarıyla güncellendi'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final key = entries[index].key;
            final value = entries[index].value;
            
            // Hasta bilgilerini atla
            if (key == 'hasta_adi' || key == 'hasta_yasi' || key == 'hasta_cinsiyet' || key == 'sikayet') {
              return const SizedBox.shrink(); // Boş widget döndür
            }
            
            // Öncelikle yapay zekadan gelen durumu kullan
            String analiz = '';
            if (_tahlilDurumlari.containsKey(key.toUpperCase())) {
              analiz = _tahlilDurumlari[key.toUpperCase()]!;
            } else {
              // Yapay zeka analizi yoksa, referans aralıklarına göre basit analiz yap
              if (_isLoading) {
                analiz = "Analiz ediliyor...";
              } else {
                final normalizedKey = normalizeKey(key);
                
                // Önce sayısal değer olarak deneyip referans aralıklarını kontrol et
                final deger = double.tryParse(value.toString());
                if (referansAraliklari.containsKey(normalizedKey) && deger != null) {
                  analiz = analizEt(key, deger);
                } 
                // Sayısal değilse veya referans aralığı yoksa, metin tabanlı analiz dene
                else if (key.contains('idrar') || key.toLowerCase().contains('idrar') || 
                         key == 'tamidrartetkiki' || key.contains('tetkik')) {
                  analiz = analizEt(key, value);
                } else {
                  analiz = "Bilinmiyor";
                }
              }
            }
            
            Color renk;
            IconData statusIcon;
            
            // Yapay zekadan gelen durum metinleri farklı olabilir, bu yüzden içerik kontrolü yap
            if (analiz.toLowerCase() == 'normal') {
              renk = Colors.green.shade700;
              statusIcon = Icons.check_circle;
            } else if (analiz.toLowerCase().contains('sınırda') || 
                       analiz.toLowerCase().contains('sinirda') ||
                       analiz.toLowerCase().contains('sınır') ||
                       analiz.toLowerCase().contains('sinir')) {
              renk = Colors.amber.shade700;
              statusIcon = Icons.warning_amber_rounded;
            } else if (analiz.toLowerCase().contains('anormal')) {
              renk = Colors.purple.shade700;
              statusIcon = Icons.error_outline;
            } else if (analiz.toLowerCase().contains('düşük') || 
                       analiz.toLowerCase().contains('dusuk') || 
                       analiz.toLowerCase().contains('yüksek') || 
                       analiz.toLowerCase().contains('yuksek')) {
              renk = Colors.red.shade700;
              statusIcon = Icons.error;
            } else {
              // Varsayılan olarak normal kabul et
              renk = Colors.green.shade700;
              statusIcon = Icons.check_circle;
            }
            
            return Card(
              elevation: 2,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    // Parametre adı ve değeri
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '').join(' '),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Değer: $value',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Durum
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: renk.withAlpha(26),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: renk.withAlpha(77), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: renk, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            analiz.isNotEmpty ? analiz : 'Bilinmiyor',
                            style: TextStyle(
                              color: renk,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  // HTML yanıtını temizle ve düzgün formata getir
  String _cleanHtmlResponse(String response) {
    // Eğer yanıt HTML içeriyorsa
    if (response.contains('<html') || response.contains('html>') || 
        response.contains('"html') || response.contains('\'html') || 
        response.contains('`html')) {
      
      try {
        // HTML etiketlerini temizle
        response = response.replaceAll(RegExp(r'<[^>]*>'), '');
      } catch (e) {
        debugPrint('HTML temizleme hatası: $e');
      }
      
      // Tırnak işaretlerini ve kaçış karakterlerini temizle
      response = response.replaceAll('"', '');
      response = response.replaceAll('\'', '');
      response = response.replaceAll('`', '');
      response = response.replaceAll('\\n', '');
      
      // HTML başlangıç ve bitiş etiketlerini düzelt
      if (!response.contains('<html') && response.contains('html')) {
        response = response.replaceAll('html', '<html>');
      }
      
      // HTML başlangıcını düzelt
      if (response.startsWith('<html') && !response.startsWith('<html>')) {
        response = response.replaceFirst('<html', '<html>');
      }
      
      // HTML sonunu düzelt
      if (response.contains('</html') && !response.contains('</html>')) {
        response = response.replaceAll('</html', '</html>');
      }
      
      // Tam bir HTML belgesi oluştur
      if (!response.contains('<html>')) {
        response = '<html><head><meta charset="UTF-8"><style>body{font-family:sans-serif;line-height:1.5;} h1{color:#00838F;} h2{color:#0097A7;} .yuksek{color:red;} .dusuk{color:blue;} .sinirda{color:orange;} .normal{color:green;}</style></head><body>' + response + '</body></html>';
      }
    }
    
    return response;
  }
  
  // Yapay zeka yanıtından tahlil durumlarını çıkar
  void _extractTahlilDurumlari(String response) {
      if (kDebugMode) {
        print('Tahlil durumları çıkarılıyor...');
        print('Yanıt: ${response.substring(0, min(200, response.length))}...');
      }
      
      // Basit bir çözüm: Tüm tahlil parametrelerini manuel olarak kontrol et
      // ve her biri için durumu belirle
      final entries = widget.tahlil.entries.toList();
      for (final entry in entries) {
        final key = entry.key;
        
        // Hasta bilgileri ve diğer meta verileri atla
        if (key == 'hasta_adi' || key == 'hasta_yasi' || key == 'hasta_cinsiyet' || 
            key == 'sikayet' || key == 'id' || key == 'tarih' || key == 'doktor') {
          continue;
        }
        
        // Önce yanıtta bu parametre için bir durum olup olmadığını kontrol et
        final normalPattern = RegExp('$key.*?normal', caseSensitive: false);
        final yuksekPattern = RegExp('$key.*?yüksek|$key.*?yuksek', caseSensitive: false);
        final dusukPattern = RegExp('$key.*?düşük|$key.*?dusuk', caseSensitive: false);
        final sinirdaPattern = RegExp('$key.*?sınırda|$key.*?sinirda|$key.*?sınır değerlerde|$key.*?sinir degerlerde', caseSensitive: false);
        
        // Referans aralıkları kontrol et
        final normalizedKey = normalizeKey(key);
        final ref = referansAraliklari[normalizedKey];
        final deger = double.tryParse(entry.value.toString());
        
        if (ref != null && deger != null) {
          // Referans aralığı varsa, değeri kontrol et
          final min = ref['min']!;
          final max = ref['max']!;
          final delta = (max - min) * 0.1; // %10 tolerans
          
          if (deger >= min && deger <= max) {
            _tahlilDurumlari[key] = 'Normal';
          } else if ((deger >= min - delta && deger < min) || (deger > max && deger <= max + delta)) {
            _tahlilDurumlari[key] = 'Sınırda';
          } else if (deger < min - delta) {
            _tahlilDurumlari[key] = 'Düşük';
          } else if (deger > max + delta) {
            _tahlilDurumlari[key] = 'Yüksek';
          }
        } else {
          // Referans aralığı yoksa, yanıt içeriğini kontrol et
          if (normalPattern.hasMatch(response)) {
            _tahlilDurumlari[key] = 'Normal';
          } else if (yuksekPattern.hasMatch(response)) {
            _tahlilDurumlari[key] = 'Yüksek';
          } else if (dusukPattern.hasMatch(response)) {
            _tahlilDurumlari[key] = 'Düşük';
          } else if (sinirdaPattern.hasMatch(response)) {
            _tahlilDurumlari[key] = 'Sınırda';
          // Referans aralıkları kontrol et
          final normalizedKey = normalizeKey(key);
          final ref = referansAraliklari[normalizedKey];
          final deger = double.tryParse(entry.value.toString());
          
          if (ref != null && deger != null) {
            // Referans aralığı varsa, değeri kontrol et
            final min = ref['min']!;
            final max = ref['max']!;
            final delta = (max - min) * 0.1; // %10 tolerans
            
            if (deger >= min && deger <= max) {
              _tahlilDurumlari[key] = 'Normal';
            } else if ((deger >= min - delta && deger < min) || (deger > max && deger <= max + delta)) {
              _tahlilDurumlari[key] = 'Sınırda';
            } else if (deger < min - delta) {
              _tahlilDurumlari[key] = 'Düşük';
            } else if (deger > max + delta) {
              _tahlilDurumlari[key] = 'Yüksek';
            }
          } else {
            // Referans aralığı yoksa, yanıt içeriğini kontrol et
            if (normalPattern.hasMatch(response)) {
              _tahlilDurumlari[key] = 'Normal';
            } else if (yuksekPattern.hasMatch(response)) {
              _tahlilDurumlari[key] = 'Yüksek';
            } else if (dusukPattern.hasMatch(response)) {
              _tahlilDurumlari[key] = 'Düşük';
            } else if (sinirdaPattern.hasMatch(response)) {
              _tahlilDurumlari[key] = 'Sınırda';
            } else {
              // Eğer hiçbir durum bulunamazsa, varsayılan olarak 'Normal' kabul et
              _tahlilDurumlari[key] = 'Normal';
            }
          }
        }
      }
      
      // JSON formatındaki tahlil durumlarını ara (eski yöntem)
      try {
        RegExp jsonRegex = RegExp(r'\{\s*"tahlil_durumlari"\s*:\s*\{[^\}]*\}\s*\}');
        Match? match = jsonRegex.firstMatch(response);
        
        if (match != null) {
          String jsonStr = match.group(0) ?? '';
          
          // JSON string'i temizle
          jsonStr = jsonStr.replaceAll("'", '"');
          jsonStr = jsonStr.replaceAll('\\"', '"');
          
          // JSON'u parse et
          Map<String, dynamic> jsonData = jsonDecode(jsonStr);
          
          if (jsonData.containsKey('tahlil_durumlari')) {
            Map<String, dynamic> durumlar = jsonData['tahlil_durumlari'];
            
            // Tahlil durumlarını güncelle
            durumlar.forEach((key, value) {
              if (value is String) {
                _tahlilDurumlari[key.toUpperCase()] = value;
              }
            });
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('JSON parse hatası (beklenen bir durum): $e');
        }
      }
      
      if (kDebugMode) {
        print('Tahlil durumları çıkarıldı: $_tahlilDurumlari');
      }
    }
  }
  // Bu metod artık kullanılmıyor
}
