import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yardım'),
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpSection(
              'Uygulama Hakkında',
              'Akıllı Doktor Asistanı, sağlık profesyonelleri için geliştirilmiş bir hastane yönetim uygulamasıdır. '
              'Hasta bilgilerini görüntüleme, tahlil sonuçlarını analiz etme ve QR kod tarama gibi özellikler sunar.',
              Icons.info_outline,
            ),
            _buildHelpSection(
              'AI Asistan Nasıl Kullanılır?',
              'AI Asistan ekranında hasta listesinden bir hasta seçin. Sistem otomatik olarak hastanın laboratuvar '
              'sonuçlarını analiz edecek ve size bir rapor sunacaktır.',
              Icons.psychology,
            ),
            _buildHelpSection(
              'QR Kod Tarama',
              'QR Kod Tarama özelliği ile hasta bilgilerine hızlıca erişebilirsiniz. Ana ekrandan QR Kod Tarama '
              'seçeneğini seçin ve hasta bilgilerini içeren QR kodu taratın.',
              Icons.qr_code_scanner,
            ),
            _buildHelpSection(
              'Güvenlik',
              'Uygulamaya giriş yapmak için TC Kimlik No veya Hastane ID\'nizi ve şifrenizi kullanın. '
              'Güvenliğiniz için uygulamadan çıkış yaptığınızdan emin olun.',
              Icons.security,
            ),
            _buildHelpSection(
              'Sorun Bildirme',
              'Herhangi bir sorunla karşılaşırsanız, lütfen IT desteği ile iletişime geçin: '
              'support@akillidoktorasistani.com',
              Icons.report_problem,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text('Anladım'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, String content, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.cyan, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
