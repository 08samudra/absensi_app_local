import 'package:absensi_app/pages_app/absent_page.dart';
import 'package:absensi_app/providers/home_providers.dart'; // Mungkin ini tidak perlu jika sudah ada di bawah
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Memastikan profil diambil setelah build widget selesai
      Provider.of<HomeProvider>(context, listen: false).fetchProfile(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            // Tambahkan Riwayat Absen di bawah Profil
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat Absen'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/history_absen',
                ); // Nama route untuk halaman riwayat absen
              },
            ),
            //Dokumentasi untuk logout/stay app
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await Provider.of<HomeProvider>(
                  context,
                  listen: false,
                ).removeToken(context); // Tambahkan context sebagai argumen
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          if (homeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (homeProvider.errorMessage.isNotEmpty) {
            return Center(child: Text('Error: ${homeProvider.errorMessage}'));
          }

          if (homeProvider.profileData.isEmpty) {
            return const Center(child: Text('Data profil tidak tersedia.'));
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Selamat Datang, ${homeProvider.profileData['name']}!',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AbsentPage()),
                      );
                    },
                    child: const Text('Absen Check In'),
                  ),
                  // Anda bisa menambahkan informasi profil lain di sini jika perlu
                  // Text('Email: ${homeProvider.profileData['email'] ?? ''}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
