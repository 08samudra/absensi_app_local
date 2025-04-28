import 'dart:async';
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
  late Timer _timer;
  String _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());

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

    // Timer untuk update jam tiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
      drawer: const HomeDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDateAndClock(formattedDate),
            const SizedBox(height: 16),
            _buildMapCard(mapProvider),
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

  Widget _buildDateAndClock(String formattedDate) {
    return Column(
      children: [
        Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 99, 99, 99),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 114, 135, 150).withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _currentTime,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard(MapService mapProvider) {
    final bool isMapReady = mapProvider.currentLatLng != null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child:
              isMapReady
                  ? _buildMap(mapProvider)
                  : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Memuat peta...",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildMap(MapService mapProvider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: mapProvider.currentLatLng!,
          zoom: 17,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapToolbarEnabled: true,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        onMapCreated: (controller) {
          _mapController = controller;
          mapProvider.setMapController(controller);
        },
        markers: {},
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
