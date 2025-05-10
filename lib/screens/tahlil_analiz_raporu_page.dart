import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tahlil_analiz_sonuclari_page.dart';

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
      floatingActionButton: FloatingActionButton(
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
    );
  }
}
