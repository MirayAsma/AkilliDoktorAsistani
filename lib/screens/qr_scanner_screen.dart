import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class QRScannerScreen extends StatefulWidget {
  final Function(String) onScan;

  const QRScannerScreen({
    super.key,
    required this.onScan,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController controller;
  bool _hasScanned = false;
  bool _isCameraInitialized = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    
    // Web platformunda kamera erişimi için kullanıcı etkileşimi gerektiğinden
    // kamera başlatma işlemi butonla yapılacak
    if (!kIsWeb) {
      _initializeCamera();
    }
  }
  
  void _initializeCamera() {
    setState(() {
      _isCameraInitialized = true;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Tarayıcı'),
        actions: [
          if (_isCameraInitialized && !kIsWeb)
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: controller.torchState,
                builder: (context, state, child) {
                  switch (state) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off);
                    case TorchState.on:
                      return const Icon(Icons.flash_on);
                  }
                },
              ),
              onPressed: () => controller.toggleTorch(),
            ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Hata mesajı varsa göster
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade700),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }
    
    // Web'de ve kamera başlatılmadıysa başlatma butonu göster
    if (kIsWeb && !_isCameraInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 64),
            const SizedBox(height: 16),
            const Text(
              'QR kodu taramak için kamera erişimi gerekiyor',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Kamerayı Başlat'),
              onPressed: _initializeCamera,
            ),
          ],
        ),
      );
    }

    // Kamera tarayıcısını göster
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty && !_hasScanned) {
              final String? code = barcodes.first.rawValue;
              if (code != null) {
                _hasScanned = true;
                widget.onScan(code);
              }
            }
          },
          errorBuilder: (context, error, child) {
            setState(() {
              _isCameraInitialized = false;
              _errorMessage = 'Kamera erişiminde hata: $error';
            });
            return Container();
          },
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'QR kodu çerçeveye yerleştirin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
