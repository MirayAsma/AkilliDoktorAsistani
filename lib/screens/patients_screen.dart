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
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4)),
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
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // "Tahlil Analizleri" yazısı kaldırıldı
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Hasta ismi ile ara...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF00BCD4)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  Expanded(
                    child: _filteredPatients.isEmpty
                        ? const Center(
                            child: Text(
                              'Aramanıza uygun hasta bulunamadı',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                            itemCount: _filteredPatients.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final patient = _filteredPatients[index];
                              // Sadece tıklanabilir olmayan bir kart ve tahlil sonuçları butonu
                              return Row(
                                children: [
                                  // Geniş kısım: Hasta bilgilerini gösteren tıklanabilir olmayan kart
                                  Expanded(
                                    child: Card(
                                      elevation: 1,
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      color: Colors.white, // Beyaz arka plan
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Daha ince yapıldı
                                        child: Row(
                                          children: [
                                            const Icon(Icons.person, color: Color(0xFF00BCD4)), // Siyah ikon
                                            const SizedBox(width: 16),
                                            Text(
                                              patient['name'] as String,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), // Siyah yazı
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8), // Aradaki boşluk
                                  // Tahlil sonuçları butonu
                                  Container(
                                    height: 46, // Daha küçük buton
                                    width: 46, // Daha küçük buton
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        backgroundColor: const Color(0xFF00BCD4),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Icon(Icons.science_outlined, color: Colors.white),
                                      onPressed: () {
                                        // Tahlil sonuçları butonuna tıklandığında tahlil sonuçlarını göster
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TestResultsScreen(
                                              patientId: patient['id'] as int,
                                              patientName: patient['name'] as String,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
