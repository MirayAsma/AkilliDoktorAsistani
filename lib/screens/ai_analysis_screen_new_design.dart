import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:akilli_doktor_asistani/screens/tahlil_analiz_raporu_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import '../theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gemini_api_service.dart';
import '../widgets/gemini_api_key_dialog.dart';

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

class _HastaListesiWidget extends StatefulWidget {
  const _HastaListesiWidget({Key? key}) : super(key: key);

  @override
  State<_HastaListesiWidget> createState() => _HastaListesiWidgetState();
}

class _HastaListesiWidgetState extends State<_HastaListesiWidget> {
  Map<String, dynamic>? _selectedVaka;
  
  // Referans aralıkları
  final Map<String, Map<String, num>> _referansAraliklari = {
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
  };
  
  // Anahtar normalleştirme fonksiyonu
  String _normalizeKey(String key) {
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

  // Analiz fonksiyonu
  String _analizEt(String param, dynamic deger) {
    final key = _normalizeKey(param);
    if (key == 'tamidrartetkiki') {
      if (deger != null && deger.toString().toLowerCase().contains('normal')) {
        return 'Normal';
      } else {
        return 'Anormal';
      }
    }
    if (deger == null) return 'Bilinmiyor';
    final ref = _referansAraliklari[key];
    if (ref == null) return '';
    final min = ref['min']!;
    final max = ref['max']!;
    final delta = (max - min) * 0.1;
    
    // String ise sayıya dönüştür
    num degerNum;
    if (deger is String) {
      try {
        degerNum = num.parse(deger);
      } catch (e) {
        return 'Bilinmiyor';
      }
    } else {
      degerNum = deger as num;
    }

    if (degerNum >= min && degerNum <= max) return 'Normal';
    if ((degerNum >= min - delta && degerNum < min) || (degerNum > max && degerNum <= max + delta)) return 'Sınırda';
    if (degerNum < min - delta) return 'Çok Düşük';
    if (degerNum > max + delta) return 'Çok Yüksek';
    return 'Bilinmiyor';
  }
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
    _searchController.dispose();
    super.dispose();
  }

  void _filterVakalar(String value) {
    setState(() {
      _filteredVakalar = _vakalar.where((vaka) {
        return vaka['ad_soyad'].toString().toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  void _startAnalysis(Map<String, dynamic> vaka) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analiz Başlatılıyor'),
        content: const Text('Yapay zeka analizi başlatılıyor, lütfen bekleyin...'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam')),
        ],
      ),
    );
    _runAnalysis(vaka);
  }

  Future<void> _runAnalysis(Map<String, dynamic> vaka) async {
    try {
      // Analiz için veri hazırlama
      final Map<String, dynamic> analysisData = {
        'ad_soyad': vaka['ad_soyad'],
        'yas': vaka['yas'],
        'son_lab_tetkik': vaka['son_lab_tetkik'],
        'basvuru_sikayeti': vaka['basvuru_sikayeti'],
      };
      
      // Firestore'a kaydet (opsiyonel)
      final docRef = await FirebaseFirestore.instance.collection('analysis_requests').add({
        'patient_data': analysisData,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      
      // Analiz sonucunu al
      final hastaId = docRef.id;
      
      // Analiz tamamlandı, rapor sayfasına yönlendir
      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat
        _navigateToReport(hastaId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Analiz hatası: $e');
      }
      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analiz sırasında bir hata oluştu: $e')),
        );
      }
    }
  }

  void _navigateToReport(String hastaId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TahlilAnalizRaporuPage(hastaId: hastaId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Hasta ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: _filterVakalar,
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
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
                    )
                  : _selectedVaka == null
                      ? _buildHastaListesi()
                      : _buildHastaDetay(),
        ),
      ],
    );
  }

  // Hasta listesini buton şeklinde gösteren widget
  Widget _buildHastaListesi() {
    return ListView.builder(
      itemCount: _filteredVakalar.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        final vaka = _filteredVakalar[index];
        final labSonuclari = vaka['son_lab_tetkik'] as Map<String, dynamic>;
        
        // Anormal değerleri kontrol et
        final anormalDegerler = labSonuclari.entries
            .where((entry) {
              final param = entry.key.toLowerCase();
              final deger = entry.value;
              if (deger == null) return false;
              
              final sonuc = _analizEt(param, deger);
              return sonuc == 'Çok Düşük' || sonuc == 'Çok Yüksek';
            })
            .toList();
        
        final hasAnormalDeger = anormalDegerler.isNotEmpty;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: hasAnormalDeger ? Colors.red.withAlpha(128) : Colors.transparent,
              width: hasAnormalDeger ? 1.5 : 0,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedVaka = vaka;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.cyan,
                    radius: 24,
                    child: Text(
                      vaka['ad_soyad'].toString().substring(0, 1),
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaka['ad_soyad'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${vaka['yas']} yaş | ${vaka['basvuru_sikayeti']}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasAnormalDeger)
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Seçili hastanın detaylarını gösteren widget
  Widget _buildHastaDetay() {
    if (_selectedVaka == null) return const SizedBox.shrink();
    
    final vaka = _selectedVaka!;
    
    // Örnek ek hasta verileri (gerçek uygulamada Firebase'den alınacak)
    final Map<String, dynamic> detayliHastaBilgileri = {
      'ad_soyad': 'Ahmet Kalkan',
      'yas': 60,
      'cinsiyet': 'Erkek',
      'basvuru_sikayeti': 'Kabızlık, kilo kaybı',
      'son_lab_tetkik': {
        'HGB': 10,
        'WBC': 6000,
        'PLT': 200000,
        'MCV': 65,
        'Kreatinin': 1,
        'Üre': 25,
        'ALT': 30,
        'AST': 25,
        'GGT': 20,
        'Amilaz': 30,
        'Lipaz': 25,
        'Direkt bilirubin': 1,
        'İndirekt bilirubin': 0.3,
        'Sodyum': 137,
        'Potasyum': 4,
        'Kalsiyum': 9.5,
        'Demir': 20,
        'Demir bağlama kapasitesi': 300,
        'Transferrin satürasyonu': 7,
        'Ferritin': 10,
        'B12 vitamini': 250,
        'Folat': 6,
        'Vitamin D3': 40,
        'Tam idrar tetkiki': 'Normal',
        'APTT': 30,
        'INR': 1,
      },
      'goruntuleme_sonuclari': 'Ayakta direkt batın grafisinde batın içinde yaygın gaz',
      'onceki_basvurular': 'var, son 6 ayda 4 kez başvurmuş.',
      'onceki_tetkik_sonuclari': {
        'HGB': 12.5,
        'WBC': 6000,
        'PLT': 200000,
        'MCV': 80,
        'Kreatinin': 1,
        'Üre': 25,
        'ALT': 30,
        'AST': 25,
        'GGT': 20,
        'Amilaz': 30,
        'Lipaz': 25,
        'Direkt bilirubin': 1,
        'İndirekt bilirubin': 0.3,
        'Sodyum': 137,
        'Potasyum': 4,
        'Kalsiyum': 9.5,
        'Demir': 60,
        'Demir bağlama kapasitesi': 240,
        'Transferrin satürasyonu': 25,
        'Ferritin': 35,
        'B12 vitamini': 250,
        'Folat': 6,
        'Vitamin D3': 40,
        'Tam idrar tetkiki': 'Normal',
        'APTT': 30,
        'INR': 1,
      },
      'onceki_goruntuleme': 'ayakta direkt batın grafisinde yaygın gaz',
      'ameliyat': 'yok.',
      'patoloji_sonucu': 'yok.',
      'dogum_oykusu': 'yok.',
      'tansiyon': '100/65 mmgh',
      'nabiz': '105/dk',
      'ates': '36,6',
      'onceki_tedavi': 'oral duphalac',
      'uyari': 'yok.',
    };
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasta Detayı', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.cyan,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _selectedVaka = null;
            });
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Temel Hasta Bilgileri
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Ad Soyad', detayliHastaBilgileri['ad_soyad'].toString()),
                  _buildInfoRow('Yaş', '${detayliHastaBilgileri['yas']} yaş'),
                  _buildInfoRow('Cinsiyet', detayliHastaBilgileri['cinsiyet']),
                  _buildInfoRow('Hastaneye başvuru şikâyeti', detayliHastaBilgileri['basvuru_sikayeti']),
                ],
              ),
            ),
            
            // Son Başvurudaki Laboratuvar Tetkik Sonuçları
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Son başvurudaki laboratuar tetkik sonuçları:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.cyan,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletedLabList(detayliHastaBilgileri['son_lab_tetkik']),
                ],
              ),
            ),
            
            // Son Görüntüleme Sonuçları
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.image, color: Colors.cyan, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Son başvurudaki görüntüleme sonuçları',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            detayliHastaBilgileri['goruntuleme_sonuclari'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Önceki Başvurular
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.cyan, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daha öncesine ait hastane başvuruları',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            detayliHastaBilgileri['onceki_basvurular'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Önceki Başvurulardaki Tetkik Sonuçları
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Önceki başvurularında yapılan tetkik sonuçları: var, 1 ay öncesine ait.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.cyan,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletedLabList(detayliHastaBilgileri['onceki_tetkik_sonuclari']),
                ],
              ),
            ),
            
            // Önceki Görüntüleme Sonuçları
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.image, color: Colors.cyan, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Önceki başvurulardaki görüntüleme sonuçları',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            detayliHastaBilgileri['onceki_goruntuleme'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Ameliyat, Patoloji ve Doğum Öyküsü
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Hastaya yapılan ameliyat', detayliHastaBilgileri['ameliyat']),
                  _buildInfoRow('Hastanın patoloji sonucu', detayliHastaBilgileri['patoloji_sonucu']),
                  _buildInfoRow('Hastanın doğum öyküsü', detayliHastaBilgileri['dogum_oykusu']),
                ],
              ),
            ),
            
            // Tansiyon, Nabız ve Ateş Ölçümleri
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Tansiyon ölçüm sonuçları', detayliHastaBilgileri['tansiyon']),
                  _buildInfoRow('Nabız sayısı', detayliHastaBilgileri['nabiz']),
                  _buildInfoRow('Ateş ölçümü', detayliHastaBilgileri['ates']),
                ],
              ),
            ),
            
            // Önceki Tedavi ve Uyarı
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Daha önceki başvurusunda verilen tedavi', detayliHastaBilgileri['onceki_tedavi']),
                  _buildInfoRow('Hasta için sisteme eklenmiş uyarı', detayliHastaBilgileri['uyari']),
                ],
              ),
            ),
            
            // AI Analiz butonu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _startAnalysis(vaka),
                  icon: const Icon(Icons.analytics),
                  label: const Text('AI Analiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Laboratuvar sonuçlarını madde işaretli liste olarak gösteren widget
  Widget _buildBulletedLabList(Map<String, dynamic> labSonuclari) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: labSonuclari.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;
        final valueStr = value is num ? value.toString() : value.toString();
        
        // Referans aralığına göre renk belirleme
        final sonuc = _analizEt(key, value);
        final isNormal = sonuc == 'Normal';
        final textColor = isNormal ? Colors.black : Colors.red;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('\u2022 ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),  // Madde işareti
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    children: [
                      TextSpan(
                        text: '$key: ',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: valueStr,
                        style: TextStyle(color: textColor, fontWeight: isNormal ? FontWeight.normal : FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  // Bilgi satırını gösteren widget
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
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
  GeminiApiService? _geminiService;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _messages.add(_ChatMessage(text: 'AI Doktor Asistanına Hoş Geldiniz! Size tıbbi konularda yardımcı olabilirim.', isUser: false));
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('gemini_api_key');
    if (key != null && key.isNotEmpty) {
      setState(() {
        _apiKey = key;
        _geminiService = GeminiApiService(key);
      });
    }
  }

  Future<void> _saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);
    setState(() {
      _apiKey = key;
      _geminiService = GeminiApiService(key);
    });
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => GeminiApiKeyDialog(
        initialValue: _apiKey,
        onApiKeySaved: (key) => _saveApiKey(key),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    if (_apiKey == null || _geminiService == null) {
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

      final response = await _geminiService!.sendMessage(prompt);
      
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
              label: const Text('Gemini API Anahtarını Girin'),
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
