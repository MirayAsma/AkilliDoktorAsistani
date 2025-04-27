import 'package:flutter/material.dart';
import 'tahlil_analiz_sonuclari_page.dart';

class HastaDetayDialog extends StatelessWidget {
  final Map<String, dynamic> hasta;
  final String adSoyad;
  final Map<String, dynamic>? sonTetkik;
  final dynamic oncekiTetkik; // String veya Map olabilir

  const HastaDetayDialog({
    Key? key,
    required this.hasta,
    required this.adSoyad,
    this.sonTetkik,
    this.oncekiTetkik,
  }) : super(key: key);

  String _str(dynamic val) => val == null ? 'Yok' : val.toString();

  Widget _buildInfoRow(String label, String value, IconData? icon) {
    // Her etiket için anlamlı renk belirleme
    Color iconColor;
    switch(label) {
      case 'Ad Soyad':
        iconColor = Colors.blue;
        break;
      case 'Yaş':
        iconColor = Colors.green;
        break;
      case 'Cinsiyet':
        iconColor = Colors.purple;
        break;
      case 'Başvuru Şikayeti':
        iconColor = Colors.orange;
        break;
      case 'Önceki Görüntüleme':
        iconColor = Colors.indigo;
        break;
      case 'Ameliyat':
        iconColor = Colors.red;
        break;
      case 'Patoloji Sonucu':
        iconColor = Colors.deepPurple;
        break;
      case 'Doğum Öyküsü':
        iconColor = Colors.pink;
        break;
      case 'Tansiyon':
        iconColor = Colors.red;
        break;
      case 'Nabız':
        iconColor = Colors.red.shade700;
        break;
      case 'Ateş':
        iconColor = Colors.deepOrange;
        break;
      case 'Önceki Tedavi':
        iconColor = Colors.teal;
        break;
      case 'Uyarı':
        iconColor = Colors.amber;
        break;
      default:
        iconColor = Colors.blueGrey;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
        .join(' ');
  }

  Widget _buildTetkikList(Map<String, dynamic>? tetkik) {
    if (tetkik == null || tetkik.isEmpty) {
      return const Text('Yok', style: TextStyle(fontStyle: FontStyle.italic));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tetkik.entries.map((e) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '${_formatKey(e.key)}:',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '${e.value}',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        )
      ).toList(),
    );
  }

  Widget _buildOncekiTetkik(dynamic onceki) {
    if (onceki == null || onceki == '' || onceki == 'yok') {
      return const Text('Yok', style: TextStyle(fontStyle: FontStyle.italic));
    }
    // Eğer Map ise tablo gibi göster
    if (onceki is Map<String, dynamic>) {
      return _buildTetkikList(onceki);
    }
    // Eğer String ise düzenli bir şekilde göster
    if (onceki is String) {
      // String'i satırlara ayır
      final lines = onceki.toString().split('\n');
      if (lines.length == 1) {
        // Virgülle ayrılmış olabilir
        final items = onceki.toString().split(',');
        if (items.length > 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(item.trim(), style: const TextStyle(fontSize: 15)),
              )
            ).toList(),
          );
        }
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines.map((line) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(line.trim(), style: const TextStyle(fontSize: 15)),
            )
          ).toList(),
        );
      }
    }
    
    // Diğer durumlarda direkt göster
    return Text(onceki.toString(), style: const TextStyle(fontSize: 15));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ad Soyad: ${_str(hasta['ad_soyad'])}', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.cyan)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Kapat',
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hasta Temel Bilgileri - İkonlarla
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hasta Bilgileri', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.cyan)),
                    const Divider(color: Colors.cyan),
                    const SizedBox(height: 12),
                    _buildInfoRow('Ad Soyad', _str(hasta['ad_soyad']), Icons.person),
                    _buildInfoRow('Yaş', _str(hasta['yas']), Icons.cake),
                    _buildInfoRow('Cinsiyet', _str(hasta['cinsiyet']), Icons.wc),
                    _buildInfoRow('Başvuru Şikayeti', _str(hasta['basvuru_sikayeti']), Icons.medical_information),
                    _buildInfoRow('Önceki Görüntüleme', _str(hasta['onceki_goruntuleme']), Icons.image),
                    _buildInfoRow('Ameliyat', _str(hasta['ameliyat']), Icons.local_hospital),
                    _buildInfoRow('Patoloji Sonucu', _str(hasta['patoloji'] ?? 'yok'), Icons.science),
                    _buildInfoRow('Doğum Öyküsü', _str(hasta['dogum_oykusu']), Icons.child_friendly),
                    _buildInfoRow('Tansiyon', _str(hasta['tansiyon'] ?? '110/70 mmHg'), Icons.monitor_heart),
                    _buildInfoRow('Nabız', _str(hasta['nabiz']), Icons.favorite),
                    _buildInfoRow('Ateş', _str(hasta['ates']), Icons.thermostat),
                    _buildInfoRow('Önceki Tedavi', _str(hasta['onceki_tedavi']), Icons.medication),
                    _buildInfoRow('Uyarı', _str(hasta['uyari'] ?? 'yok'), Icons.warning),
                  ],
                ),
              ),
            ),
            
            // Önceki Tetkik Sonuçları (varsa)
            if (oncekiTetkik != null && oncekiTetkik != '' && oncekiTetkik != 'yok') ...[  
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Önceki Laboratuvar Tetkik Sonuçları',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.amber),
                      ),
                      const Divider(color: Colors.amber),
                      const SizedBox(height: 12),
                      _buildOncekiTetkik(oncekiTetkik),
                    ],
                  ),
                ),
              ),
            ],
            
            // Son Tetkik Sonuçları
            if (sonTetkik != null && sonTetkik!.isNotEmpty)
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.cyan.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Son Laboratuvar Tetkik Sonuçları',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.cyan),
                      ),
                      const Divider(color: Colors.cyan),
                      const SizedBox(height: 12),
                      _buildTetkikList(sonTetkik),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
          onPressed: () {
            if (sonTetkik != null && sonTetkik!.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TahlilAnalizSonuclariPage(tahlil: sonTetkik!),
                ),
              );
            }
          },
          child: const Text('Analiz Et'),
        ),
      ],
    );
  }
}
