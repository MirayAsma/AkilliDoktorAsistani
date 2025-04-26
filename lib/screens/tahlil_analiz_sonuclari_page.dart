import 'package:flutter/material.dart';

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

class TahlilAnalizSonuclariPage extends StatelessWidget {
  final Map<String, dynamic> tahlil;
  const TahlilAnalizSonuclariPage({Key? key, required this.tahlil}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entries = tahlil.entries.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Tahlil Analiz Sonuçları'), backgroundColor: Colors.cyan),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final key = entries[index].key;
          final value = entries[index].value;
          final analiz = analizEt(key, value);
          Color renk;
          if (analiz == 'Normal') {
            renk = Colors.green;
          } else if (analiz == 'Sınırda') {
            renk = Colors.amber;
          } else if (analiz == 'Çok Düşük' || analiz == 'Çok Yüksek' || analiz == 'Anormal') {
            renk = Colors.red;
          } else {
            renk = Colors.grey;
          }
          return ListTile(
            title: Text(
              key.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '').join(' '),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Değer: $value'),
            trailing: analiz.isNotEmpty ? Text(
              analiz,
              style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 16),
            ) : null,
          );
        },
      ),
    );
  }
}
