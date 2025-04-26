import 'package:flutter/material.dart';

class TestResultsScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const TestResultsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {
  final List<Map<String, dynamic>> _testResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTestResults();
  }

  void _loadTestResults() {
    // Gecikme ile tahlil sonuçlarını yükleme simulasyonu
    Future.delayed(const Duration(seconds: 1), () {
      // Hasta ID'sine göre farklı tahlil sonuçları oluşturuyoruz
      final testResults = [
        {
          'id': 1,
          'date': '05.04.2025',
          'type': 'Tam Kan Sayımı',
          'status': 'Tamamlandı',
          'results': [
            {'name': 'Hemoglobin', 'value': '14.2 g/dL', 'refRange': '13.5-17.5 g/dL', 'status': 'normal'},
            {'name': 'Lökosit', 'value': '7.500 /mm³', 'refRange': '4.000-10.000 /mm³', 'status': 'normal'},
            {'name': 'Trombosit', 'value': '245.000 /mm³', 'refRange': '150.000-450.000 /mm³', 'status': 'normal'},
            {'name': 'Hematokrit', 'value': '42%', 'refRange': '38.8-50%', 'status': 'normal'},
            {'name': 'MCV', 'value': '88 fL', 'refRange': '80-97 fL', 'status': 'normal'},
            {'name': 'MCH', 'value': '29.5 pg', 'refRange': '27-33 pg', 'status': 'normal'},
          ],
        },
        {
          'id': 2,
          'date': '28.03.2025',
          'type': 'Biyokimya Paneli',
          'status': 'Tamamlandı',
          'results': [
            {'name': 'Glukoz', 'value': '110 mg/dL', 'refRange': '70-100 mg/dL', 'status': 'yüksek'},
            {'name': 'BUN', 'value': '15 mg/dL', 'refRange': '7-20 mg/dL', 'status': 'normal'},
            {'name': 'Kreatinin', 'value': '0.9 mg/dL', 'refRange': '0.6-1.2 mg/dL', 'status': 'normal'},
            {'name': 'Sodyum', 'value': '140 mEq/L', 'refRange': '136-145 mEq/L', 'status': 'normal'},
            {'name': 'Potasyum', 'value': '4.0 mEq/L', 'refRange': '3.5-5.1 mEq/L', 'status': 'normal'},
            {'name': 'Kalsiyum', 'value': '9.5 mg/dL', 'refRange': '8.5-10.2 mg/dL', 'status': 'normal'},
          ],
        },
        {
          'id': 3,
          'date': '15.03.2025',
          'type': 'Karaciğer Fonksiyon Testleri',
          'status': 'Tamamlandı',
          'results': [
            {'name': 'ALT', 'value': '32 U/L', 'refRange': '7-56 U/L', 'status': 'normal'},
            {'name': 'AST', 'value': '28 U/L', 'refRange': '5-40 U/L', 'status': 'normal'},
            {'name': 'ALP', 'value': '78 U/L', 'refRange': '44-147 U/L', 'status': 'normal'},
            {'name': 'Total Bilirubin', 'value': '0.8 mg/dL', 'refRange': '0.1-1.2 mg/dL', 'status': 'normal'},
            {'name': 'Direkt Bilirubin', 'value': '0.2 mg/dL', 'refRange': '0.0-0.3 mg/dL', 'status': 'normal'},
            {'name': 'Total Protein', 'value': '7.2 g/dL', 'refRange': '6.4-8.3 g/dL', 'status': 'normal'},
          ],
        },
      ];

      // Daha fazla tahlil ekleyelim (ID'ye bağlı)
      if (widget.patientId % 2 == 0) {
        testResults.add({
          'id': 4,
          'date': '10.03.2025',
          'type': 'Lipid Profili',
          'status': 'Tamamlandı',
          'results': [
            {'name': 'Total Kolesterol', 'value': '210 mg/dL', 'refRange': '<200 mg/dL', 'status': 'yüksek'},
            {'name': 'LDL', 'value': '130 mg/dL', 'refRange': '<100 mg/dL', 'status': 'yüksek'},
            {'name': 'HDL', 'value': '45 mg/dL', 'refRange': '>40 mg/dL', 'status': 'normal'},
            {'name': 'Trigliserit', 'value': '150 mg/dL', 'refRange': '<150 mg/dL', 'status': 'normal'},
          ],
        });
        
        testResults.add({
          'id': 5,
          'date': '01.03.2025',
          'type': 'Tiroid Fonksiyon Testleri',
          'status': 'Tamamlandı',
          'results': [
            {'name': 'TSH', 'value': '2.5 μIU/mL', 'refRange': '0.4-4.0 μIU/mL', 'status': 'normal'},
            {'name': 'T4', 'value': '1.2 ng/dL', 'refRange': '0.8-1.8 ng/dL', 'status': 'normal'},
            {'name': 'T3', 'value': '120 ng/dL', 'refRange': '80-200 ng/dL', 'status': 'normal'},
          ],
        });
      }

      // ID 3 olan hasta için özel test sonuçları
      if (widget.patientId == 3) {
        testResults.add({
          'id': 6,
          'date': '20.02.2025',
          'type': 'EKG Raporu',
          'status': 'Tamamlandı',
          'results': [
            {'name': 'Kalp Ritmi', 'value': 'Normal Sinüs Ritmi', 'refRange': 'Normal Sinüs Ritmi', 'status': 'normal'},
            {'name': 'Kalp Hızı', 'value': '78 atım/dk', 'refRange': '60-100 atım/dk', 'status': 'normal'},
            {'name': 'PR Aralığı', 'value': '160 ms', 'refRange': '120-200 ms', 'status': 'normal'},
            {'name': 'QRS Süresi', 'value': '90 ms', 'refRange': '<120 ms', 'status': 'normal'},
            {'name': 'QT Aralığı', 'value': '380 ms', 'refRange': '350-440 ms', 'status': 'normal'},
          ],
        });
      }

      if (mounted) {
        setState(() {
          _testResults.addAll(testResults);
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patientName} - Tahlil Sonuçları'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _testResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tahlil sonucu bulunamadı',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _testResults.length,
                  itemBuilder: (context, index) {
                    final testResult = _testResults[index];
                    return _buildTestResultCard(testResult);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tahlil sonucu çıktısı alınıyor...')),
          );
        },
        tooltip: 'Rapor Yazdır',
        child: const Icon(Icons.print),
      ),
    );
  }

  Widget _buildTestResultCard(Map<String, dynamic> testResult) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          testResult['type'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Tarih: ${testResult['date']}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            testResult['status'] as String,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          const Divider(height: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Test',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Değer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Referans Aralığı',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                ...List.generate(
                  (testResult['results'] as List).length,
                  (resultIndex) {
                    final result = (testResult['results'] as List)[resultIndex];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(result['name'] as String),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              result['value'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(result['status'] as String),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(result['refRange'] as String),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tahlil raporu indirildi')),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('İndir'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tahlil raporu paylaşıldı')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Paylaş'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'yüksek':
        return Colors.red;
      case 'düşük':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }
}
