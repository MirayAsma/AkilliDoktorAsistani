import 'package:flutter/material.dart';
import 'package:akilli_doktor_asistani/services/huggingface_analysis_service.dart';
import 'package:flutter/foundation.dart';
import 'package:akilli_doktor_asistani/services/api_key_service.dart';
import 'package:akilli_doktor_asistani/widgets/api_key_dialog.dart';

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
  if (key == 'tamidrartetkiki') {
    if (deger != null && deger.toString().toLowerCase().contains('normal')) {
      return 'Normal';
    } else {
      return 'Anormal';
    }
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
    _isLoading = true;
    _checkApiKey();
    _getAIAnalysis();
  }
  
  // API anahtarını kontrol et ve gerekirse dialog göster
  Future<void> _checkApiKey() async {
    final hasKey = await ApiKeyService.hasApiKey();
    if (!hasKey && mounted) {
      _showApiKeyDialog();
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

  Future<void> _getAIAnalysis() async {
    if (kDebugMode) {
      print('AI analiz fonksiyonu BAŞLADI');
    }
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Hugging Face API'yi çağır
      String result = '';
      try {
        // 35 saniye zaman aşımı ile analiz fonksiyonunu çağır
        final apiKey = await ApiKeyService.getApiKey();
        final huggingFaceService = HuggingFaceAnalysisService(apiKey: apiKey);
        final response = await huggingFaceService.analyze(widget.tahlil).timeout(const Duration(seconds: 35), onTimeout: () => 'AI analiz zaman aşımına uğradı. Lütfen tekrar deneyin.');
        result = response;
        if (kDebugMode) {
          print('AI analiz sonucu: $result');
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
        title: const Text('Tahlil Analiz Sonuçları', style: TextStyle(fontWeight: FontWeight.w600)), 
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
                
                // UI güncelleme işlemi
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
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.grey.shade50,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.7,
                      minChildSize: 0.4,
                      maxChildSize: 0.95,
                      builder: (context, scrollController) => SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 60,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00BCD4), Color(0xFF00ACC1)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyan.withAlpha(77),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.analytics, color: Colors.white, size: 28),
                                  SizedBox(width: 10),
                                  Text(
                                    'Yapay Zeka Analiz Raporu',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildAIAnalysisContent(_aiAnalysisResult),
                          ],
                        ),
                      ),
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
            final analiz = analizEt(key, value);
            Color renk;
            IconData statusIcon;
            
            if (analiz == 'Normal') {
              renk = Colors.green.shade700;
              statusIcon = Icons.check_circle;
            } else if (analiz == 'Sınırda') {
              renk = Colors.amber.shade700;
              statusIcon = Icons.warning_amber_rounded;
            } else if (analiz == 'Çok Düşük' || analiz == 'Çok Yüksek' || analiz == 'Anormal') {
              renk = Colors.red.shade700;
              statusIcon = Icons.error;
            } else {
              renk = Colors.grey.shade700;
              statusIcon = Icons.help;
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
  
  Widget _buildAIAnalysisContent(String content) {
    // Analiz içeriğini bölümlere ayır
    final sections = content.split('**').where((s) => s.trim().isNotEmpty).toList();
    
    List<Widget> widgets = [];
    
    // Bölümleri tablolar halinde göster
    for (int i = 0; i < sections.length; i += 2) {
      if (i + 1 >= sections.length) break;
      
      final title = sections[i].trim();
      final content = sections[i + 1].trim();
      
      // Başlık için ikon ve renk seç
      IconData headerIcon;
      Color headerIconColor;
      Color headerBgColor;
      if (title.toLowerCase().contains('anormal')) {
        headerIcon = Icons.warning_amber_rounded;
        headerIconColor = Colors.deepOrange;
        headerBgColor = Colors.deepOrange.shade50;
      } else if (title.toLowerCase().contains('tanı')) {
        headerIcon = Icons.search;
        headerIconColor = Colors.purple;
        headerBgColor = Colors.purple.shade50;
      } else if (title.toLowerCase().contains('test')) {
        headerIcon = Icons.science;
        headerIconColor = Colors.blue;
        headerBgColor = Colors.blue.shade50;
      } else if (title.toLowerCase().contains('tedavi')) {
        headerIcon = Icons.medical_services;
        headerIconColor = Colors.green;
        headerBgColor = Colors.green.shade50;
      } else if (title.toLowerCase().contains('kontrol')) {
        headerIcon = Icons.calendar_today;
        headerIconColor = Colors.indigo;
        headerBgColor = Colors.indigo.shade50;
      } else if (title.toLowerCase().contains('bilgi')) {
        headerIcon = Icons.info;
        headerIconColor = Colors.teal;
        headerBgColor = Colors.teal.shade50;
      } else {
        headerIcon = Icons.info_outline;
        headerIconColor = Colors.cyan;
        headerBgColor = Colors.cyan.shade50;
      }
      
      // Başlık widget'i
      widgets.add(
        Container(
          margin: const EdgeInsets.only(top: 20, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: headerBgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: headerIconColor.withAlpha(51),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(headerIcon, color: headerIconColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    color: headerIconColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      
      // İçerik satırlarını ayarla
      final lines = content.split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.trim())
          .toList();
      
      // Tablo oluştur
      widgets.add(
        Card(
          elevation: 3,
          shadowColor: Colors.black12,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(28), // İkon sütunu
                1: FlexColumnWidth(4),   // İçerik sütunu
              },
              border: TableBorder.symmetric(
                inside: BorderSide(color: Colors.grey.shade100, width: 1),
              ),
              children: lines.map((line) {
                // İçeriğe göre anlamlı ikon ve renk seç
                IconData rowIcon;
                Color rowIconColor;
                
                // Ön ekleri kaldır
                if (line.startsWith('-') || line.startsWith('•')) {
                  line = line.replaceFirst(RegExp(r'^[-•]\s*'), '');
                } else if (RegExp(r'^\d+\.').hasMatch(line)) {
                  line = line.replaceFirst(RegExp(r'^\d+\.\s*'), '');
                }
                
                // Hemoglobin, kan değerleri
                if (line.toLowerCase().contains('hemoglobin') || line.toLowerCase().contains('hgb')) {
                  rowIcon = Icons.bloodtype;
                  rowIconColor = Colors.red.shade700;
                }
                // Lökosit, beyaz kan hücresi
                else if (line.toLowerCase().contains('lökosit') || line.toLowerCase().contains('wbc')) {
                  rowIcon = Icons.shield;
                  rowIconColor = Colors.blue.shade700;
                }
                // Trombosit, pıhtılaşma
                else if (line.toLowerCase().contains('plt') || line.toLowerCase().contains('trombosit')) {
                  rowIcon = Icons.healing;
                  rowIconColor = Colors.purple;
                }
                // CRP, iltihap göstergesi
                else if (line.toLowerCase().contains('crp')) {
                  rowIcon = Icons.whatshot;
                  rowIconColor = Colors.orange;
                }
                // Karaciğer enzimleri
                else if (line.toLowerCase().contains('alt') || line.toLowerCase().contains('ast') || 
                         line.toLowerCase().contains('ggt')) {
                  rowIcon = Icons.monitor_heart;
                  rowIconColor = Colors.brown;
                }
                // Böbrek fonksiyonları
                else if (line.toLowerCase().contains('kreatinin') || line.toLowerCase().contains('üre')) {
                  rowIcon = Icons.filter_alt;
                  rowIconColor = Colors.amber.shade700;
                }
                // Elektrolit değerleri
                else if (line.toLowerCase().contains('sodyum') || line.toLowerCase().contains('potasyum') || 
                         line.toLowerCase().contains('kalsiyum') || line.toLowerCase().contains('magnezyum')) {
                  rowIcon = Icons.bolt;
                  rowIconColor = Colors.yellow.shade800;
                }
                // Demir, ferritin
                else if (line.toLowerCase().contains('demir') || line.toLowerCase().contains('ferritin')) {
                  rowIcon = Icons.fitness_center;
                  rowIconColor = Colors.grey.shade700;
                }
                // Vitaminler
                else if (line.toLowerCase().contains('b12') || line.toLowerCase().contains('d3') || 
                         line.toLowerCase().contains('folat')) {
                  rowIcon = Icons.medication;
                  rowIconColor = Colors.green;
                }
                // Kan şekeri
                else if (line.toLowerCase().contains('glukoz') || line.toLowerCase().contains('şeker')) {
                  rowIcon = Icons.grain;
                  rowIconColor = Colors.amber;
                }
                // Ateş, vücut ısısı
                else if (line.toLowerCase().contains('ateş') || line.toLowerCase().contains('ısı')) {
                  rowIcon = Icons.thermostat;
                  rowIconColor = Colors.red;
                }
                // Nabız, kalp atış hızı
                else if (line.toLowerCase().contains('nabız') || line.toLowerCase().contains('kalp')) {
                  rowIcon = Icons.favorite;
                  rowIconColor = Colors.red.shade400;
                }
                // Tansiyon
                else if (line.toLowerCase().contains('tansiyon')) {
                  rowIcon = Icons.speed;
                  rowIconColor = Colors.blue.shade800;
                }
                // Kan kültürü, mikrobiyoloji
                else if (line.toLowerCase().contains('kültür')) {
                  rowIcon = Icons.biotech;
                  rowIconColor = Colors.teal;
                }
                // Sedimentasyon
                else if (line.toLowerCase().contains('sedim')) {
                  rowIcon = Icons.hourglass_bottom;
                  rowIconColor = Colors.deepPurple;
                }
                // İdrar tetkiki
                else if (line.toLowerCase().contains('idrar')) {
                  rowIcon = Icons.opacity;
                  rowIconColor = Colors.yellow;
                }
                // Antibiyotik, tedavi
                else if (line.toLowerCase().contains('antibiyotik') || line.toLowerCase().contains('tedavi')) {
                  rowIcon = Icons.medication_liquid;
                  rowIconColor = Colors.green.shade700;
                }
                // Su tüketimi, hidrasyon
                else if (line.toLowerCase().contains('su') || line.toLowerCase().contains('sıvı') || 
                         line.toLowerCase().contains('hidrasyon')) {
                  rowIcon = Icons.water_drop;
                  rowIconColor = Colors.blue;
                }
                // Dinlenme, istirahat
                else if (line.toLowerCase().contains('dinlen') || line.toLowerCase().contains('istirahat')) {
                  rowIcon = Icons.hotel;
                  rowIconColor = Colors.indigo;
                }
                // Kontrol, takip
                else if (line.toLowerCase().contains('kontrol') || line.toLowerCase().contains('takip')) {
                  rowIcon = Icons.event_available;
                  rowIconColor = Colors.teal;
                }
                // Enfeksiyon, bakteriyel
                else if (line.toLowerCase().contains('enfeksiyon') || line.toLowerCase().contains('bakteri')) {
                  rowIcon = Icons.coronavirus;
                  rowIconColor = Colors.red.shade800;
                }
                // Anemi
                else if (line.toLowerCase().contains('anemi')) {
                  rowIcon = Icons.bloodtype_outlined;
                  rowIconColor = Colors.red.shade300;
                }
                // İnflamatuar
                else if (line.toLowerCase().contains('inflamat') || line.toLowerCase().contains('iltihap')) {
                  rowIcon = Icons.local_fire_department;
                  rowIconColor = Colors.deepOrange;
                }
                // Uyarı, dikkat
                else if (line.toLowerCase().contains('uyarı') || line.toLowerCase().contains('dikkat')) {
                  rowIcon = Icons.priority_high;
                  rowIconColor = Colors.red;
                }
                // Anormal değerler
                else if (line.toLowerCase().contains('anormal') || line.toLowerCase().contains('yüksek') || 
                         line.toLowerCase().contains('düşük') || line.toLowerCase().contains('kırmızı')) {
                  rowIcon = Icons.error_outline;
                  rowIconColor = Colors.red;
                }
                // Normal değerler
                else if (line.toLowerCase().contains('normal') || line.toLowerCase().contains('yeşil')) {
                  rowIcon = Icons.check_circle_outline;
                  rowIconColor = Colors.green;
                }
                // Sınırda değerler
                else if (line.toLowerCase().contains('sınırda') || line.toLowerCase().contains('sarı')) {
                  rowIcon = Icons.warning_amber_outlined;
                  rowIconColor = Colors.orange;
                }
                // Genel test, tetkik
                else if (line.toLowerCase().contains('test') || line.toLowerCase().contains('tetkik')) {
                  rowIcon = Icons.science_outlined;
                  rowIconColor = Colors.blue.shade700;
                }
                // Varsayılan ikon
                else {
                  rowIcon = Icons.arrow_right;
                  rowIconColor = Colors.indigo;
                }
                
                return TableRow(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
                  ),
                  children: [
                    // İkon hücresi
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: rowIconColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(rowIcon, size: 16, color: rowIconColor),
                        ),
                      ),
                    ),
                    // İçerik hücresi
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        child: Text(
                          line,
                          style: const TextStyle(
                            fontSize: 14, 
                            color: Color(0xFF2C3E50),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
    }
    
    // Eğer widgets boşsa veya analiz formatı beklediğimiz gibi değilse
    if (widgets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Text(
          content, 
          style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50), height: 1.3),
        ),
      );
    }
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets),
      ),
    );
  }
}
