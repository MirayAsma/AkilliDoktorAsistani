import 'package:flutter/material.dart';
import 'test_results_screen.dart';


class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final List<Map<String, dynamic>> _confirmedPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadConfirmedPatients();
  }

  // _getStatusColor fonksiyonu kullanılmadığı için kaldırıldı

  void _loadConfirmedPatients() {
    // Simüle edilmiş veri yükleme
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _confirmedPatients.addAll([
            {
              'id': 1,
              'name': 'Elif Demir',
              'age': '45',
              'gender': 'Erkek',
              'appointmentDate': '12.04.2025',
              'appointmentTime': '09:30',
              'status': 'Onaylandı',
              'doctor': 'Dr. Mehmet Öz',
              'department': 'Kardiyoloji'
            },
            {
              'id': 2,
              'name': 'Tarık Basma',
              'age': '35',
              'gender': 'Kadın',
              'appointmentDate': '15.04.2025',
              'appointmentTime': '14:15',
              'status': 'Onaylandı',
              'doctor': 'Dr. Zeynep Kaya',
              'department': 'Dahiliye'
            },
            {
              'id': 3,
              'name': 'Ahmet Kalkan',
              'age': '62',
              'gender': 'Erkek',
              'appointmentDate': '18.04.2025',
              'appointmentTime': '11:00',
              'status': 'Onaylandı',
              'doctor': 'Dr. Ahmet Yılmaz',
              'department': 'Nöroloji'
            },
            {
              'id': 4,
              'name': 'Ayşegül Aslan',
              'age': '29',
              'gender': 'Kadın',
              'appointmentDate': '20.04.2025',
              'appointmentTime': '10:45',
              'status': 'Onaylandı',
              'doctor': 'Dr. Ali Kaya',
              'department': 'Göz Hastalıkları'
            },
          ]);
          _isLoading = false;
          _filteredPatients = List.from(_confirmedPatients);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hastalar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00BCD4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _confirmedPatients.clear();
                _filteredPatients.clear();
                _searchController.clear();
              });
              _loadConfirmedPatients();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF00BCD4)),
                  const SizedBox(height: 16),
                  Text(
                    'Hastalar yükleniyor...',
                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Arama kutusu
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A9E9E9E),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Hasta ismi ile ara...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF00BCD4)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _filteredPatients = List.from(_confirmedPatients);
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filteredPatients = _confirmedPatients.where((patient) =>
                            (patient['name'] as String).toLowerCase().contains(value.toLowerCase())
                          ).toList();
                        });
                      },
                    ),
                  ),
                // Hasta listesi
                Expanded(
                  child: _filteredPatients.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Hasta bulunamadı',
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Lütfen farklı bir arama terimi deneyin',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          itemCount: _filteredPatients.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final patient = _filteredPatients[index];
                            final String patientName = patient['name'] as String;
                            final String patientAge = patient['age'] as String;
                            final String patientGender = patient['gender'] as String;
                            final String department = patient['department'] as String;
                            
                            // Hasta adının ilk harfini al (avatar için)
                            final String initial = patientName.isNotEmpty ? patientName[0].toUpperCase() : '?';
                            
                            // Departmana göre ikon seç
                            IconData departmentIcon = Icons.medical_services;
                            Color departmentColor = const Color(0xFF00BCD4);
                            
                            if (department.toLowerCase().contains('kardiyoloji')) {
                              departmentIcon = Icons.favorite;
                              departmentColor = Colors.redAccent;
                            } else if (department.toLowerCase().contains('göz')) {
                              departmentIcon = Icons.visibility;
                              departmentColor = Colors.blueAccent;
                            } else if (department.toLowerCase().contains('nöroloji')) {
                              departmentIcon = Icons.psychology;
                              departmentColor = Colors.purpleAccent;
                            } else if (department.toLowerCase().contains('dahiliye')) {
                              departmentIcon = Icons.health_and_safety;
                              departmentColor = Colors.teal;
                            }
                            
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [BoxShadow(color: Color(0x1A9E9E9E), blurRadius: 8, offset: Offset(0, 3))],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    // Hasta kartına tıklandığında tahlil sonuçlarını göster
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TestResultsScreen(
                                          patientId: patient['id'] as int,
                                          patientName: patientName,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [Colors.white, Color(0xFFFAFAFA)],
                                      ),
                                      border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Avatar
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                                            ),
                                            boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))],
                                          ),
                                          child: Center(
                                            child: Text(
                                              initial,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Hasta bilgileri
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                patientName,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2C3E50),
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(patientGender.toLowerCase().contains('erkek') ? Icons.male : Icons.female, 
                                                       color: const Color(0xFF757575), size: 14),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '$patientAge yaş',
                                                    style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Icon(departmentIcon, color: departmentColor, size: 14),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      department,
                                                      style: TextStyle(color: departmentColor, fontSize: 14, fontWeight: FontWeight.w500),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Tahlil sonuçları butonu
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0x1A00BCD4),
                                          ),
                                          child: const Icon(
                                            Icons.science_outlined,
                                            color: Color(0xFF00BCD4),
                                            size: 20,
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
                ),
              ],
            ),
    );
  }
}
