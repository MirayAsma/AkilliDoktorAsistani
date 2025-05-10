import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gemini_api_service.dart';
import '../widgets/gemini_api_key_dialog.dart';

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
  
  // Gemini servisi
  GeminiApiService? _geminiService;
  String? _geminiApiKey;

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Gemini API anahtarını kontrol et
    final geminiKey = prefs.getString('gemini_api_key');
    if (geminiKey != null && geminiKey.isNotEmpty) {
      _geminiApiKey = geminiKey;
      _geminiService = GeminiApiService(geminiKey);
      _analyzePatientDataGemini();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'AI analizi için Gemini API anahtarı gerekiyor. Lütfen anahtarı girin.';
      });
      _showGeminiApiKeyDialog();
    }
  }

  void _showGeminiApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => GeminiApiKeyDialog(
        onApiKeySaved: (key) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('gemini_api_key', key);
          _geminiApiKey = key;
          _geminiService = GeminiApiService(key);
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
          _analyzePatientDataGemini();
        },
      ),
    );
  }

  Future<void> _analyzePatientDataGemini() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await _geminiService!.analyzePatientData(widget.hastaVerileri);
      
      if (result['error'] != null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Hata: ${result['error']}';
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _analysisResult = result;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Analiz sırasında hata oluştu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analiz Raporu'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _showGeminiApiKeyDialog,
                        child: const Text('Gemini API Anahtarını Gir'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hasta verilerini göster
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hasta Verileri',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...widget.hastaVerileri.entries.map((entry) {
                                if (entry.value != null && entry.value.toString().isNotEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      '${entry.key}: ${entry.value}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Analiz sonuçlarını göster
                      if (_analysisResult['error'] != null)
                        Text(
                          'Hata: ${_analysisResult['error']}',
                          style: const TextStyle(color: Colors.red),
                        )
                      else
                        ..._analysisResult.entries.map((entry) {
                          if (entry.key != 'rawResponse' && entry.key != 'error') {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key.replaceAll('Text', '').replaceAll('_', ' '),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      entry.value.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }).toList(),
                    ],
                  ),
                ),
    );
  }
}
