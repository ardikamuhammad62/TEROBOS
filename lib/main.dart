import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart'; // <-- tambahkan ini

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan const agar lebih efisien

    const Color mainBackgroundColor = Color(0xFF1E1E1E);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: mainBackgroundColor,
      ),
      home: const TerobosMonitorScreen(),
    );
  }
}

class TerobosMonitorScreen extends StatelessWidget {
  const TerobosMonitorScreen({super.key});

  static const double drawerWidth = 150.0; // Tambahkan ini untuk mendefinisikan drawerWidth

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          // 2. Bungkus child (ListView) dengan Container
          //    atau bisa juga pakai SizedBox(width: drawerWidth, child: ...)
          child: SizedBox(
            // 3. Atur lebarnya di sini
            width: drawerWidth,
            
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Header untuk drawer
                Container(
                  // Pastikan header juga menggunakan lebar yang sama
                  width: drawerWidth,
                  height: 150, // Tinggi header (sesuaikan)
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: const Center(
                    child : CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('terobos.png'),
                    ),
                    // child: Text(
                      // 'Menu Header',
                      // style: TextStyle(color: Colors.white, fontSize: 24),
                    // ),
                  ),
                ),
                
                // Item-item menu
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Beranda'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Pengaturan'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),

      // 1. AppBar untuk Judul
      appBar: AppBar(
        title: const Text('TEROBOS MONITOR'),
        backgroundColor: Colors.transparent, // Transparan agar menyatu
        elevation: 0, // Hilangkan bayangan
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 3. Box abu-abu besar di atas
            Container(
              height: 200, // Tentukan tinggi sesuai kebutuhan
              width: double.infinity, // Lebar penuh
              decoration: BoxDecoration(
                color: Colors.grey[800], // Warna abu-abu gelap
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Center(
                child: Text(
                  'Konten Utama TEROBOS MONITOR',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),

            const SizedBox(height: 20), // Beri jarak
            // 4. Grid 2x2
            // Kita bungkus dengan Expanded agar GridView mengisi sisa ruang
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: [
                  const SuhuCard(), // <-- ganti panggilan _buildSensorCard untuk Suhu dengan widget yang realtime
                  _buildSensorCard(
                    'Cahaya',
                    Icons.wb_sunny,
                    const Color(0xFFF0AD4E),
                  ),
                  _buildSensorCard(
                    'Hujan',
                    Icons.water_drop,
                    const Color(0xFF5BC0DE),
                  ),
                  _buildSensorCard(
                    'Kelembapan',
                    Icons.opacity,
                    const Color(0xFF5CB85C),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi untuk tombol +
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );

    // 2. Body utama menggunakan Column

    // 5. Floating Action Button di tengah
  }

  // Fungsi bantuan untuk membuat Card (agar kode tidak berulang)
  Widget _buildSensorCard(String title, IconData icon, Color color) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten
        children: [
          Icon(icon, size: 40.0, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget baru: card Suhu yang membaca realtime dari Realtime Database
class SuhuCard extends StatelessWidget {
  const SuhuCard({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference suhuRef = FirebaseDatabase.instance.ref('cuaca/suhu');

    return StreamBuilder<DatabaseEvent>(
      stream: suhuRef.onValue,
      builder: (context, snapshot) {
        String display = '—';
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          display = snapshot.data!.snapshot.value.toString();
        } else if (snapshot.hasError) {
          display = 'Err';
        }

        return Card(
          color: const Color(0xFFD9534F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.thermostat, size: 40.0, color: Colors.white),
              const SizedBox(height: 8),
              const Text(
                'Suhu',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$display °C',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}
