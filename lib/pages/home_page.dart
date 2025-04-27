import 'package:absensi_app/widgets/home_drawer.dart';
import 'package:absensi_app/providers/absen_provider.dart';
import 'package:absensi_app/providers/home_provider.dart';
import 'package:absensi_app/services/map_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    Provider.of<MapService>(context, listen: false).getCurrentLocation();
    Provider.of<AbsenProvider>(
      context,
      listen: false,
    ).checkIfCheckedIn(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchProfile(context);
    });
  }

  void _updateLocation() async {
    await Provider.of<MapService>(context, listen: false).getCurrentLocation();
    final mapProvider = Provider.of<MapService>(context, listen: false);
    if (mapProvider.currentLatLng != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(mapProvider.currentLatLng!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final absenProvider = Provider.of<AbsenProvider>(context);
    final mapProvider = Provider.of<MapService>(context);

    final formattedDate = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          homeProvider.profileData.isNotEmpty
              ? 'Hallo ${homeProvider.profileData['name'] ?? 'Pengguna'}'
              : 'Hallo Pengguna',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _updateLocation,
            tooltip: 'Perbarui Lokasi',
          ),
        ],
      ),
      drawer: const HomeDrawer(), // Gunakan widget HomeDrawer
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              // Tambahkan Card di sini
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildMap(mapProvider),
              ),
            ),
            const SizedBox(height: 16),
            _buildAbsenButtons(absenProvider),
            if (absenProvider.message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(absenProvider.message),
              ),
            if (absenProvider.checkOutMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(absenProvider.checkOutMessage),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(MapService mapProvider) {
    return SizedBox(
      height:
          MediaQuery.of(context).size.height *
          0.4, // Sesuaikan tinggi sesuai kebutuhan
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          16,
        ), // Radius lebih kecil agar pas di dalam Card
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: mapProvider.currentLatLng ?? const LatLng(0, 0),
            zoom: 17,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            mapProvider.setMapController(controller);
          },
          markers: {},
        ),
      ),
    );
  }

  Widget _buildAbsenButtons(AbsenProvider absenProvider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed:
                absenProvider.isLoading
                    ? null
                    : () => absenProvider.checkIn(context),
            child:
                absenProvider.isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text('Absen Masuk', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed:
                absenProvider.isCheckOutLoading ||
                        !absenProvider.isCheckOutEnabled
                    ? null
                    : () => absenProvider.checkOutProcess(context),
            child:
                absenProvider.isCheckOutLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'Absen Pulang',
                      style: TextStyle(fontSize: 16),
                    ),
          ),
        ),
      ],
    );
  }
}
