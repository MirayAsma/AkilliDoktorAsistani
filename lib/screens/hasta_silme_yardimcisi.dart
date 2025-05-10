import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Hasta silme işlemlerini yönetmek için yardımcı sınıf
class HastaSilmeYardimcisi {
  /// Hasta silme işlemi
  static Future<bool> hastaKaydiniSil({
    required BuildContext context,
    required String hastaId,
    required String hastaAdi,
  }) async {
    // Silme işlemi için onay al
    final bool? onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hasta Kaydını Sil'),
        content: Text('$hastaAdi isimli hasta kaydını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    
    // Onay verilmediyse işlemi iptal et
    if (onay != true) return false;
    
    try {
      // Firestore'dan hasta kaydını sil
      await FirebaseFirestore.instance.collection('cases').doc(hastaId).delete();
      
      // Başarılı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$hastaAdi hasta kaydı silindi')),
      );
      
      return true;
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hasta silme işlemi sırasında hata: $e')),
      );
      return false;
    }
  }
}
