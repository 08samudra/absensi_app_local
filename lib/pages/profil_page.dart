import 'package:absensi_app/pages/edit_profile_page.dart';
import 'package:absensi_app/providers/home_provider.dart';
import 'package:absensi_app/providers/riwayat_absen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(
        // Gunakan HomeProvider
        context,
        listen: false,
      ).fetchProfile(context);
      Provider.of<RiwayatAbsenProvider>(
        context,
        listen: false,
      ).getHistoryAbsens(context: context); // Tambahkan context
    });
  }

  Future<void> _reloadProfile() async {
    print('Memuat ulang profil...'); // Tambahkan print
    await Provider.of<HomeProvider>(
      // Gunakan HomeProvider
      context,
      listen: false,
    ).fetchProfile(context);
    print('Profil selesai dimuat ulang.'); // Tambahkan print
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna')),
      body: Consumer<HomeProvider>(
        // Gunakan Consumer untuk HomeProvider
        builder: (context, homeProvider, child) {
          print('Consumer<HomeProvider> membangun...'); // Tambahkan print
          if (homeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (homeProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                'Error: ${homeProvider.errorMessage}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (homeProvider.profileData.isEmpty) {
            return const Center(child: Text('Data profil tidak tersedia.'));
          }

          final profile = homeProvider.profileData;
          final String name = profile['name'] ?? 'Tidak ada nama';
          final String email = profile['email'] ?? 'Tidak ada email';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 70, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Consumer<RiwayatAbsenProvider>(
                  builder: (context, riwayatAbsenProvider, child) {
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Informasi Absensi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text(
                                  'Total Absen:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '${riwayatAbsenProvider.totalAbsen} Hari',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text(
                                  'Total Izin:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '${riwayatAbsenProvider.totalIzin} Hari',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      print('Tombol Edit Ditekan'); // Tambahkan print
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(),
                        ),
                      );
                      print(
                        'Kembali dari Edit Page dengan hasil: $updated',
                      ); // Tambahkan print
                      if (updated == true) {
                        _reloadProfile(); // Muat ulang profil jika ada perubahan
                      }
                    },
                    child: const Text(
                      'Edit Profil',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
