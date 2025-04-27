import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapService with ChangeNotifier {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  String _errorMessage = '';

  LatLng? get currentLatLng => _currentLatLng;
  GoogleMapController? get mapController => _mapController;
  String get errorMessage => _errorMessage;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<LatLng?> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentLatLng = LatLng(position.latitude, position.longitude);
      notifyListeners();
      return _currentLatLng;
    } catch (e) {
      setErrorMessage('Gagal mendapatkan lokasi: $e');
      return null;
    }
  }

  void animateCameraToLocation(LatLng latLng) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }
}
