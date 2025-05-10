import 'package:flutter/material.dart';
import 'package:akilli_doktor_asistani/screens/login_screen.dart';
import 'package:akilli_doktor_asistani/services/auth_service.dart';
import 'package:akilli_doktor_asistani/screens/patients_screen.dart';
import 'package:akilli_doktor_asistani/screens/ai_analysis_screen.dart';
import 'package:akilli_doktor_asistani/screens/settings_screen.dart';
import 'package:akilli_doktor_asistani/screens/help_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthService _authService;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  final List<String> _appBarTitles = [
    'Ana Sayfa',
    'Hastalar',
    'Randevular',
    'Profil',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, color: Colors.black),
            label: 'Hastalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, color: Colors.black),
            label: 'Randevular',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        // Hastalar ekranında ikinci başlık görünmemesi için doğrudan PatientsScreen'i döndür
        return const Scaffold(
          body: PatientsScreen(),
          appBar: null, // AppBar'i kaldır, PatientsScreen kendi AppBar'ını kullanacak
        );
      case 2:
        return _buildAppointmentsTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.user['name'] ?? ''),
            accountEmail: Text(widget.user['department'] ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (widget.user['name'] ?? '').toString().isNotEmpty 
                    ? widget.user['name'].toString().substring(0, 1) 
                    : '',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Ana Sayfa'),
            selected: _selectedIndex == 0,
            onTap: () {
              setState(() {
                _selectedIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Hastalar'),
            selected: _selectedIndex == 1,
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Randevular'),
            selected: _selectedIndex == 2,
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red, size: 28),
            title: const Text(
              'AI Asistan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black, // Siyah yazı
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIAnalysisScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ayarlar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Yardım'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Çıkış Yap'),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  // Randevu türüne göre ikon belirleme yardımcı fonksiyonu
  IconData _getAppointmentTypeIcon(String type) {
    switch (type) {
      case 'Muayene':
        return Icons.medical_services;
      case 'Kontrol':
        return Icons.check_circle;
      case 'Tahlil Sonuçları':
        return Icons.science;
      case 'İlk Muayene':
        return Icons.person_add;
      default:
        return Icons.event_note;
    }
  }
  
  // Randevu türüne göre renk belirleme yardımcı fonksiyonu
  Color _getAppointmentTypeColor(String type) {
    switch (type) {
      case 'Muayene':
        return const Color(0xFF00BCD4); // Turkuaz
      case 'Kontrol':
        return const Color(0xFFFFA726); // Turuncu
      case 'Tahlil Sonuçları':
        return const Color(0xFF9C27B0); // Mor
      case 'İlk Muayene':
        return const Color(0xFF4CAF50); // Yeşil
      default:
        return Colors.grey;
    }
  }
  
  // Randevu durumuna göre renk belirleme yardımcı fonksiyonu
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Onaylandı':
        return Colors.green; // Yeşil renk
      case 'Beklemede':
        return const Color(0xFFFF9800); // Turuncu
      case 'İptal Edildi':
        return const Color(0xFFF44336); // Kırmızı
      default:
        return Colors.grey;
    }
  }

  // İstatistik kartı oluşturma yardımcı fonksiyonu
  Widget _buildStatisticCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final dateFormat = DateFormat('d MMMM yyyy, EEEE', 'tr_TR');
    final formattedDate = dateFormat.format(DateTime.now());
    final List<Map<String, dynamic>> appointments = [
      {
        "name": "Ahmet Kalkan",
        "type": "Muayene",
        "time": "09:00",
        "status": "Onaylandı"
      },
      {
        "name": "Ayşegül Aslan",
        "type": "Kontrol",
        "time": "10:30",
        "status": "Beklemede"
      },
      {
        "name": "Ali Kapı",
        "type": "Tahlil Sonuçları",
        "time": "10:00",
        "status": "Onaylandı"
      },
    ];

    final List<Map<String, dynamic>> notifications = [
      {
        "title": "Bildirimler",
        "icon": Icons.notifications_active,
        "color": Colors.blue,
        "items": [
          {
            "title": "Acil Durum",
            "subtitle": "Acil kan nakline ihtiyaç var",
            "icon": Icons.warning,
            "color": Colors.red,
            "time": "10 dakika önce"
          },
        ]
      },
      {
        "title": "Yeni Mesaj",
        "icon": Icons.email,
        "color": Colors.teal,
        "items": [
          {
            "title": "Dr. Ahmet'ten yeni mesaj",
            "subtitle": "Toplantı saati değişti",
            "icon": Icons.email,
            "color": Colors.teal,
            "time": "1 saat önce"
          },
        ]
      },
      {
        "title": "Randevu Hatırlatma",
        "icon": Icons.calendar_today,
        "color": Colors.green,
        "items": [
          {
            "title": "Yarın 3 randevunuz var",
            "subtitle": "Detaylar için tıklayın",
            "icon": Icons.event_note,
            "color": Colors.green,
            "time": "2 saat önce"
          },
        ]
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarih Gösterimi - Beyaz kart, siyah yazı tasarımı
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF00BCD4), size: 20),
                const SizedBox(width: 12),
                Text(
                  formattedDate,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF333333)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Bugünkü Randevular Başlığı - Daha belirgin ve şık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bugünkü Randevular',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF333333)),
              ),
              TextButton(
                onPressed: () {
                  // Tüm randevuları görüntüleme sayfasına git
                  setState(() {
                    _selectedIndex = 2; // Randevular sekmesine git
                  });
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
                  'Tümünü Gör',
                  style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Bugünkü Randevular Listesi - Daha şık kartlar
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: _getAppointmentTypeColor(appointment["type"].toString()),
                    child: Icon(
                      _getAppointmentTypeIcon(appointment["type"].toString()),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    appointment["name"].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF333333)),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        appointment["type"].toString(),
                        style: TextStyle(
                          color: _getAppointmentTypeColor(appointment["type"].toString()),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const Text(' • ', style: TextStyle(color: Colors.grey)),
                      Text(
                        appointment["time"].toString(),
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStatusColor(appointment["status"].toString()).withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment["status"].toString(),
                      style: TextStyle(
                        color: _getStatusColor(appointment["status"].toString()),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Bildirimler Başlığı - Daha belirgin ve şık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bildirimler',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF333333)),
              ),
              TextButton(
                onPressed: () {
                  // Bildirimler sayfasına git
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
                  'Tümünü Gör',
                  style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Bildirimler Listesi - Daha şık kartlar
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notifications.length,
            itemBuilder: (context, sectionIndex) {
              final section = notifications[sectionIndex];
              final items = section["items"] as List;
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, itemIndex) {
                  final item = items[itemIndex];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: (item["color"] as Color).withAlpha(51),
                        child: Icon(
                          item["icon"] as IconData,
                          color: item["color"] as Color,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item["title"].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF333333)),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["subtitle"].toString(),
                            style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item["time"].toString(),
                            style: const TextStyle(color: Color(0xFF999999), fontSize: 12),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
          
          // Günün İstatistikleri Kutucu
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BCD4).withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.analytics, color: Color(0xFF00BCD4), size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Günün İstatistikleri",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF333333)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  
                  // İstatistik Kartları - Daha şık tasarım
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatisticCard(
                          "Toplam Hasta",
                          "5",
                          Icons.people,
                          const Color(0xFF00BCD4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatisticCard(
                          "Kontrol",
                          "2",
                          Icons.check_circle,
                          const Color(0xFFFFA726),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatisticCard(
                          "Muayene",
                          "3",
                          Icons.medical_services,
                          const Color(0xFF9C27B0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatisticCard(
                          "Bekleyen",
                          "1",
                          Icons.hourglass_empty,
                          const Color(0xFFF44336),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Randevu sebebine göre renk belirleme yardımcı fonksiyonu
  Color _getReasonColor(String? reason) {
    switch (reason) {
      case 'Muayene':
        return Colors.green;
      case 'Kontrol':
        return Colors.orange;
      case 'Tahlil Sonuçları':
        return const Color(0xFFA259FF); // Mor
      case 'İlk Muayene':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  Widget _buildAppointmentsTab() {
    final List<Map<String, String>> appointments = [
      {'date': '26.04.2025', 'time': '09:00', 'patient': 'Ahmet Kalkan', 'reason': 'Muayene'},
      {'date': '26.04.2025', 'time': '10:30', 'patient': 'Ayşegül Aslan', 'reason': 'Kontrol'},
      {'date': '26.04.2025', 'time': '13:15', 'patient': 'Tarık Basma', 'reason': 'Tahlil Sonuçları'},
      {'date': '26.04.2025', 'time': '15:45', 'patient': 'Meryem Asmalı', 'reason': 'İlk Muayene'},
      {'date': '27.04.2025', 'time': '09:30', 'patient': 'Elif Demir', 'reason': 'Kontrol'},
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    appointment['patient'] ?? '',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getReasonColor(appointment['reason']).withAlpha(31),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    appointment['reason'] ?? '',
                    style: TextStyle(
                      color: _getReasonColor(appointment['reason']),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text('${appointment['date']} - ${appointment['time']}'),
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return const Center(
      child: Text('Profil Sayfası'),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }
}
