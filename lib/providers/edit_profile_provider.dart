import 'package:absensi_app/locals/local_database.dart';
import 'package:absensi_app/pages_app/profil_page.dart';
import 'package:absensi_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileProvider with ChangeNotifier {
  final LocalDatabase _db = LocalDatabase();
  bool _isLoading = false;
  String _message = '';

  bool get isLoading => _isLoading;
  String get message => _message;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setMessage(String value) {
    _message = value;
    notifyListeners();
  }

  Future<void> editProfile(BuildContext context, String name) async {
    setLoading(true);
    setMessage('');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.loggedInUserId;

    if (userId == null) {
      setMessage('Pengguna tidak terautentikasi.');
      setLoading(false);
      return;
    }

    try {
      int updatedRows = await _db.updateProfile({
        'user_id': userId,
        'name': name,
      });
      if (updatedRows > 0) {
        setMessage('Profil berhasil diperbarui.');
        setLoading(false);
        // Navigasi kembali ke ProfilePage setelah berhasil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      } else {
        setMessage('Gagal memperbarui profil.');
        setLoading(false);
      }
    } catch (e) {
      setMessage('Terjadi kesalahan saat memperbarui profil: $e');
      setLoading(false);
    }
  }
}
