import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../widgets/heart_page_transition.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> _notifications = [];
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    
    // Yeni bildirimler için dinleyici ekle
    _notificationService.notificationStream.listen((notification) {
      if (mounted) {
        setState(() {
          _notifications.insert(0, notification);
        });
      }
    });
  }

  // Bildirimleri yükle
  Future<void> _loadNotifications() async {
    // Burada gerçek bir veritabanından bildirimler yüklenebilir
    // Şimdilik örnek bildirimler oluşturalım
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _notifications.addAll([
          {
            'type': 'notification',
            'title': 'Yeni Hasta Raporu',
            'body': 'Ahmet Kalkan: Kabızlık, kilo kaybı',
            'data': {'patient_id': '1'},
            'timestamp': DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
            'read': true,
          },
          {
            'type': 'notification',
            'title': 'Yeni Hasta Raporu',
            'body': 'Ayşegül Aslan: Karın, kas ağrısı',
            'data': {'patient_id': '2'},
            'timestamp': DateTime.now().subtract(const Duration(hours: 5)).millisecondsSinceEpoch,
            'read': false,
          },
          {
            'type': 'notification',
            'title': 'Yeni Hasta Raporu',
            'body': 'Tarık Başma: Ayaklarda uyuşma',
            'data': {'patient_id': '3'},
            'timestamp': DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
            'read': true,
          },
          {
            'type': 'notification',
            'title': 'Yeni Hasta Raporu',
            'body': 'Meryem Asmalı: Kas ağrısı, yorgunluk',
            'data': {'patient_id': '4'},
            'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3)).millisecondsSinceEpoch,
            'read': false,
          },
          {
            'type': 'notification',
            'title': 'Yeni Hasta Raporu',
            'body': 'Elif Demir: Halsizlik',
            'data': {'patient_id': '5'},
            'timestamp': DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
            'read': true,
          },
        ]);
        _isLoading = false;
      });
    }
  }

  // Bildirimi okundu olarak işaretle
  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['read'] = true;
    });
  }

  // Bildirimi sil
  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  // Tüm bildirimleri okundu olarak işaretle
  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });
  }

  // Tarih formatını oluştur
  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BCD4),
        title: const Text('Bildirimler', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_notifications.any((notification) => notification['read'] == false))
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.white),
              onPressed: _markAllAsRead,
              tooltip: 'Tümünü okundu olarak işaretle',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz bildirim yok',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final bool isRead = notification['read'] as bool;
                    
                    return Dismissible(
                      key: Key('notification_${index}_${notification['timestamp']}'),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteNotification(index),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        elevation: isRead ? 1 : 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isRead
                              ? BorderSide.none
                              : const BorderSide(color: Color(0xFF00BCD4), width: 1.5),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            _markAsRead(index);
                            // Burada bildirime tıklandığında yapılacak işlemler
                            // Örneğin, hasta detay sayfasına yönlendirme
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bildirim ikonu
                                Container(
                                  decoration: BoxDecoration(
                                    color: isRead
                                        ? Colors.grey.shade200
                                        : const Color(0xFF00BCD4).withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.person,
                                    color: isRead
                                        ? Colors.grey.shade600
                                        : const Color(0xFF00BCD4),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Bildirim içeriği
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification['title'] as String,
                                        style: TextStyle(
                                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification['body'] as String,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatTimestamp(notification['timestamp'] as int),
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Okunmadı işareti
                                if (!isRead)
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00BCD4),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
