import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:akilli_doktor_asistani/screens/ai_analiz_raporu_page_openai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/openai_api_service.dart';
import '../widgets/openai_api_key_dialog.dart';

// Örnek hasta verileri
final List<Map<String, dynamic>> vakalar = [
  {
    'ad_soyad': 'Elif Demir',
    'yas': 25,
    'cinsiyet': 'Kadın',
    'son_lab_tetkik': {'HGB': 10, 'WBC': 5500, 'PLT': 180000, 'Kreatinin': 0.8, 'Glukoz': 90},
    'basvuru_sikayeti': 'Baş ağrısı',
  },
  {
    'ad_soyad': 'Ahmet Yılmaz',
    'yas': 40,
    'cinsiyet': 'Erkek',
    'son_lab_tetkik': {'HGB': 13, 'WBC': 7000, 'PLT': 220000, 'Kreatinin': 1.1, 'Glukoz': 105},
    'basvuru_sikayeti': 'Karın ağrısı',
  },
  {
    'ad_soyad': 'Zeynep Kaya',
    'yas': 32,
    'cinsiyet': 'Kadın',
    'son_lab_tetkik': {'HGB': 11, 'WBC': 4300, 'PLT': 150000, 'Kreatinin': 0.9, 'Glukoz': 98},
    'basvuru_sikayeti': 'Yorgunluk',
  },
  {
    'ad_soyad': 'Mehmet Can',
    'yas': 55,
    'cinsiyet': 'Erkek',
    'son_lab_tetkik': {'HGB': 15, 'WBC': 12000, 'PLT': 450000, 'Kreatinin': 1.5, 'Glukoz': 180},
    'basvuru_sikayeti': 'Nefes darlığı',
  },
  {
    'ad_soyad': 'Ayşe Polat',
    'yas': 60,
    'cinsiyet': 'Kadın',
    'son_lab_tetkik': {'HGB': 9, 'WBC': 3900, 'PLT': 95000, 'Kreatinin': 2.2, 'Glukoz': 210},
    'basvuru_sikayeti': 'Çarpıntı',
  },
];

class AIAnalysisScreen extends StatelessWidget {
  const AIAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI ASİSTAN', style: TextStyle(letterSpacing: 1.5)),
          backgroundColor: Colors.cyan,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: "Hasta Listesi"),
              Tab(icon: Icon(Icons.chat), text: "AI Doktor Asistanı"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const _HastaListesiWidget(),
            _ChatbotWidget(),
          ],
        ),
      ),
    );
  }
}
// Hasta Listesi Widget'ı
class _HastaListesiWidget extends StatefulWidget {
  const _HastaListesiWidget();

  @override
  State<_HastaListesiWidget> createState() => _HastaListesiWidgetState();
}

class _HastaListesiWidgetState extends State<_HastaListesiWidget> {
  List<Map<String, dynamic>> _vakalar = [];
  List<Map<String, dynamic>> _filteredVakalar = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVakalar();
  }

  Future<void> _fetchVakalar() async {
    try {
      // Firebaseden verileri çek
      final snapshot = await FirebaseFirestore.instance.collection('cases').get();
      
      // Doküman yoksa, örnek verilerle devam et
      if (snapshot.docs.isEmpty) {
        setState(() {
          _vakalar = vakalar; // Sabit tanımlı örnek veriler
          _filteredVakalar = List<Map<String, dynamic>>.from(vakalar);
          _isLoading = false;
        });
        return;
      }
      
      // Dokümanları işle
      final patients = snapshot.docs.map((doc) {
        final data = doc.data();
        return {...data, 'id': doc.id};
      }).toList();
      
      final seenNames = <String>{};
      final uniquePatients = <Map<String, dynamic>>[];
      
      for (final patient in patients) {
        final name = patient['ad_soyad']?.toString() ?? '';
        
        if (name.isNotEmpty && !seenNames.contains(name)) {
          seenNames.add(name);
          uniquePatients.add(patient);
        }
      }
      
      setState(() {
        _vakalar = uniquePatients.isEmpty ? vakalar : uniquePatients;
        _filteredVakalar = List<Map<String, dynamic>>.from(_vakalar);
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Veri çekme hatası: $e');
      }
      setState(() {
        _errorMessage = 'Hasta verileri yüklenirken bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // OpenAI API ile analiz başlatma metodu
  Future<void> _baslat(Map<String, dynamic> vaka) async {
    try {
      // API anahtarını kontrol et
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchVakalar,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }
    
    return _buildHastaListesi();
  }

  Widget _buildHastaListesi() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Hasta ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _filteredVakalar = List<Map<String, dynamic>>.from(_vakalar);
                } else {
                  _filteredVakalar = _vakalar.where((vaka) {
                    final adSoyad = vaka['ad_soyad']?.toString().toLowerCase() ?? '';
                    final sikayet = vaka['basvuru_sikayeti']?.toString().toLowerCase() ?? '';
                    final searchTerm = value.toLowerCase();
                    return adSoyad.contains(searchTerm) || sikayet.contains(searchTerm);
                  }).toList();
                }
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredVakalar.length,
            itemBuilder: (context, index) {
              final vaka = _filteredVakalar[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => _showHastaDetayi(vaka),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.cyan.shade100,
                              child: Text(
                                vaka['ad_soyad'].toString().substring(0, 1),
                                style: TextStyle(
                                  color: Colors.cyan.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vaka['ad_soyad'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${vaka['yas']} yaş, ${vaka['cinsiyet'] ?? 'Belirtilmemiş'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _baslat(vaka),
                              icon: const Icon(Icons.smart_toy),
                              label: const Text('AI Analizi Başlat'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.medical_information, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'Şikayet: ${vaka['basvuru_sikayeti']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showHastaDetayi(Map<String, dynamic> vaka) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vaka['ad_soyad'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _baslat(vaka),
                    icon: const Icon(Icons.smart_toy),
                    label: const Text('AI Analizi Başlat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    const Text(
                      'Hasta Bilgileri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.person,
                            title: 'Yaş',
                            value: '${vaka['yas']}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailCard(
                            icon: Icons.wc,
                            title: 'Cinsiyet',
                            value: vaka['cinsiyet'] ?? 'Belirtilmemiş',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      icon: Icons.medical_information,
                      title: 'Başvuru Şikayeti',
                      value: vaka['basvuru_sikayeti'],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Laboratuvar Sonuçları',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLabResults(vaka['son_lab_tetkik'] ?? {}),
                    const SizedBox(height: 24),
                    const Text(
                      'Önceki Tetkikler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPreviousLabResults(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.cyan),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabResults(Map<String, dynamic> labSonuclari) {
    if (labSonuclari.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Text(
            'Laboratuvar sonucu bulunamadı',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                flex: 2,
                child: Text(
                  'Tetkik',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Sonuç',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Referans Aralığı',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const Divider(),
          ...labSonuclari.entries.map((entry) {
            final String testName = entry.key;
            final dynamic value = entry.value;
            
            // Referans aralıkları (örnek)
            String refRange = '';
            Color valueColor = Colors.black;
            
            // Örnek referans aralıkları ve renk kodlaması
            switch (testName) {
              case 'HGB':
                refRange = '12-16 g/dL';
                valueColor = (value < 12) ? Colors.red : (value > 16) ? Colors.red : Colors.green;
                break;
              case 'WBC':
                refRange = '4000-11000 /μL';
                valueColor = (value < 4000) ? Colors.red : (value > 11000) ? Colors.red : Colors.green;
                break;
              case 'PLT':
                refRange = '150000-400000 /μL';
                valueColor = (value < 150000) ? Colors.red : (value > 400000) ? Colors.red : Colors.green;
                break;
              case 'Kreatinin':
                refRange = '0.6-1.2 mg/dL';
                valueColor = (value < 0.6) ? Colors.red : (value > 1.2) ? Colors.red : Colors.green;
                break;
              case 'Glukoz':
                refRange = '70-100 mg/dL';
                valueColor = (value < 70) ? Colors.red : (value > 100) ? Colors.orange : Colors.green;
                break;
              default:
                refRange = 'Belirtilmemiş';
            }
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(testName),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '$value',
                      style: TextStyle(
                        color: valueColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      refRange,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPreviousLabResults() {
    // Örnek önceki tetkikler
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: Text(
          'Önceki tetkik sonuçları bulunamadı',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

// Chatbot widget'ı
class _ChatbotWidget extends StatefulWidget {
  @override
  State<_ChatbotWidget> createState() => _ChatbotWidgetState();
}

// Chat mesajı sınıfı
class _ChatMessage {
  final String text;
  final bool isUser;
  
  _ChatMessage({required this.text, required this.isUser});
}

class _ChatbotWidgetState extends State<_ChatbotWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _apiKey;
  OpenAIApiService? _openaiService;
  
  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }
  
  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('openai_api_key');
    if (key != null && key.isNotEmpty) {
      setState(() {
        _apiKey = key;
        _openaiService = OpenAIApiService(key);
      });
    }
  }
  
  Future<void> _saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('openai_api_key', key);
    setState(() {
      _apiKey = key;
      _openaiService = OpenAIApiService(key);
    });
  }
  
  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => OpenAIApiKeyDialog(
        initialValue: _apiKey,
        onApiKeySaved: (key) => _saveApiKey(key),
      ),
    );
  }
  
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    if (_apiKey == null || _openaiService == null) {
      _showApiKeyDialog();
      return;
    }
    
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    
    try {
      final prompt = '''
Sen bir tıbbi yapay zeka asistanısın. Bir doktora yardımcı oluyorsun. 
Doğru, net ve profesyonel yanıtlar ver. Kullanıcı sorusu: $text
''';

      final response = await _openaiService!.sendMessage(prompt);
      
      setState(() {
        _messages.add(_ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          text: 'Bir hata oluştu: $e',
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_apiKey == null)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.vpn_key),
              label: const Text('OpenAI API Anahtarını Girin'),
              onPressed: _showApiKeyDialog,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return Align(
                alignment: message.isUser 
                    ? Alignment.centerRight 
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: message.isUser 
                        ? Colors.blue.shade100 
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Mesajınızı yazın...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
                color: Colors.cyan,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
