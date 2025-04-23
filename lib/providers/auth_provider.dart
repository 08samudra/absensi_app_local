import 'package:absensi_app/locals/local_database.dart'; // Pastikan path ini benar
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';

class AuthProvider with ChangeNotifier {
  final LocalDatabase _db = LocalDatabase();
  bool _isAuthenticated = false;
  int? _loggedInUserId;
  String? _errorMessage = '';

  bool get isAuthenticated => _isAuthenticated;
  int? get loggedInUserId => _loggedInUserId;
  String? get errorMessage => _errorMessage;

  // Metode baru untuk mengatur ID pengguna yang login
  void setLoggedInUserId(int userId) {
    _loggedInUserId = userId;
    notifyListeners();
  }

  // Metode baru untuk mengatur status autentikasi
  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  Future<bool> register(
    String username,
    String password,
    String name,
    String email,
  ) async {
    // Enkripsi password sebelum menyimpan
    final salt = BCrypt.gensalt();
    final String encryptedPassword = BCrypt.hashpw(password, salt);

    int userId = await _db.register(
      name,
      email,
      encryptedPassword,
    ); // Gunakan metode register dari LocalDatabase
    if (userId > 0) {
      return true;
    }
    _errorMessage = 'Gagal mendaftar.';
    notifyListeners();
    return false;
  }

  Future<bool> login(String username, String password) async {
    // Kita perlu mengambil user berdasarkan username, lalu verifikasi password
    // Asumsi di LocalDatabase ada fungsi getUserByUsername
    List<Map<String, dynamic>> users = await _db.getUserByUsername(username);
    if (users.isNotEmpty) {
      Map<String, dynamic> user = users.first;
      final String storedPassword = user['password'];

      // Verifikasi password
      if (BCrypt.checkpw(password, storedPassword)) {
        _isAuthenticated = true;
        _loggedInUserId =
            user['user_id']; // Gunakan user_id sesuai dengan skema tabel
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', _loggedInUserId!);
        notifyListeners();
        return true;
      }
    }
    _errorMessage = 'Username atau password salah.';
    notifyListeners();
    return false;
  }

  Future<void> checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _loggedInUserId = prefs.getInt('userId');
    _isAuthenticated = _loggedInUserId != null;
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _loggedInUserId = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }
}
