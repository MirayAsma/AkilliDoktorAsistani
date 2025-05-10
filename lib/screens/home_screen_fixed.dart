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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Hastalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Randevular',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
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
        return const PatientsScreen();
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
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: const Text(
              'AI Asistan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
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

  Widget _buildHomeTab() {
    final dateFormat = DateFormat('d MMMM yyyy, EEEE', 'tr_TR');
    final formattedDate = dateFormat.format(DateTime.now());
    final List<Map<String, dynamic>> appointments = [
      {
        "name": "Elif Demir",
        "type": "Muayene",
        "time": "09:00",
        "age": 29,
        "gender": "Kadın",
        "status": "Onaylandı"
      },
      {
        "name": "Tarık Basma",
        "type": "Kontrol",
        "time": "09:30",
        "age": 41,
        "gender": "Erkek",
        "status": "Beklemede"
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Randevular Kartı
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.calendar_month, color: Colors.purple, size: 24),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 2),
                  const Text(
                    "Bugünkü Randevular",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  ...appointments.map((appointment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.teal[50],
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal[200],
                              child: Icon(
                                appointment['type'] == 'Muayene'
                                    ? Icons.medical_services
                                    : appointment['type'] == 'Kontrol'
                                        ? Icons.check_circle_outline
                                        : Icons.event_note,
                                color: Colors.white,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  "${appointment['name']}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  " (${appointment['age']} ${appointment['gender']})",
                                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${appointment['type']} • ${appointment['time']}",
                                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getColor(appointment['status']).withAlpha(38),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        appointment['status'].toString(),
                                        style: TextStyle(
                                          color: _getColor(appointment['status']),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minLeadingWidth: 0,
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
          
          // Bildirimler Kutucuğu
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.notifications, color: Colors.blue, size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Bildirimler",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // Bildirim Öğeleri
                  const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                    title: Text("Hasta Raporları Hazır"),
                    subtitle: Text("Elif Demir'in test sonuçları hazır"),
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.access_time, color: Colors.white),
                    ),
                    title: Text("Randevu Hatırlatma"),
                    subtitle: Text("Yarın 3 randevunuz bulunmaktadır"),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          
          // Günün İstatistikleri Kutucuğu
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.analytics, color: Colors.amber, size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Günün İstatistikleri",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // İstatistik Kartları
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: "Toplam Hasta",
                          value: "5",
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: "Kontrol",
                          value: "2",
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: "Muayene",
                          value: "3",
                          icon: Icons.medical_services,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: "Bekleyen",
                          value: "1",
                          icon: Icons.hourglass_empty,
                          color: Colors.orange,
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
  
  // İstatistik kartı widget'ı
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String status) {
    switch (status.toLowerCase()) {
      case 'onaylandı':
        return Colors.green;
      case 'beklemede':
        return Colors.orange;
      case 'iptal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAppointmentsTab() {
    final List<Map<String, String>> appointments = [
      {'date': '26.04.2025', 'time': '09:00', 'patient': 'Elif Demir', 'reason': 'Muayene'},
      {'date': '26.04.2025', 'time': '09:30', 'patient': 'Tarık Basma', 'reason': 'Kontrol'},
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
            title: Text('${appointment['patient']} - ${appointment['reason']}'),
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
