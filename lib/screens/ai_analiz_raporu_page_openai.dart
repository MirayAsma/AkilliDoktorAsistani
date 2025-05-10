import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/openai_api_service.dart';
import '../widgets/openai_api_key_dialog.dart';

class AIAnalizRaporuPage extends StatefulWidget {
  final Map<String, dynamic> hastaVerileri;
  
  const AIAnalizRaporuPage({
    Key? key,
    required this.hastaVerileri,
  }) : super(key: key);

  @override
  State<AIAnalizRaporuPage> createState() => _AIAnalizRaporuPageState();
}

class _AIAnalizRaporuPageState extends State<AIAnalizRaporuPage> {
  bool _isLoading = true;
  Map<String, dynamic> _analysisResult = {};
  String? _errorMessage;
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
      _openaiService = OpenAIApiService(key);
      _analyzePatientData();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'OpenAI API anahtarı bulunamadı. Lütfen API anahtarınızı ekleyin.';
      });
      _showApiKeyDialog();
    }
  }
  
  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OpenAI API Anahtarı Girin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AI analizi için OpenAI API anahtarınızı girin. API anahtarınız yoksa, OpenAI web sitesinden ücretsiz olarak alabilirsiniz.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'API Anahtarı',
                hintText: 'sk-...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _apiKey = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_apiKey != null && _apiKey!.isNotEmpty) {
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('openai_api_key', _apiKey!);
                _openaiService = OpenAIApiService(_apiKey!);
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _analyzePatientData();
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
  
  String? _apiKey;
  
  Future<void> _analyzePatientData() async {
    try {
      final result = await _openaiService!.analyzePatientData(widget.hastaVerileri);
      
      // Debug için
      print("API Yanıtı: ${result['rawResponse']}");
      
      setState(() {
        _analysisResult = result;
        _isLoading = false;
      });
    } catch (e) {
      print("Analiz Hatası: $e");
      setState(() {
        _errorMessage = 'Analiz sırasında bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Analiz Raporu', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.cyan,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Hasta verileri analiz ediliyor...'),
            ],
          ),
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Analiz Raporu', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.cyan,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
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
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _analyzePatientData();
                },
                child: const Text('Tekrar Dene'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _showApiKeyDialog,
                child: const Text('API Anahtarını Değiştir'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analiz Raporu', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.cyan,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _analyzePatientData();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientInfoCard(),
            const SizedBox(height: 24),
            
            // Debug için ham API yanıtı
            if (_analysisResult.containsKey('rawResponse')) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ham API Yanıtı (Debug):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _analysisResult['rawResponse'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            if (_analysisResult.containsKey('abnormalFindingsText')) ...[
              _buildSectionTitle('1. Normal Değer Dışı Bulgular', Icons.warning),
              _buildTextSection(_analysisResult['abnormalFindingsText']),
              const SizedBox(height: 24),
            ],
            
            if (_analysisResult.containsKey('diagnosesText')) ...[  
              _buildSectionTitle('2. Olası İlk 3 Tanı', Icons.medical_services),
              _buildTextSection(_analysisResult['diagnosesText']),
              const SizedBox(height: 24),
            ],
            
            if (_analysisResult.containsKey('testsText')) ...[  
              _buildSectionTitle('3. Önerilen Tetkikler', Icons.science),
              _buildTextSection(_analysisResult['testsText']),
              const SizedBox(height: 24),
            ],
            
            if (_analysisResult.containsKey('treatmentText')) ...[  
              _buildSectionTitle('4. Tedavi Önerisi', Icons.medication),
              _buildTextSection(_analysisResult['treatmentText']),
              const SizedBox(height: 24),
            ],
            
            if (_analysisResult.containsKey('followUpText')) ...[  
              _buildSectionTitle('5. Kontrol Zamanı', Icons.calendar_today),
              _buildTextSection(_analysisResult['followUpText']),
              const SizedBox(height: 24),
            ],
            
            if (_analysisResult.containsKey('warningsText')) ...[  
              _buildSectionTitle('6. Hastaya Bilgi ve Uyarılar', Icons.info_outline),
              _buildTextSection(_analysisResult['warningsText']),
              const SizedBox(height: 24),
            ],
            
            const SizedBox(height: 32),
            
            // Açıklama
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                'Not: Bu analiz yapay zeka tarafından oluşturulmuştur ve sadece bilgilendirme amaçlıdır. Kesin tanı ve tedavi için doktor görüşü esastır.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyan),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTextSection(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
  
  Widget _buildPatientInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.cyan.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.cyan),
              const SizedBox(width: 8),
              Text(
                widget.hastaVerileri['ad_soyad'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.hastaVerileri['yas']} yaş, ${widget.hastaVerileri['cinsiyet'] ?? 'Belirtilmemiş'}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Şikayet: ${widget.hastaVerileri['basvuru_sikayeti']}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
