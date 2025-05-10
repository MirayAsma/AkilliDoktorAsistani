import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:akilli_doktor_asistani/screens/tahlil_analiz_raporu_page.dart';
import '../services/openai_analysis_service.dart';
import '../services/api_key_service.dart';
import '../services/patient_notification_service.dart';
import '../widgets/api_key_dialog.dart';
import '../widgets/heart_page_transition.dart';
import '../widgets/notification_overlay.dart';
import '../widgets/notification_icon_button.dart';
import '../widgets/test_bildirim_butonu.dart';

// Ekran import'ları
import 'home_screen.dart';
import 'patients_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'login_screen.dart';

// API anahtarı artık güvenli bir şekilde saklanıyor
// Kullanıcı ilk kullanımda API anahtarını girecek

final List<Map<String, dynamic>> vakalar = [
  {
    'ad_soyad': 'Elif Demir',
    'yas': 25,
    'son_lab_tetkik': {'HGB': 10, 'WBC': 5500, 'PLT': 180000, 'Kreatinin': 0.8, 'Glukoz': 90},
    'basvuru_sikayeti': 'Baş ağrısı',
  },
  {
    'ad_soyad': 'Ahmet Yılmaz',
    'yas': 40,
    'son_lab_tetkik': {'HGB': 13, 'WBC': 7000, 'PLT': 220000, 'Kreatinin': 1.1, 'Glukoz': 105},
    'basvuru_sikayeti': 'Karın ağrısı',
  },
  {
    'ad_soyad': 'Zeynep Kaya',
    'yas': 32,
    'son_lab_tetkik': {'HGB': 11, 'WBC': 4300, 'PLT': 150000, 'Kreatinin': 0.9, 'Glukoz': 98},
    'basvuru_sikayeti': 'Yorgunluk',
  },
  {
    'ad_soyad': 'Mehmet Can',
    'yas': 55,
    'son_lab_tetkik': {'HGB': 15, 'WBC': 12000, 'PLT': 450000, 'Kreatinin': 1.5, 'Glukoz': 180},
    'basvuru_sikayeti': 'Nefes darlığı',
  },
  {
    'ad_soyad': 'Ayşe Polat',
    'yas': 60,
    'son_lab_tetkik': {'HGB': 9, 'WBC': 3900, 'PLT': 95000, 'Kreatinin': 2.2, 'Glukoz': 210},
    'basvuru_sikayeti': 'Çarpıntı',
  },
];

class AIAnalysisScreen extends StatelessWidget {
  const AIAnalysisScreen({super.key});

  // Ana ekrandaki ile aynı Drawer fonksiyonu
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Dr. İdris Baydar'), // Gerekirse dinamik yapabilirsin
            accountEmail: Text('Dahiliye'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.cyan),
            ),
            decoration: BoxDecoration(color: Color(0xFF00BCD4)),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Ana Sayfa'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen(user: {'name': 'Dr. İdris Baydar', 'department': 'Dahiliye'})),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Hastalar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PatientsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Randevular'),
            onTap: () {
              Navigator.pop(context);
              // Randevular ekranı için HomeScreen'e yönlendir ve Randevular tab'ini seç
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    user: {'name': 'Dr. İdris Baydar', 'department': 'Dahiliye'},
                  ),
                ),
              ).then((_) {
                // Not: Bu ideal bir çözüm değil, ama HomeScreen'e gittikten sonra 
                // randevular tab'ine geçiş için kullanıcı manuel olarak tıklayabilir
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite, color: Colors.red),
            title: Text('AI Asistan'),
            onTap: () {
              Navigator.pop(context); // Zaten AI Asistan ekranındayız, sadece drawer'i kapat
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Ayarlar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Yardım'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Çıkış Yap'),
            onTap: () {
              Navigator.pop(context);
              // Çıkış işlemi
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false, // Tüm stack'i temizle
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        drawer: _buildDrawer(context),

        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00BCD4),
            ),
            child: SafeArea(top: true, bottom: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'AI ASİSTAN',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      // Bildirim ikonu
                      const NotificationIconButton(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    color: Color(0xFF00BCD4),
                    child: TabBar(
                      indicator: BoxDecoration(), // Alt çizgiyi tamamen kaldır
                      
                      labelColor: Colors.white,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      unselectedLabelColor: Colors.white70,
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                      labelPadding: EdgeInsets.zero,
                      isScrollable: false,
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics, size: 20),
                              SizedBox(width: 8),
                              Text('Tahlil Analizi'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat, size: 20),
                              SizedBox(width: 8),
                              Text('Chatbot'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Tahlil Analizi Ekranı
            _HastaListesiWidget(),
            
            // Chatbot Ekranı
            _GeminiChatbotWidget(),
          ],
        ),
        floatingActionButton: TestBildirimButonu(),
      ),
    );
  }
}

class _HastaListesiWidget extends StatefulWidget {
  @override
  State<_HastaListesiWidget> createState() => _HastaListesiWidgetState();
}

class _HastaListesiWidgetState extends State<_HastaListesiWidget> {
  List<Map<String, dynamic>> _vakalar = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String? _openaiKey; // API anahtarını SharedPreferences'ten alacağız
  
  // Bildirim servisi
  final PatientNotificationService _notificationService = PatientNotificationService();

  @override
  void initState() {
    super.initState();
  
    // API anahtarını kontrol et ve al
    _checkApiKey().then((_) {
      // API anahtarı alındıktan sonra hazır olduğunu kontrol et
      if (_openaiKey != null && _openaiKey!.isNotEmpty) {
        print('API anahtarı hazır: ${_openaiKey!.substring(0, 5)}...');
      }
    });
  
    // Bildirim servisini başlat
    _notificationService.init();
    
    // Hoş geldin bildirimi göster
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeNotification();
    });
    
    // Hasta verilerini çek
    _fetchVakalar();
  }
  
  void _showWelcomeNotification() {
    if (mounted) {
      NotificationOverlay.show(
        context: context,
        title: 'Akıllı Doktor Asistanı',
        message: 'Yeni hasta raporları için bildirimler aktif edildi',
        icon: Icons.health_and_safety,
        backgroundColor: const Color(0xFF00BCD4),
      );
    }
  }
  
  // API anahtarını kontrol et ve gerekirse dialog göster
  Future<void> _checkApiKey() async {
    final hasKey = await ApiKeyService.hasApiKey();
    if (!hasKey && mounted) {
      _showApiKeyDialog();
    }
  }
  
  // API anahtarı giriş dialog'unu göster
  void _showApiKeyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ApiKeyDialog(
        onApiKeySaved: (apiKey) async {
          await ApiKeyService.saveApiKey(apiKey);
        },
      ),
    );
  }
  
  Future<void> _fetchVakalar() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Firestore'dan verileri çek
      debugPrint('[DEBUG] Firestore\'dan vakalar çekiliyor...');

      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('cases').get();
      if (snapshot.docs.isEmpty) {
        setState(() {
          _vakalar = List<Map<String, dynamic>>.from(vakalar);
          _isLoading = false;
        });
        return;
      }
      final patients = snapshot.docs.map((doc) {
        Map<String, dynamic> data = {};
        try {
          data = doc.data() as Map<String, dynamic>;
        } catch (e) {
          // Veri dönüşümü hatası durumunda boş Map kullan
        }
        
        return <String, dynamic>{
          ...data,
          'id': doc.id, // Firestore'dan id'yi ata
        };
      }).toList();
      
      // Verileri ekranda göster
      setState(() {
        _vakalar = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Veri çekme sırasında hata: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _analyzePatient(Map<String, dynamic> vaka) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Analiz sonuçlarını göster
      if (mounted) {
        Navigator.push(
          context,
          HeartPageTransition(
            page: TahlilAnalizRaporuPage(hastaId: vaka['id'] ?? ''),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'AI analiz sırasında hata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _vakalar.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vaka = _vakalar[index];
        final String? hastaId = vaka['id'];
        
        // Hasta şikayetine göre etiket rengi ve metni belirleme
        Color etiketRengi;
        String etiketMetni;
        
        if (index == 0) {
          etiketRengi = const Color(0xFF4CAF50); // Yeşil
          etiketMetni = 'Muayene';
        } else if (index == 1) {
          etiketRengi = const Color(0xFFFF9800); // Turuncu
          etiketMetni = 'Kontrol';
        } else if (index == 2) {
          etiketRengi = const Color(0xFF9C27B0); // Mor
          etiketMetni = 'Tahlil Sonuçları';
        } else if (index == 3) {
          etiketRengi = const Color(0xFF2196F3); // Mavi
          etiketMetni = 'İlk Muayene';
        } else {
          etiketRengi = const Color(0xFFFF9800); // Turuncu
          etiketMetni = 'Kontrol';
        }
        
        // Kaydırarak silme özelliği
        return Dismissible(
          key: Key(vaka['id'] ?? DateTime.now().toString()),
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            // Silme işlemi için onay al
            final bool? onay = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Hasta Kaydını Sil'),
                content: Text('${vaka["ad_soyad"]} isimli hasta kaydını silmek istediğinize emin misiniz?'),
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
              final String? hastaId = vaka['id'];
              if (hastaId == null || hastaId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hasta ID bulunamadı!')),
                );
                return false;
              }
              
              // Firestore'dan hasta kaydını sil
              await FirebaseFirestore.instance.collection('cases').doc(hastaId).delete();
              
              // Başarılı mesajı göster
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${vaka["ad_soyad"]} hasta kaydı silindi')),
                );
              }
              
              // Silme işlemi başarılı
              return true;
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hasta silme işlemi sırasında hata: $e')),
                );
              }
              return false;
            }
          },
          onDismissed: (direction) {
            // Hasta listesini güncelle
            _fetchVakalar();
          },
          child: Stack(
            children: [
              // Ana kart
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Hasta detaylarına git
                    _analyzePatient(vaka);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Üst kısım - isim ve etiket
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Bilgi sütunu
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vaka['ad_soyad'] ?? 'Hasta',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '${26 + (index % 2)}.04.2025 - ',
                                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                                        ),
                                        Text(
                                          '${9 + index}:${(index * 15) % 60 < 10 ? '0' : ''}${(index * 15) % 60}',
                                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Sağ taraf - RENKLİ KUTU (artık şikayet yazıyor)
                              Container(
                                constraints: const BoxConstraints(maxWidth: 120),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: etiketRengi.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  vaka['basvuru_sikayeti'] ?? '-',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: etiketRengi),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Sağ alt köşede analiz butonu
              Positioned(
                bottom: 8,
                right: 8,
                child: Material(
                  color: const Color(0xFF00BCD4), // Turkuaz
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _analyzePatient(vaka),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.analytics, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GeminiChatbotWidget extends StatefulWidget {
  @override
  State<_GeminiChatbotWidget> createState() => _GeminiChatbotWidgetState();
}

// Chat mesajı sınıfı
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class _GeminiChatbotWidgetState extends State<_GeminiChatbotWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late OpenAIAnalysisService _openaiService;
  String _openaiKey = ''; // API anahtarı ApiKeyService üzerinden güvenli şekilde alınacak

  @override
  void initState() {
    super.initState();
    _openaiService = OpenAIAnalysisService(apiKey: _openaiKey);
    _messages.add(ChatMessage(text: 'AI Doktor Asistanına Hoş Geldiniz! Size nasıl yardımcı olabilirim?', isUser: false));
    //_checkApiKey();
  }
  
  // API anahtarını kontrol et ve gerekirse dialog göster
  Future<void> _checkApiKey() async {
    final hasKey = await ApiKeyService.hasApiKey();
    if (!hasKey && mounted) {
      _showApiKeyDialog();
    }
  }
  
  // API anahtarı giriş dialog'unu göster
  void _showApiKeyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ApiKeyDialog(
        onApiKeySaved: (apiKey) async {
          await ApiKeyService.saveApiKey(apiKey);
          // OpenAI anahtarı burada kaydedildi, gerekirse _openaiService güncellenebilir.
        },
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    try {
      final response = await _openaiService.analyze(text);
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: 'Bir hata oluştu: $e', isUser: false));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return Align(
                alignment: message.isUser 
                    ? Alignment.centerRight 
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: message.isUser 
                        ? Colors.blue.shade100 
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Mesajınızı yazın...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
                color: const Color(0xFF00C6DF),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
