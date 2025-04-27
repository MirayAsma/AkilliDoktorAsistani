import 'package:flutter/material.dart';
import 'package:akilli_doktor_asistani/screens/tahlil_analiz_raporu_page.dart';
import 'package:akilli_doktor_asistani/services/ai_analysis_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';


final List<Map<String, dynamic>> vakalar = [
  {
    'ad_soyad': 'Elif Demir',
    'yas': 25,
    'son_lab_tetkik': {'HGB': 10, 'WBC': 5500, 'PLT': 180000, 'Kreatinin': 0.8, 'Glukoz': 90},
    'basvuru_sikayeti': 'Baş ağrısı',
  },
  {
    'ad_soyad': 'Ahmet Yılmaz',
    'yas': 40,
    'son_lab_tetkik': {'HGB': 13, 'WBC': 7000, 'PLT': 220000, 'Kreatinin': 1.1, 'Glukoz': 105},
    'basvuru_sikayeti': 'Karın ağrısı',
  },
  {
    'ad_soyad': 'Zeynep Kaya',
    'yas': 32,
    'son_lab_tetkik': {'HGB': 11, 'WBC': 4300, 'PLT': 150000, 'Kreatinin': 0.9, 'Glukoz': 98},
    'basvuru_sikayeti': 'Yorgunluk',
  },
  {
    'ad_soyad': 'Mehmet Can',
    'yas': 55,
    'son_lab_tetkik': {'HGB': 15, 'WBC': 12000, 'PLT': 450000, 'Kreatinin': 1.5, 'Glukoz': 180},
    'basvuru_sikayeti': 'Nefes darlığı',
  },
  {
    'ad_soyad': 'Ayşe Polat',
    'yas': 60,
    'son_lab_tetkik': {'HGB': 9, 'WBC': 3900, 'PLT': 95000, 'Kreatinin': 2.2, 'Glukoz': 210},
    'basvuru_sikayeti': 'Çarpıntı',
  },
];

class AIAnalysisScreen extends StatelessWidget {
  const AIAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI ASİSTAN', style: TextStyle(letterSpacing: 1.5)),
        backgroundColor: Colors.cyan,
      ),
      body: const _HastaListesiWidget(),
    );
  }
}

class _HastaListesiWidget extends StatefulWidget {
  const _HastaListesiWidget({Key? key}) : super(key: key);

  @override
  State<_HastaListesiWidget> createState() => _HastaListesiWidgetState();
}

class _HastaListesiWidgetState extends State<_HastaListesiWidget> {
  // Kullanılmayan fonksiyon kaldırıldı
  List<Map<String, dynamic>> _vakalar = [];
  List<Map<String, dynamic>> _filteredVakalar = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVakalar();
  }

  Future<void> _fetchVakalar() async {
    try {
      // print('Firebaseden hasta verileri çekiliyor...');
      
      // Firebaseden verileri çek
      final snapshot = await FirebaseFirestore.instance.collection('cases').get();
      // print('Firebase sorgusu tamamlandı. Bulunan doküman sayısı: ${snapshot.docs.length}');
      
      // Doküman yoksa, örnek verilerle devam et
      if (snapshot.docs.isEmpty) {
        // print('Firebasede doküman bulunamadı. Örnek veriler kullanılacak.');
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
        // print('Doküman ID: ${doc.id}, Veri: $data');
        return {...data, 'id': doc.id};
      }).toList();
      
      final seenNames = <String>{};
      final uniquePatients = <Map<String, dynamic>>[];
      
      for (final patient in patients) {
        final name = patient['ad_soyad']?.toString() ?? '';
        // print('Hasta adı: $name, ID: ${patient["id"]}');
        
        if (name.isNotEmpty && !seenNames.contains(name)) {
          seenNames.add(name);
          uniquePatients.add(patient);
          if (uniquePatients.length >= 5) break;
        }
      }
      
      // print('Toplam benzersiz hasta sayısı: ${uniquePatients.length}');
      
      setState(() {
        _vakalar = uniquePatients.isNotEmpty ? uniquePatients : vakalar;
        _filteredVakalar = List<Map<String, dynamic>>.from(_vakalar);
        _isLoading = false;
      });
    } catch (e) {
      // print('Hasta verileri alınırken hata: $e');
      setState(() {
        _errorMessage = 'Hasta verileri alınırken hata oluştu: \n${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterVakalar(String value) {
    setState(() {
      _filteredVakalar = _vakalar.where((vaka) {
        final adSoyad = (vaka['ad_soyad'] ?? '').toLowerCase();
        return adSoyad.contains(value.toLowerCase());
      }).toList();
    });
  }

  // Analiz işlemini başlat ve sonra navigasyon yap
  void _startAnalysis(Map<String, dynamic> vaka) {
    // Önce dialog'u göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(child: CircularProgressIndicator()),
    );
    
    // Sonra analiz işlemini yap
    _runAnalysis(vaka);
  }
  
  // Analiz işlemini gerçekleştir
  Future<void> _runAnalysis(Map<String, dynamic> vaka) async {
    try {
      // print('Analiz başlatılıyor. Vaka bilgileri: ${vaka.toString()}');
      // print('Hasta ID: ${vaka['id'] ?? "ID bulunamadı"}');
      
      await analizHuggingFace(vaka['son_lab_tetkik'] ?? {});
      
      // Analiz başarılı olduysa
      if (mounted) {
        // Önce dialog'u kapat
        Navigator.of(context).pop();
        
        // Sonra rapor sayfasına git
        final hastaId = vaka['id'] ?? '';
        // print('Rapor sayfasına yönlendiriliyor. Hasta ID: $hastaId');
        _navigateToReport(hastaId);
      }
    } catch (e) {
      // Hata durumunda
      // print('Analiz sırasında hata: $e');
      if (mounted) {
        Navigator.of(context).pop();
        // Hata mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analiz sırasında hata oluştu: $e')),
        );
      }
    }
  }
  
  // Rapor sayfasına git
  void _navigateToReport(String hastaId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TahlilAnalizRaporuPage(
          hastaId: hastaId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Hasta ismi ile ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: _filterVakalar,
          ),
        ),
        Expanded(
          child: _filteredVakalar.isEmpty
              ? const Center(child: Text('Aramanıza uygun hasta bulunamadı', style: TextStyle(fontSize: 16)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: _filteredVakalar.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final vaka = _filteredVakalar[index];
                    final adSoyad = vaka['ad_soyad'] ?? '';
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          elevation: 2,
                        ),
                        onPressed: () {
                          // Analiz işlemini başlat
                          _startAnalysis(vaka);
                        
                        },
                        child: Text(adSoyad),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}


