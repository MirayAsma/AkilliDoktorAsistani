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
        title: const Text('Onaylanmış Hastalar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Tahlil Analizleri',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.cyan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Hasta ismi ile ara...',
                        prefixIcon: const Icon(Icons.search),
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
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.person),
                                  label: Text(
                                    patient['name'] as String,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Colors.cyan[50],
                                    foregroundColor: Colors.cyan[900],
                                    elevation: 1,
                                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
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
