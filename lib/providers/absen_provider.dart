import 'package:absensi_app/locals/local_database.dart';
import 'package:absensi_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart'; // Import geocoding package

class AbsenProvider with ChangeNotifier {
  final LocalDatabase _db = LocalDatabase();
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  String _status = 'Masuk';
  String _alasanIzin = '';
  bool _isLoading = false;
  String _message = '';
  bool _isCheckOutLoading = false;
  String _checkOutMessage = '';
  bool _isCheckOutEnabled = false; // Kontrol tombol check-out

  LatLng? get currentLocation => _currentLocation;
  String get status => _status;
  String get alasanIzin => _alasanIzin;
  bool get isLoading => _isLoading;
  String get message => _message;
  bool get isCheckOutLoading => _isCheckOutLoading;
  String get checkOutMessage => _checkOutMessage;
  bool get isCheckOutEnabled => _isCheckOutEnabled;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  void setStatus(String value) {
    _status = value;
    notifyListeners();
  }

  void setAlasanIzin(String value) {
    _alasanIzin = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    _message = '';
    notifyListeners();
  }

  void setCheckOutLoading(bool value) {
    _isCheckOutLoading = value;
    _checkOutMessage = '';
    notifyListeners();
  }

  void setMessage(String value) {
    _message = value;
    notifyListeners();
  }

  void setCheckOutMessage(String value) {
    _checkOutMessage = value;
    notifyListeners();
  }

  Future<LatLng?> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentLocation = LatLng(position.latitude, position.longitude);
      return _currentLocation;
    } catch (e) {
      setMessage('Gagal mendapatkan lokasi: $e');
      notifyListeners();
      return null;
    }
  }

  Future<String?> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // Anda bisa menggabungkan beberapa bagian alamat sesuai kebutuhan
        return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}';
      }
      return null;
    } catch (e) {
      setMessage('Gagal mendapatkan nama lokasi: $e');
      notifyListeners();
      return null;
    }
  }

  Future<void> checkIn(BuildContext context) async {
    setLoading(true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.loggedInUserId;
    final now = DateTime.now();
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    if (userId == null) {
      setMessage('Pengguna tidak terautentikasi.');
      setLoading(false);
      return;
    }

    if (_currentLocation == null) {
      await getCurrentLocation();
      if (_currentLocation == null) {
        setLoading(false);
        return;
      }
    }

    String? locationName = await _getAddressFromLatLng(_currentLocation!);

    try {
      // Periksa apakah sudah ada absen masuk hari ini yang belum pulang
      List<Map<String, dynamic>> todayUncheckedIn = await _db
          .getTodayUncheckedOutAbsen(userId);

      if (todayUncheckedIn.isNotEmpty) {
        setMessage(
          'Anda sudah melakukan absen masuk hari ini dan belum melakukan absen pulang.',
        );
      } else {
        int id = await _db.insertAbsen({
          'user_id': userId,
          'check_in': formattedTime,
          'check_out': null,
          'latitude_in': _currentLocation!.latitude,
          'longitude_in': _currentLocation!.longitude,
          'latitude_out': null,
          'longitude_out': null,
          'status': _status,
          'alasan_izin': _status == 'izin' ? _alasanIzin : null,
          'location_in_name': locationName, // Simpan nama lokasi
        });

        if (id > 0) {
          setMessage(
            'Berhasil melakukan absen masuk pada $formattedTime di $locationName',
          );
          _isCheckOutEnabled =
              true; // Aktifkan tombol check-out setelah check-in
        } else {
          setMessage('Gagal melakukan absen masuk.');
        }
      }
    } catch (e) {
      setMessage('Terjadi kesalahan saat absen masuk: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> checkOutProcess(BuildContext context) async {
    setCheckOutLoading(true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.loggedInUserId;
    final now = DateTime.now();
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    if (userId == null) {
      setCheckOutMessage('Pengguna tidak terautentikasi.');
      setCheckOutLoading(false);
      return;
    }

    if (_currentLocation == null) {
      await getCurrentLocation();
      if (_currentLocation == null) {
        setCheckOutLoading(false);
        return;
      }
    }

    try {
      // Cari absensi hari ini yang belum check-out
      List<Map<String, dynamic>> todayAbsen = await _db
          .getTodayUncheckedOutAbsen(userId);
      if (todayAbsen.isNotEmpty) {
        int absenId = todayAbsen.first['id'];
        int rowsAffected = await _db.updateAbsen({
          'id': absenId,
          'check_out': formattedTime,
          'latitude_out': _currentLocation!.latitude,
          'longitude_out': _currentLocation!.longitude,
        });

        if (rowsAffected > 0) {
          setCheckOutMessage(
            'Berhasil melakukan absen keluar pada $formattedTime',
          );
          _isCheckOutEnabled =
              false; // Nonaktifkan tombol check-out setelah check-out
        } else {
          setCheckOutMessage('Gagal melakukan absen keluar.');
        }
      } else {
        setCheckOutMessage('Tidak ada absen masuk hari ini yang belum keluar.');
      }
    } catch (e) {
      setCheckOutMessage('Terjadi kesalahan saat absen keluar: $e');
    } finally {
      setCheckOutLoading(false);
    }
  }

  // Fungsi untuk memeriksa apakah pengguna sudah check-in hari ini
  Future<void> checkIfCheckedIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.loggedInUserId;
    if (userId != null) {
      List<Map<String, dynamic>> todayAbsen = await _db
          .getTodayUncheckedOutAbsen(userId);
      _isCheckOutEnabled = todayAbsen.isNotEmpty;
      notifyListeners();
    } else {
      _isCheckOutEnabled = false;
      notifyListeners();
    }
  }
}
