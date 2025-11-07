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
          
          child: SizedBox(
            
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
                  // Menampilkan suhu dari path cuaca/suhu
                  const RealtimeSensorCard(
                    path: 'cuaca/suhu',
                    title: 'Suhu',
                    icon: Icons.thermostat,
                    unit: '°C',
                    color: Color(0xFFD9534F),
                  ),

                       // Cahaya: membaca path digital (0/1) atau analog (threshold)
                       const BinarySensorCard(
                         title: 'Cahaya',
                         dbPath: 'cuaca/ldr_analog',
                         trueLabel: 'Terang',
                         falseLabel: 'Redup',
                         trueIcon: Icons.wb_sunny,
                         falseIcon: Icons.nights_stay,
                         trueColor: Color(0xFFF0AD4E),
                         falseColor: Color(0xFF6C5B7B),
                         // Jika Anda hanya punya ldr_analog, ganti dbPath ke 'cuaca/ldr_analog'
                       ),
                       
                       // Hujan: membaca 0/1
                       const BinarySensorCard(
                         title: 'Hujan',
                         dbPath: 'cuaca/hujan_analog',
                         trueLabel: 'Hujan',
                         falseLabel: 'Tidak Hujan',
                         trueIcon: Icons.umbrella,
                         falseIcon: Icons.wb_cloudy,
                         trueColor: Color(0xFF5BC0DE),
                         falseColor: Color(0xFFB0BEC5),
                       ),

                  const RealtimeSensorCard(
                    path: 'cuaca/kelembaban',
                    title: 'Kelembapan',
                    icon: Icons.opacity,
                    unit: '%',
                    color: Color(0xFF5CB85C),
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

  // (Dihapus) fungsi pembantu statis digantikan oleh RealtimeSensorCard
}

// Generic realtime sensor card that reads a single path from Realtime Database.
class RealtimeSensorCard extends StatelessWidget {
  final String path;
  final String title;
  final IconData icon;
  final String unit;
  final Color color;

  const RealtimeSensorCard({
    super.key,
    required this.path,
    required this.title,
    required this.icon,
    this.unit = '',
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final DatabaseReference ref = FirebaseDatabase.instance.ref(path);

    return StreamBuilder<DatabaseEvent>(
      stream: ref.onValue,
      builder: (context, snapshot) {
        String display = '—';
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          display = snapshot.data!.snapshot.value.toString();
        } else if (snapshot.hasError) {
          display = 'Err';
        }

        return Card(
          color: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 6),
              Text(
                unit.isNotEmpty ? '$display $unit' : display,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CuacaPanel extends StatelessWidget {
  const CuacaPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference cuacaRef = FirebaseDatabase.instance.ref('cuaca');

    return StreamBuilder<DatabaseEvent>(
      stream: cuacaRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error membaca data'));
        }
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('Tidak ada data'));
        }

        final raw = snapshot.data!.snapshot.value;
        // Pastikan konversi aman ke Map<String, dynamic>
        final Map<String, dynamic> data = (raw is Map) ? Map<String, dynamic>.from(raw) : {};

        final suhu = data['suhu']?.toString() ?? '—';
        final kelembaban = data['kelembaban']?.toString() ?? '—';
        final hujanAnalog = data['hujan_analog']?.toString() ?? '—';
        final hujanDigital = data['hujan_digital']?.toString() ?? '—';
        final ldrAnalog = data['ldr_analog']?.toString() ?? '—';
        final ldrDigital = data['ldr_digital']?.toString() ?? '—';

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Suhu: $suhu °C', style: Theme.of(context).textTheme.titleLarge),
            Text('Kelembaban: $kelembaban %'),
            Text('Hujan (analog): $hujanAnalog'),
            Text('Hujan (digital): $hujanDigital'),
            Text('LDR (analog): $ldrAnalog'),
            Text('LDR (digital): $ldrDigital'),
          ],
        );
      },
    );
  }
}

  // Widget untuk sensor dengan dua state (0/1) atau analog dengan threshold
  class BinarySensorCard extends StatelessWidget {
    final String title;
    final String dbPath; // contoh: 'cuaca/hujan_digital' atau 'cuaca/ldr_analog'
    final String trueLabel;
    final String falseLabel;
    final IconData trueIcon;
    final IconData falseIcon;
    final Color trueColor;
    final Color falseColor;
    final double analogThreshold; // jika path mengeluarkan nilai analog, >= threshold => true

    const BinarySensorCard({
      super.key,
      required this.title,
      required this.dbPath,
      required this.trueLabel,
      required this.falseLabel,
      required this.trueIcon,
      required this.falseIcon,
      required this.trueColor,
      required this.falseColor,
      this.analogThreshold = 1.0,
    });

    @override
    Widget build(BuildContext context) {
      final DatabaseReference ref = FirebaseDatabase.instance.ref(dbPath);

      return StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          // Default state unknown
          bool? state;
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final v = snapshot.data!.snapshot.value;

            // Jika value adalah int 0/1
            if (v is int) {
              state = (v == 1);
            } else if (v is String) {
              // coba parse sebagai int dulu
              final i = int.tryParse(v);
              if (i != null) {
                state = (i == 1);
              } else {
                // coba parse sebagai double (analog)
                final d = double.tryParse(v);
                if (d != null) state = d >= analogThreshold;
              }
            } else if (v is double) {
              state = (v >= analogThreshold);
            } else if (v is num) {
              state = (v.toDouble() >= analogThreshold);
            }
          }

          // determine display
          final bool isTrue = state == true;
          final displayLabel = state == null ? '—' : (isTrue ? trueLabel : falseLabel);
          final displayIcon = isTrue ? trueIcon : falseIcon;
          final displayColor = isTrue ? trueColor : falseColor;

          return Card(
            color: displayColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(displayIcon, size: 40.0, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  displayLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          );
        },
      );
    }
  }
