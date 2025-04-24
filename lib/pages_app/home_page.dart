import 'package:absensi_app/providers/absen_provider.dart'; // Pastikan path ini benar
import 'package:absensi_app/providers/auth_provider.dart';
import 'package:absensi_app/providers/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<LatLng?>? _locationFuture;

  @override
  void initState() {
    super.initState();
    _locationFuture =
        Provider.of<AbsenProvider>(context, listen: false).getCurrentLocation();
    // Periksa status check-in saat halaman dimuat
    Provider.of<AbsenProvider>(
      context,
      listen: false,
    ).checkIfCheckedIn(context);
    // Ambil data profil saat halaman dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchProfile(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final absenProvider = Provider.of<AbsenProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Format tanggal
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          homeProvider.profileData.isNotEmpty
              ? 'Hallo ${homeProvider.profileData['name'] ?? 'Pengguna'}'
              : 'Hallo Pengguna',
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  if (homeProvider.profileData.isNotEmpty)
                    Text(
                      homeProvider.profileData['name'] ?? 'Nama Pengguna',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat Absen'),
              onTap: () {
                Navigator.pushNamed(context, '/history_absen');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await Provider.of<HomeProvider>(
                  context,
                  listen: false,
                ).removeToken(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: FutureBuilder<LatLng?>(
                  future: _locationFuture,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<LatLng?> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Gagal mendapatkan lokasi: ${snapshot.error}',
                        ),
                      );
                    } else if (snapshot.data != null) {
                      return GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: snapshot.data!,
                          zoom: 17,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('currentLocation'),
                            position: snapshot.data!,
                          ),
                        },
                        onMapCreated: (GoogleMapController controller) {
                          absenProvider.setMapController(controller);
                        },
                        myLocationEnabled: true, // Aktifkan ikon lokasi saya
                        myLocationButtonEnabled:
                            false, // Nonaktifkan tombol default lokasi saya
                      );
                    } else {
                      return const Center(
                        child: Text('Lokasi belum tersedia.'),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  onPressed:
                      absenProvider.isLoading
                          ? null
                          : () => absenProvider.checkIn(context),
                  child:
                      absenProvider.isLoading
                          ? const CircularProgressIndicator(strokeWidth: 3.0)
                          : const Text('Absen Masuk'),
                ),
                ElevatedButton(
                  onPressed:
                      absenProvider.isCheckOutLoading ||
                              !absenProvider.isCheckOutEnabled
                          ? null
                          : () => absenProvider.checkOutProcess(context),
                  child:
                      absenProvider.isCheckOutLoading
                          ? const CircularProgressIndicator(strokeWidth: 3.0)
                          : const Text('Absen Pulang'),
                ),
              ],
            ),
            if (absenProvider.message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(absenProvider.message),
              ),
            if (absenProvider.checkOutMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(absenProvider.checkOutMessage),
              ),
          ],
        ),
      ),
    );
  }
}
