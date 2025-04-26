import 'package:flutter/material.dart';

class HomeMenuScreen extends StatelessWidget {
  final List<MenuItem> menuItems = [
    MenuItem('Hastalıklarım', Icons.favorite, Colors.redAccent),
    MenuItem('Reçetelerim', Icons.medical_services, Colors.blueAccent),
    MenuItem('Radyoloji Görüntülerim', Icons.image, Colors.teal),
    MenuItem('Laboratuvar Sonuçlarım', Icons.science, Colors.cyan),
    MenuItem('Alerjilerim', Icons.warning, Colors.orangeAccent),
    MenuItem('Raporlarım', Icons.insert_drive_file, Colors.green),
    MenuItem('Dokümanlarım', Icons.description, Colors.purple),
    MenuItem('Acil Durum Notlarım', Icons.medical_information, Colors.deepOrange),
  ];

  HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Menü'),
        backgroundColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${item.title}" seçildi!')),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: item.color.withAlpha(217),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withAlpha(64),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 44, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profilim'),
          BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'Çıkış'),
        ],
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  MenuItem(this.title, this.icon, this.color);
}
