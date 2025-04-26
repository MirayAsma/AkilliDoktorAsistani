import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({
    super.key,
    required this.patient,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _testReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTestReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTestReports() {
    // Simüle edilmiş veri yükleme gecikmesi - gerçek uygulamada bu bir API çağrısı olabilir
    Future.delayed(const Duration(seconds: 1), () {
      // Hasta için simüle edilmiş tahlil raporları
      final mockReports = [
        {
          'id': '1',
          'date': '05.04.2025',
          'type': 'Kan Tahlili',
          'doctor': 'Dr. Mehmet Öz',
          'status': 'Tamamlandı',
          'results': [
            {'name': 'Hemoglobin', 'value': '14.2 g/dL', 'refRange': '13.5-17.5 g/dL', 'status': 'normal'},
            {'name': 'Lökosit', 'value': '7.500 /mm³', 'refRange': '4.000-10.000 /mm³', 'status': 'normal'},
            {'name': 'Trombosit', 'value': '245.000 /mm³', 'refRange': '150.000-450.000 /mm³', 'status': 'normal'},
            {'name': 'Glukoz', 'value': '110 mg/dL', 'refRange': '70-100 mg/dL', 'status': 'yüksek'},
          ]
        },
        {
          'id': '2',
          'date': '15.03.2025',
          'type': 'İdrar Tahlili',
          'doctor': 'Dr. Ayşe Kaya',
          'status': 'Tamamlandı',
          'results': [
            {'name': 'pH', 'value': '6.2', 'refRange': '4.5-8.0', 'status': 'normal'},
            {'name': 'Protein', 'value': 'Negatif', 'refRange': 'Negatif', 'status': 'normal'},
            {'name': 'Glukoz', 'value': 'Negatif', 'refRange': 'Negatif', 'status': 'normal'},
          ]
        },
        {
          'id': '3',
          'date': '22.02.2025',
          'type': 'Karaciğer Fonksiyon Testleri',
          'doctor': 'Dr. Ahmet Yılmaz',
          'status': 'Tamamlandı',
          'results': [
            {'name': 'ALT', 'value': '32 U/L', 'refRange': '7-56 U/L', 'status': 'normal'},
            {'name': 'AST', 'value': '28 U/L', 'refRange': '5-40 U/L', 'status': 'normal'},
            {'name': 'ALP', 'value': '78 U/L', 'refRange': '44-147 U/L', 'status': 'normal'},
          ]
        },
      ];
      
      if (mounted) {
        setState(() {
          _testReports.addAll(mockReports);
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasta Detayı'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bilgiler'),
            Tab(text: 'Tahliller'),
            Tab(text: 'Randevular'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPatientInfoTab(),
          _buildTestReportsTab(),
          _buildAppointmentsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni tahlil raporu veya randevu ekleme işlemi burada yapılabilir
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu özellik henüz eklenmedi')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPatientInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(51),
                          child: Text(
                            (widget.patient['name'] as String).substring(0, 1),
                            style: TextStyle(
                              fontSize: 36,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.patient['name'] as String,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${widget.patient['age'] as String} yaş, ${widget.patient['gender'] as String}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Divider(height: 32),
                      ],
                    ),
                  ),
                  _buildInfoRow('Hasta No', '#${10000 + (widget.patient['id'] as int)}'),
                  _buildInfoRow('TC Kimlik No', '${11111111110 + (widget.patient['id'] as int)}'),
                  _buildInfoRow('Durum', widget.patient['condition'] as String),
                  _buildInfoRow('Son Ziyaret', widget.patient['lastVisit'] as String),
                  _buildInfoRow('Kan Grubu', _getRandomBloodType()),
                  _buildInfoRow('Adres', _getRandomAddress()),
                  _buildInfoRow('Telefon', _getRandomPhone()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notlar',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hasta ${widget.patient['condition'] as String} tanısı almıştır. '
                    'Düzenli kontrol önerilir. Son muayenede vital bulgular normal sınırlar içindeydi.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestReportsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_testReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tahlil raporu bulunamadı',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _testReports.length,
      itemBuilder: (context, index) {
        final report = _testReports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              report['type'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Tarih: ${report['date']}'),
                Text('Doktor: ${report['doctor']}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                report['status'] as String,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            children: [
              const Divider(height: 1),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Test',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Değer',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Referans Aralığı',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    ...List.generate(
                      (report['results'] as List).length,
                      (resultIndex) {
                        final result = (report['results'] as List)[resultIndex];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(result['name'] as String),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  result['value'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(result['status'] as String),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(result['refRange'] as String),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tahlil raporu indirildi')),
                            );
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('İndir'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tahlil raporu paylaşıldı')),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Paylaş'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsTab() {
    final formatter = DateFormat('dd.MM.yyyy');
    final today = DateTime.now();
    
    final upcomingAppointments = [
      {
        'date': formatter.format(today.add(const Duration(days: 7))),
        'time': '09:30',
        'doctor': 'Dr. Ahmet Yılmaz',
        'department': 'Kardiyoloji',
        'status': 'Onaylandı',
      },
      {
        'date': formatter.format(today.add(const Duration(days: 14))),
        'time': '14:15',
        'doctor': 'Dr. Zeynep Kaya',
        'department': 'Nöroloji',
        'status': 'Beklemede',
      },
    ];
    
    final pastAppointments = [
      {
        'date': formatter.format(today.subtract(const Duration(days: 14))),
        'time': '11:00',
        'doctor': 'Dr. Mehmet Öz',
        'department': 'Dahiliye',
        'status': 'Tamamlandı',
      },
      {
        'date': formatter.format(today.subtract(const Duration(days: 30))),
        'time': '10:45',
        'doctor': 'Dr. Ayşe Kaya',
        'department': 'Göz Hastalıkları',
        'status': 'Tamamlandı',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yaklaşan Randevular',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...upcomingAppointments.map((appointment) => _buildAppointmentCard(appointment, isUpcoming: true)),
          
          const SizedBox(height: 24),
          Text(
            'Geçmiş Randevular',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...pastAppointments.map((appointment) => _buildAppointmentCard(appointment, isUpcoming: false)),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, String> appointment, {required bool isUpcoming}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Text(
              '${appointment['date']} - ${appointment['time']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getAppointmentStatusColor(appointment['status']!).withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                appointment['status']!,
                style: TextStyle(
                  color: _getAppointmentStatusColor(appointment['status']!),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Doktor: ${appointment['doctor']}'),
            Text('Bölüm: ${appointment['department']}'),
            const SizedBox(height: 16),
            if (isUpcoming)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Randevu iptal edildi')),
                      );
                    },
                    child: const Text('İptal Et'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Randevu yeniden planlandı')),
                      );
                    },
                    child: const Text('Yeniden Planla'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'yüksek':
        return Colors.red;
      case 'düşük':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  Color _getAppointmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'onaylandı':
        return Colors.green;
      case 'beklemede':
        return Colors.orange;
      case 'tamamlandı':
        return Colors.blue;
      case 'iptal edildi':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String _getRandomBloodType() {
    final bloodTypes = ['A Rh+', 'A Rh-', 'B Rh+', 'B Rh-', 'AB Rh+', 'AB Rh-', '0 Rh+', '0 Rh-'];
    return bloodTypes[(widget.patient['id'] as int) % bloodTypes.length];
  }

  String _getRandomAddress() {
    final addresses = [
      'Atatürk Mah. Cumhuriyet Cad. No:45/6 Kartal/İstanbul',
      'Bahçelievler Mah. İnönü Sok. No:12 Daire:3 Üsküdar/İstanbul',
      'Yıldız Mah. Barbaros Bulvarı No:78 Beşiktaş/İstanbul',
      'Göztepe Mah. Bağdat Cad. No:156 Kadıköy/İstanbul',
    ];
    return addresses[(widget.patient['id'] as int) % addresses.length];
  }

  String _getRandomPhone() {
    final id = widget.patient['id'] as int;
    return '0532 ${500 + id} ${40 + id} ${60 + id}';
  }
}
