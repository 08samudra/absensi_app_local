import 'package:absensi_app/locals/local_database.dart';
import 'package:absensi_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileProvider with ChangeNotifier {
  final LocalDatabase _db = LocalDatabase();
  Map<String, dynamic> _profileData = {};
  bool _isLoading = true;
  String _errorMessage = '';

  Map<String, dynamic> get profileData => _profileData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setProfileData(Map<String, dynamic> value) {
    _profileData = value;
    notifyListeners();
  }

  void setErrorMessage(String value) {
    _errorMessage = value;
    notifyListeners();
  }

  Future<void> fetchProfile(BuildContext context) async {
    setLoading(true);
    setErrorMessage('');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.loggedInUserId;

    if (userId == null) {
      setErrorMessage('Pengguna tidak terautentikasi.');
      setProfileData({});
      setLoading(false);
      return;
    }

    try {
      final profile = await _db.getProfile(userId);
      if (profile != null) {
        setProfileData(profile);
      } else {
        setProfileData({});
      }
    } catch (e) {
      setErrorMessage('Gagal memuat profil: $e');
      setProfileData({});
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateProfile(BuildContext context, String name) async {
    setLoading(true);
    setErrorMessage('');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.loggedInUserId;

    if (userId == null) {
      setErrorMessage('Pengguna tidak terautentikasi.');
      setLoading(false);
      return;
    }

    try {
      await _db.updateProfile({'user_id': userId, 'name': name});
      // Muat ulang profil setelah pembaruan
      fetchProfile(context);
    } catch (e) {
      setErrorMessage('Gagal memperbarui profil: $e');
    } finally {
      setLoading(false);
    }
  }
}
