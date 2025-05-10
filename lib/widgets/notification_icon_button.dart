import 'package:flutter/material.dart';
import '../screens/notification_screen.dart';
import '../services/notification_service.dart';
import '../widgets/heart_page_transition.dart';

class NotificationIconButton extends StatefulWidget {
  const NotificationIconButton({Key? key}) : super(key: key);

  @override
  State<NotificationIconButton> createState() => _NotificationIconButtonState();
}

class _NotificationIconButtonState extends State<NotificationIconButton> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    
    // Yeni bildirimler için dinleyici ekle
    _notificationService.notificationStream.listen((notification) {
      if (mounted) {
        setState(() {
          _unreadCount++;
        });
      }
    });
  }

  // Okunmamış bildirim sayısını yükle
  Future<void> _loadUnreadCount() async {
    // Gerçek uygulamada bu değer veritabanından yüklenebilir
    // Şimdilik örnek bir değer kullanıyoruz
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _unreadCount = 3; // Örnek değer
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            // Bildirim ekranına git
            Navigator.push(
              context,
              HeartPageTransition(
                page: const NotificationScreen(),
              ),
            ).then((_) {
              // Bildirim ekranından dönüldüğünde bildirimleri okundu olarak işaretle
              setState(() {
                _unreadCount = 0;
              });
            });
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
