import 'package:absensi_app/db/data_access_object/user_dao.dart';
import 'package:absensi_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileProvider with ChangeNotifier {
  final UserDao _userDao = UserDao(); // Gunakan UserDao
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
      final profile = await _userDao.getProfile(userId); // Gunakan UserDao
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
      await _userDao.updateProfile({
        'user_id': userId,
        'name': name,
      }); // Gunakan UserDao
      // Muat ulang profil setelah pembaruan
      fetchProfile(context);
    } catch (e) {
      setErrorMessage('Gagal memperbarui profil: $e');
    } finally {
      setLoading(false);
    }
  }
}
