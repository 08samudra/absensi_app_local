import 'package:absensi_app/locals/local_database.dart';
import 'package:absensi_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeProvider with ChangeNotifier {
  final LocalDatabase _db = LocalDatabase();
  Map<String, dynamic> _profileData = {};
  bool _isLoading = true;
  String _errorMessage = '';
  String _updateMessage = ''; // Tambahkan pesan update

  Map<String, dynamic> get profileData => _profileData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get updateMessage => _updateMessage; // Getter untuk pesan update

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

  void setUpdateMessage(String value) {
    // Setter untuk pesan update
    _updateMessage = value;
    notifyListeners();
  }

  Future<void> fetchProfile(BuildContext context) async {
    setLoading(true);
    setErrorMessage('');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.loggedInUserId;

    if (userId == null) {
      setLoading(false);
      setErrorMessage('Pengguna tidak terautentikasi.');
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
      // Tidak perlu menampilkan SnackBar di sini
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateProfile(BuildContext context, String newName) async {
    setLoading(true);
    setUpdateMessage('');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.loggedInUserId;

    if (userId == null) {
      setErrorMessage('Pengguna tidak terautentikasi.');
      setLoading(false);
      return;
    }

    try {
      int rowsAffected = await _db.updateProfile({
        'user_id': userId,
        'name': newName,
      });
      if (rowsAffected > 0) {
        setUpdateMessage('Profil berhasil diperbarui!');
        fetchProfile(context); // Muat ulang profil setelah pembaruan
        Navigator.pop(
          context,
          true,
        ); // Kembalikan nilai true untuk menandakan perubahan
      } else {
        setErrorMessage('Gagal memperbarui profil.');
      }
    } catch (e) {
      setErrorMessage('Terjadi kesalahan saat memperbarui profil: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> removeToken(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout(context); // Tambahkan context sebagai argumen
    // Tidak perlu navigasi di sini, biarkan widget yang menanganinya jika perlu
  }
}
