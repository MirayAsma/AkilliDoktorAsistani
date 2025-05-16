import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tahlil_analiz_sonuclari_page.dart';
import 'package:akilli_doktor_asistani/services/gemini_api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:akilli_doktor_asistani/services/api_key_service.dart';

// Alanların sıralı ve eksiksiz gelmesi için kullanılacak sıra listesi
final List<String> dataOrder = [
  'ad_soyad',
  'yas',
  'cinsiyet',
  'basvuru_sikayeti',
  'ameliyat',
  'patoloji',
  'dogum_oykusu',
  'tansiyon',
  'nabiz',
  'ates',
  'onceki_tedavi',
  'uyari',
  'son_lab_tetkik',
  'son_goruntuleme',
  'onceki_basvurular',
  'onceki_tetkik',
  'onceki_goruntuleme',
];

class TahlilAnalizRaporuPage extends StatelessWidget {
  final String hastaId;
  
  const TahlilAnalizRaporuPage({Key? key, required this.hastaId}) : super(key: key);

  // DEBUG: HastaId'yi kolayca görebilmek için getter
  String get debugHastaId => hastaId;
  
  // Yapay Zeka analizi için dialog gösterme metodu
  void _showAIAnalysisDialog(BuildContext context, Map<String, dynamic> hastaVerileri) async {
    bool isLoading = true;
    String resultText = '';
    bool hasError = false;
    
    // API anahtarını kontrol et
    final apiKey = await ApiKeyService.getApiKey();
    
    if (apiKey == null || apiKey.isEmpty) {
      // API anahtarı yoksa kullanıcıya bildir
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gemini API anahtarı bulunamadı. Lütfen ayarlardan ekleyin.')),
        );
      }
      return;
    }
    
    // Dialog'u göster
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setState) {
            // Analiz işlemini başlat
            if (isLoading && resultText.isEmpty) {
              _performAIAnalysis(hastaVerileri).then((result) {
                if (context.mounted) {
                  setState(() {
                    resultText = result;
                    isLoading = false;
                  });
                }
              }).catchError((error) {
                if (context.mounted) {
                  setState(() {
                    resultText = 'Hata: ${error.toString()}';
                    isLoading = false;
                    hasError = true;
                  });
                }
              });
            }
            
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.psychology, color: Colors.purple.shade600),
                  const SizedBox(width: 10),
                  const Text('Yapay Zeka Analizi'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hasta bilgileri özeti
                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${hastaVerileri['ad_soyad']}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${hastaVerileri['yas']} yaş, ${hastaVerileri['cinsiyet']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Şikayet: ${hastaVerileri['basvuru_sikayeti']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Yükleniyor veya sonuç
                      if (isLoading)
                        Center(
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              const Text('Yapay zeka analizi yapılıyor...'),
                              const SizedBox(height: 8),
                              Text(
                                'Hasta verileri ve tahlil sonuçları işleniyor',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      else if (hasError)
                        Text(
                          resultText,
                          style: const TextStyle(color: Colors.red),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildAnalysisResults(resultText),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kapat'),
                ),
              ],
            );
          },
        ),
      );
    }
  }
  
  // Yapay zeka analizi yapma metodu
  Future<String> _performAIAnalysis(Map<String, dynamic> hastaVerileri) async {
    try {
      // API anahtarını al
      final String apiKey = await ApiKeyService.getApiKey() ?? '';
      
      if (apiKey.isEmpty) {
        return 'API anahtarı bulunamadı. Lütfen ayarlardan bir API anahtarı ekleyin.';
      }
      
      // Tahlil sonuçlarını al
      final labResults = hastaVerileri['son_lab_tetkik'];
      String labResultsStr = '';
      
      // Tahlil sonuçlarını string'e çevir
      if (labResults is Map) {
        labResults.forEach((key, value) {
          labResultsStr += '$key: $value\n';
        });
      } else {
        labResultsStr = labResults?.toString() ?? 'Tahlil sonucu yok';
      }
      
      // Hasta bilgilerini hazırla
      final adSoyad = hastaVerileri['ad_soyad'] ?? 'Bilinmiyor';
      final yas = hastaVerileri['yas']?.toString() ?? 'Bilinmiyor';
      final cinsiyet = hastaVerileri['cinsiyet'] ?? 'Bilinmiyor';
      final sikayet = hastaVerileri['basvuru_sikayeti'] ?? 'Bilinmiyor';
      
      // GeminiApiService'i kullanarak analiz yap
      final geminiApiService = GeminiApiService(apiKey);
      
      // Hasta verilerini hazırla
      final Map<String, dynamic> patientData = {
        'ad_soyad': adSoyad,
        'yas': yas,
        'cinsiyet': cinsiyet,
        'basvuru_sikayeti': sikayet,
        'son_lab_tetkik': labResultsStr,
      };
      
      final result = await geminiApiService.analyzePatientData(patientData);
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('AI Analysis Error: $e');
      }
      throw Exception('Yapay zeka analizi sırasında bir hata oluştu: $e');
    }
  }
  
  // Analiz sonuçlarını görsel olarak oluşturma
  List<Widget> _buildAnalysisResults(String resultText) {
    // Sonuç boşsa
    if (resultText.isEmpty) {
      return [const Text('Sonuç bulunamadı')];
    }
    
    // HTML yanıtı içeriyor mu kontrol et
    if (resultText.contains('<table>')) {
      return [_buildHtmlResultCard(resultText)];
    }
    
    // Sonucu satırlara ayır
    final lines = resultText.split('\n');
    final widgets = <Widget>[];
    
    // Başlık ve içerik için geçici değişkenler
    String? currentTitle;
    List<String> currentContent = [];
    
    // Her satırı işle
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      // Başlık satırı mı kontrol et (başında # veya * olan satırlar başlık olarak kabul edilir)
      if (line.startsWith('#') || line.startsWith('*') || line.startsWith('-')) {
        // Önceki başlık ve içeriği ekle
        if (currentTitle != null && currentContent.isNotEmpty) {
          widgets.add(_buildCategoryCard(currentTitle, currentContent.join('\n')));
          currentContent = [];
        }
        
        // Yeni başlık
        currentTitle = line.replaceAll(RegExp(r'^[#*-]\s*'), '');
      } else {
        // İçerik satırı
        if (currentTitle != null) {
          currentContent.add(line);
        } else {
          // Başlık yoksa, ilk satırı başlık olarak kullan
          currentTitle = 'Analiz Sonucu';
          currentContent.add(line);
        }
      }
    }
    
    // Son başlık ve içeriği ekle
    if (currentTitle != null && currentContent.isNotEmpty) {
      widgets.add(_buildCategoryCard(currentTitle, currentContent.join('\n')));
    }
    
    // Hiç kart oluşturulmadıysa, tüm metni tek bir kart olarak göster
    if (widgets.isEmpty) {
      widgets.add(_buildCategoryCard('Analiz Sonucu', resultText));
    }
    
    return widgets;
  }
  
  // HTML yanıtını işleyip gösteren kart
  Widget _buildHtmlResultCard(String htmlContent) {
    // HTML yanıtını basit bir şekilde işleyerek gösterelim
    // HTML içeriğini analiz edip düzenli bir şekilde gösterme
    
    // Tablo başlıklarını ve içeriğini ayıklama
    final tableRows = _extractTableRows(htmlContent);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Yapay Zeka Analizi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            // Tablo içeriğini gösterme
            ...tableRows,
          ],
        ),
      ),
    );
  }
  
  // HTML tablosundan satırları ayıklama
  List<Widget> _extractTableRows(String htmlContent) {
    final List<Widget> rows = [];
    
    try {
      // Basit bir şekilde tablo içeriğini işleyelim
      // Tablo satırlarını ayıkla
      final tableRows = htmlContent.split('</tr>');
      
      // İlk satır genellikle başlık olduğu için atla
      for (int i = 1; i < tableRows.length; i++) {
        final row = tableRows[i];
        
        // Hücreleri ayıkla
        final cells = row.split('</td>');
        
        if (cells.length >= 2) {
          // İlk hücre başlık, ikinci hücre içerik
          String titleCell = cells[0];
          String contentCell = cells[1];
          
          // <td> etiketlerini kaldır
          titleCell = titleCell.replaceAll('<tr>', '').replaceAll('<td>', '');
          contentCell = contentCell.replaceAll('<td>', '');
          
          // HTML etiketlerini temizle
          String title = _cleanHtmlTags(titleCell);
          String content = _cleanHtmlTags(contentCell);
          
          // Başlığa göre renk ve ikon belirleme
          Color cardColor = Colors.blue.shade50;
          IconData cardIcon = Icons.info_outline;
          
          if (title.toLowerCase().contains('anormal')) {
            cardColor = Colors.red.shade50;
            cardIcon = Icons.warning_amber_outlined;
          } else if (title.toLowerCase().contains('olası tanı')) {
            cardColor = Colors.purple.shade50;
            cardIcon = Icons.medical_services_outlined;
          } else if (title.toLowerCase().contains('tedavi')) {
            cardColor = Colors.amber.shade50;
            cardIcon = Icons.healing;
          } else if (title.toLowerCase().contains('uyar')) {
            cardColor = Colors.orange.shade50;
            cardIcon = Icons.warning;
          }
          
          // Kart oluşturma
          rows.add(
            Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(cardIcon, color: cardColor.withAlpha(255).withBlue(150)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(
                      content,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('HTML işleme hatası: $e');
      }
    }
    
    // Hiç satır bulunamazsa, tüm HTML içeriğini göster
    if (rows.isEmpty) {
      rows.add(
        Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              _cleanHtmlTags(htmlContent),
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ),
      );
    }
    
    return rows;
  }
  
  // HTML etiketlerini temizleme
  String _cleanHtmlTags(String html) {
    if (html.isEmpty) return '';
    
    try {
      // <b> ve </b> etiketlerini kaldırma
      String cleaned = html.replaceAll('<b>', '').replaceAll('</b>', '');
      
      // span etiketlerini özel olarak işle
      cleaned = cleaned.replaceAll('<span style="color:green">', '(+) ');
      cleaned = cleaned.replaceAll('<span style="color:yellow">', '(!) ');
      cleaned = cleaned.replaceAll('<span style="color:red">', '(-) ');
      cleaned = cleaned.replaceAll('</span>', '');
      
      // Diğer HTML etiketlerini kaldırma
      cleaned = cleaned.replaceAll(RegExp('<[^>]*>'), '');
      
      // HTML karakter kodlarını dönüştürme
      cleaned = cleaned.replaceAll('&nbsp;', ' ');
      cleaned = cleaned.replaceAll('&lt;', '<');
      cleaned = cleaned.replaceAll('&gt;', '>');
      cleaned = cleaned.replaceAll('&amp;', '&');
      cleaned = cleaned.replaceAll('&quot;', '"');
      
      return cleaned.trim();
    } catch (e) {
      if (kDebugMode) {
        print('HTML temizleme hatası: $e');
      }
      return html;
    }
  }
  
  // Kategori kartı oluşturma
  Widget _buildCategoryCard(String title, String content) {
    // Başlığa göre renk ve emoji seç
    Color cardColor = Colors.blue.shade100;
    IconData cardIcon = Icons.info_outline;
    
    // Başlık içeriğine göre renk ve ikon belirle
    if (title.toLowerCase().contains('normal') || 
        title.toLowerCase().contains('sağlıklı')) {
      cardColor = Colors.green.shade100;
      cardIcon = Icons.check_circle_outline;
    } else if (title.toLowerCase().contains('anormal') || 
               title.toLowerCase().contains('yüksek') || 
               title.toLowerCase().contains('düşük') || 
               title.toLowerCase().contains('risk')) {
      cardColor = Colors.red.shade100;
      cardIcon = Icons.warning_amber_outlined;
    } else if (title.toLowerCase().contains('öneri') || 
               title.toLowerCase().contains('tavsiye')) {
      cardColor = Colors.amber.shade100;
      cardIcon = Icons.lightbulb_outline;
    } else if (title.toLowerCase().contains('tanı') || 
               title.toLowerCase().contains('teşhis')) {
      cardColor = Colors.purple.shade100;
      cardIcon = Icons.medical_services_outlined;
    }
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(cardIcon, color: cardColor.withAlpha(255).withBlue(150)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(
              content,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  // Tekil ve doğru tanımlı fonksiyon
  Future<Map<String, dynamic>> _fetchHastaDetay(String hastaId) async {
    try {
      // print('Hasta detayı çekiliyor. Hasta ID: $hastaId');
      
      // Hasta ID boşsa, test verilerini döndür
      if (hastaId.isEmpty) {
        // print('Hasta ID boş, test verileri döndürülüyor');
        return {
          'ad_soyad': 'Test Hasta',
          'yas': 35,
          'cinsiyet': 'Erkek',
          'son_lab_tetkik': {'HGB': 12, 'WBC': 6000, 'PLT': 200000, 'Kreatinin': 1.0, 'Glukoz': 100},
          'basvuru_sikayeti': 'Test şikayeti',
          'ameliyat': 'Yok',
          'patoloji': 'Normal',
          'dogum_oykusu': 'Yok',
          'tansiyon': '120/80 mmHg',
          'nabiz': '72',
          'ates': '36.5',
          'onceki_tedavi': 'Yok',
          'uyari': 'Yok',
          'son_goruntuleme': 'Yok',
          'onceki_basvurular': 'Yok',
          'onceki_tetkik': 'Yok',
          'onceki_goruntuleme': 'Yok'
        };
      }
      
      try {
        // Firebase'den veri çekme
        final doc = await FirebaseFirestore.instance.collection('cases').doc(hastaId).get();
        
        // Doküman var mı kontrol et
        if (!doc.exists) {
          // print('Vaka bulunamadı: $hastaId');
          // Test verisi döndür
          return {
            'ad_soyad': 'Test Hasta (ID: $hastaId)',
            'yas': 35,
            'cinsiyet': 'Erkek',
            'son_lab_tetkik': {'HGB': 12, 'WBC': 6000, 'PLT': 200000, 'Kreatinin': 1.0, 'Glukoz': 100},
            'basvuru_sikayeti': 'Test şikayeti',
            'ameliyat': 'Yok',
            'patoloji': 'Normal',
            'dogum_oykusu': 'Yok',
            'tansiyon': '120/80 mmHg',
            'nabiz': '72',
            'ates': '36.5',
            'onceki_tedavi': 'Yok',
            'uyari': 'Yok',
            'son_goruntuleme': 'Yok',
            'onceki_basvurular': 'Yok',
            'onceki_tetkik': 'Yok',
            'onceki_goruntuleme': 'Yok'
          };
        }
        
        final data = doc.data()!;
        // print('Veri başarıyla çekildi: ${data.toString()}');
        
        // DEBUG: Çekilen hastaId ve veri
        // ignore: avoid_print
        print('[DEBUG] Firestore hastaId: $hastaId, data: ${data.toString()}');
        // Eksik alanları tamamla
        final Map<String, dynamic> completeData = {...data};
        
        // Zorunlu alanları kontrol et ve eksikse ekle
        final requiredFields = [
          'ad_soyad', 'yas', 'cinsiyet', 'basvuru_sikayeti', 'ameliyat',
          'patoloji', 'dogum_oykusu', 'tansiyon', 'nabiz', 'ates',
          'onceki_tedavi', 'uyari', 'son_lab_tetkik', 'son_goruntuleme',
          'onceki_basvurular', 'onceki_tetkik', 'onceki_goruntuleme'
        ];
        
        for (final field in requiredFields) {
          if (!completeData.containsKey(field)) {
            // print('Eksik alan tamamlanıyor: $field');
            if (field == 'son_lab_tetkik') {
              completeData[field] = {'HGB': 'Veri yok', 'WBC': 'Veri yok', 'PLT': 'Veri yok'};
            } else {
              completeData[field] = 'Veri yok';
            }
          }
        }
        
        return completeData;
      } catch (e) {
        // print('Firebase hatası: $e');
        // Test verisi döndür
        return {
          'ad_soyad': 'Test Hasta (Hata)',
          'yas': 35,
          'cinsiyet': 'Erkek',
          'son_lab_tetkik': {'HGB': 12, 'WBC': 6000, 'PLT': 200000, 'Kreatinin': 1.0, 'Glukoz': 100},
          'basvuru_sikayeti': 'Test şikayeti',
          'ameliyat': 'Yok',
          'patoloji': 'Normal',
          'dogum_oykusu': 'Yok',
          'tansiyon': '120/80 mmHg',
          'nabiz': '72',
          'ates': '36.5',
          'onceki_tedavi': 'Yok',
          'uyari': 'Yok',
          'son_goruntuleme': 'Yok',
          'onceki_basvurular': 'Yok',
          'onceki_tetkik': 'Yok',
          'onceki_goruntuleme': 'Yok'
        };
      }
    } catch (e) {
      // print('Genel hata: $e');
      // Test verisi döndür
      return {
        'ad_soyad': 'Test Hasta (Genel Hata)',
        'yas': 35,
        'cinsiyet': 'Erkek',
        'son_lab_tetkik': {'HGB': 12, 'WBC': 6000, 'PLT': 200000, 'Kreatinin': 1.0, 'Glukoz': 100},
        'basvuru_sikayeti': 'Test şikayeti',
        'ameliyat': 'Yok',
        'patoloji': 'Normal',
        'dogum_oykusu': 'Yok',
        'tansiyon': '120/80 mmHg',
        'nabiz': '72',
        'ates': '36.5',
        'onceki_tedavi': 'Yok',
        'uyari': 'Yok',
        'son_goruntuleme': 'Yok',
        'onceki_basvurular': 'Yok',
        'onceki_tetkik': 'Yok',
        'onceki_goruntuleme': 'Yok'
      };
    }
  }

  // Anahtarı düzenli formata çevirme
  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
        .join(' ');
  }
  
  // Her alan için ikon belirle
  IconData _getIconForField(String field) {
    switch (field) {
      case 'ad_soyad': return Icons.person;
      case 'yas': return Icons.cake;
      case 'cinsiyet': return Icons.wc;
      case 'basvuru_sikayeti': return Icons.medical_information;
      case 'ameliyat': return Icons.local_hospital;
      case 'patoloji': return Icons.science;
      case 'dogum_oykusu': return Icons.child_friendly;
      case 'tansiyon': return Icons.monitor_heart;
      case 'nabiz': return Icons.favorite;
      case 'ates': return Icons.thermostat;
      case 'onceki_tedavi': return Icons.medication;
      case 'uyari': return Icons.warning;
      case 'son_lab_tetkik': return Icons.biotech;
      case 'son_goruntuleme': return Icons.image;
      case 'onceki_basvurular': return Icons.history;
      case 'onceki_tetkik': return Icons.analytics;
      case 'onceki_goruntuleme': return Icons.image_search;
      default: return Icons.info;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasta Detayı'),
        backgroundColor: Colors.cyan,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchHastaDetay(hastaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Test verileri - her durumda görüntülenecek
          final testData = {
            'ad_soyad': 'Test Hasta',
            'yas': 35,
            'cinsiyet': 'Erkek',
            'son_lab_tetkik': {'HGB': 12, 'WBC': 6000, 'PLT': 200000, 'Kreatinin': 1.0, 'Glukoz': 100},
            'basvuru_sikayeti': 'Test şikayeti',
            'ameliyat': 'Yok',
            'patoloji': 'Normal',
            'dogum_oykusu': 'Yok',
            'tansiyon': '120/80 mmHg',
            'nabiz': '72',
            'ates': '36.5',
            'onceki_tedavi': 'Yok',
            'uyari': 'Yok',
            'son_goruntuleme': 'Yok',
            'onceki_basvurular': 'Yok',
            'onceki_tetkik': 'Yok',
            'onceki_goruntuleme': 'Yok'
          };
          
          // Firebase'den veri gelmediyse test verilerini kullan
          Map<String, dynamic> data = testData;
          
          // Firebase'den veri geldiyse onu kullan
          if (snapshot.hasData && snapshot.data != null) {
            data = snapshot.data!;
            // print('Firebase verisi kullanılıyor: $data');
          } else if (snapshot.hasError) {
            // print('Hata oluştu, test verisi kullanılıyor: ${snapshot.error}');
          } else {
            // print('Veri yok, test verisi kullanılıyor');
          }
          
          // Veri sıralaması
          final dataOrder = [
            'ad_soyad',
            'yas',
            'cinsiyet',
            'basvuru_sikayeti',
            'ameliyat',
            'patoloji',
            'dogum_oykusu',
            'tansiyon',
            'nabiz',
            'ates',
            'onceki_tedavi',
            'uyari',
            'son_lab_tetkik',
            'son_goruntuleme',
            'onceki_basvurular',
            'onceki_tetkik',
            'onceki_goruntuleme'
          ];
          
          final widgets = <Widget>[];
          
          // Hasta adı kısmını tamamen kaldırdık, çünkü altta zaten gösteriliyor
          
          // Sıralamaya göre verileri ekle
          for (final key in dataOrder) {
            // "onceki_tetkik" için, eğer yoksa otomatik olarak "son_lab_tetkik" gösterilsin
            if (key == 'onceki_tetkik' && data.containsKey(key)) {
              final value = data[key];
              
              if (value is Map && value.isNotEmpty) {
                widgets.add(
                  Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.cyan.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Önceki Laboratuvar Tetkik Sonuçları',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.cyan),
                          ),
                          const Divider(color: Colors.cyan),
                          const SizedBox(height: 12),
                          ...value.entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    _formatKey(e.key.toString()),
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '${e.value}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                  ),
                );
                continue;
              }
            }
            if (data.containsKey(key)) {
              final value = data[key];
              
              // Lab tetkik sonuçları için özel işlem
              if (key == 'son_lab_tetkik' && value is Map) {
                widgets.add(
                  Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: Colors.cyan.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Son Laboratuvar Tetkik Sonuçları',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.cyan),
                          ),
                          const Divider(color: Colors.cyan),
                          const SizedBox(height: 12),
                          ...value.entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _formatKey(e.key.toString()),
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${e.value}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                // Normal alanlar için
                widgets.add(
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Alan adı ve ikonu
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Icon(_getIconForField(key), color: Colors.cyan, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formatKey(key),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: key.contains('goruntuleme') ? 14 : 16
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Alan değeri
                          Expanded(
                            flex: 3,
                            child: Text(
                              key == 'onceki_tetkik' && (value is Map && value.isEmpty) ? 'yok' : (value?.toString() ?? 'Veri yok'),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }
          }
          
          // Hata varsa ekrana uyarı mesajı göster
          if (snapshot.hasError) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Hata oluştu: ${snapshot.error}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            );
          }
          
          return ListView(
            padding: const EdgeInsets.all(20),
            children: widgets,
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Yapay Zeka Analiz Butonu
              FloatingActionButton.extended(
                heroTag: 'ai_analysis',
                onPressed: () async {
                  // Hasta verilerini al
                  final hastaVerileri = await _fetchHastaDetay(hastaId);
                  // Yapay zeka analizi için dialog'u göster
                  _showAIAnalysisDialog(context, hastaVerileri);
                },
                backgroundColor: Colors.purple.shade600,
                label: const Text('Yapay Zeka Analizi'),
                icon: const Icon(Icons.psychology),
              ),
              const SizedBox(width: 16),
              // Tahlil Analiz Butonu
              FloatingActionButton(
                heroTag: 'tahlil_analiz',
                onPressed: () {
                  // Kapsamlı test veri seti - tüm değerleri içeriyor
                  // Bazıları normal, bazıları sınırda, bazıları anormal
                  final sonTetkik = {
                    // Normal değerler
                    'HGB': 14.2,                       // Normal (12-16)
                    'WBC': 7500,                       // Normal (4000-10000)
                    'PLT': 250000,                     // Normal (150000-450000)
                    'Kreatinin': 0.9,                  // Normal (0.6-1.2)
                    'Glukoz': 95,                      // Normal (70-110)
                    'Ferritin': 150,                   // Normal (15-200)
                    'Demir': 80,                       // Normal (60-160)
                    
                    // Sınırda değerler
                    'MCV': 78,                         // Sınırda düşük (80-100)
                    'Kalsiyum': 8.3,                   // Sınırda düşük (8.5-10.5)
                    'Potasyum': 5.2,                   // Sınırda yüksek (3.5-5.1)
                    'Folat': 2.8,                      // Sınırda düşük (3-17)
                    'APTT': 36,                        // Sınırda yüksek (25-35)
                    
                    // Anormal değerler
                    'ALT': 65,                         // Yüksek (0-40)
                    'AST': 70,                         // Yüksek (0-40)
                    'GGT': 75,                         // Yüksek (9-48)
                    'Amilaz': 120,                     // Yüksek (28-100)
                    'Lipaz': 100,                      // Yüksek (8-78)
                    'Üre': 60,                         // Yüksek (10-50)
                    'Direkt bilirubin': 0.5,           // Yüksek (0-0.3)
                    'İndirekt bilirubin': 1.2,        // Yüksek (0.2-0.8)
                    'Sodyum': 130,                     // Düşük (135-145)
                    'Demir bağlama kapasitesi': 450,  // Yüksek (250-400)
                    'B12 vitamini': 180,               // Düşük (200-900)
                    'Vitamin D3': 15,                  // Düşük (20-50)
                    'INR': 1.5,                        // Yüksek (0.8-1.2)
                    'Tam idrar tetkiki': 'Lökosit (+), Eritrosit (+), Protein (+)'  // Anormal
                  };
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TahlilAnalizSonuclariPage(tahlil: sonTetkik),
                    ),
                  );
                },
                backgroundColor: Colors.cyan,
                child: const Icon(Icons.analytics),
              ),
            ],
          );
        },
      ),
    );
  }
}
