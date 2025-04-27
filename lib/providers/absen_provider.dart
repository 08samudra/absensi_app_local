import 'package:absensi_app/db/data_access_object/attendace_dao.dart';
// import 'package:absensi_app/providers/auth_provider.dart';
// import 'package:absensi_app/providers/map_provider.dart'; // Import MapProvider
import 'package:absensi_app/services/auth_service.dart';
import 'package:absensi_app/services/map_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import untuk LatLng
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class AbsenProvider with ChangeNotifier {
  final AttendanceDao _attendanceDao = AttendanceDao();
  String _status = 'Masuk';
  String _alasanIzin = '';
  bool _isLoading = false;
  String _message = '';
  bool _isCheckOutLoading = false;
  String _checkOutMessage = '';
  bool _isCheckOutEnabled = false;

  String get status => _status;
  String get alasanIzin => _alasanIzin;
  bool get isLoading => _isLoading;
  String get message => _message;
  bool get isCheckOutLoading => _isCheckOutLoading;
  String get checkOutMessage => _checkOutMessage;
  bool get isCheckOutEnabled => _isCheckOutEnabled;

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

  Future<String?> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}';
      }
      return null;
    } catch (e) {
      setMessage('Gagal mendapatkan nama lokasi: $e');
      return null;
    }
  }

  Future<void> checkIn(BuildContext context) async {
    setLoading(true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final mapProvider = Provider.of<MapService>(context, listen: false);
    final userId = authProvider.loggedInUserId;
    final now = DateTime.now();
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    final currentLocation = mapProvider.currentLatLng;

    if (userId == null) {
      setMessage('Pengguna tidak terautentikasi.');
      setLoading(false);
      return;
    }

    if (currentLocation == null) {
      setMessage('Lokasi belum tersedia. Harap coba lagi.');
      setLoading(false);
      return;
    }

    String? locationName = await _getAddressFromLatLng(currentLocation);

    try {
      List<Map<String, dynamic>> todayUncheckedIn = await _attendanceDao
          .getTodayUncheckedOutAbsen(userId);

      if (todayUncheckedIn.isNotEmpty) {
        setMessage(
          'Anda sudah melakukan absen masuk hari ini dan belum melakukan absen pulang.',
        );
      } else {
        int id = await _attendanceDao.insertAbsen({
          'user_id': userId,
          'check_in': formattedTime,
          'check_out': null,
          'latitude_in': currentLocation.latitude,
          'longitude_in': currentLocation.longitude,
          'latitude_out': null,
          'longitude_out': null,
          'status': _status,
          'alasan_izin': _status == 'izin' ? _alasanIzin : null,
          'location_in_name': locationName,
        });

        if (id > 0) {
          setMessage(
            'Berhasil melakukan absen masuk pada $formattedTime di $locationName',
          );
          _isCheckOutEnabled = true;
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
    final mapProvider = Provider.of<MapService>(context, listen: false);
    final userId = authProvider.loggedInUserId;
    final now = DateTime.now();
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    final currentLocation = mapProvider.currentLatLng;

    if (userId == null) {
      setCheckOutMessage('Pengguna tidak terautentikasi.');
      setCheckOutLoading(false);
      return;
    }

    if (currentLocation == null) {
      setCheckOutMessage('Lokasi belum tersedia. Harap coba lagi.');
      setCheckOutLoading(false);
      return;
    }

    try {
      List<Map<String, dynamic>> todayAbsen = await _attendanceDao
          .getTodayUncheckedOutAbsen(userId);
      if (todayAbsen.isNotEmpty) {
        int absenId = todayAbsen.first['id'];
        int rowsAffected = await _attendanceDao.updateAbsen({
          'id': absenId,
          'check_out': formattedTime,
          'latitude_out': currentLocation.latitude,
          'longitude_out': currentLocation.longitude,
        });

        if (rowsAffected > 0) {
          setCheckOutMessage(
            'Berhasil melakukan absen keluar pada $formattedTime',
          );
          _isCheckOutEnabled = false;
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

  Future<void> checkIfCheckedIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.loggedInUserId;
    if (userId != null) {
      List<Map<String, dynamic>> todayAbsen = await _attendanceDao
          .getTodayUncheckedOutAbsen(userId);
      _isCheckOutEnabled = todayAbsen.isNotEmpty;
      notifyListeners();
    } else {
      _isCheckOutEnabled = false;
      notifyListeners();
    }
  }
}
