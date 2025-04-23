import 'package:absensi_app/locals/local_database.dart'; // Pastikan path ini benar
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';

class AuthProvider with ChangeNotifier {
  final LocalDatabase _db = LocalDatabase();
  bool _isLoading = false;
  String? _errorMessage = '';
  int? _loggedInUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get loggedInUserId => _loggedInUserId;

  void setInitialLoggedInUserId(int? userId) {
    _loggedInUserId = userId;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _db.getUserByEmail(email);
      if (user != null) {
        final String storedPassword = user['password'];
        if (BCrypt.checkpw(password, storedPassword)) {
          _loggedInUserId = user['user_id'];
          print('Login Berhasil. User ID: $_loggedInUserId');
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', _loggedInUserId!);
          print('User ID disimpan: $_loggedInUserId');
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _errorMessage = 'Email atau password salah.';
          print('Login Gagal: Password salah.');
        }
      } else {
        _errorMessage = 'Email atau password salah.';
        print('Login Gagal: Email tidak ditemukan.');
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat login: $e';
      print('Error saat login: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Hash the password
      final salt = BCrypt.gensalt();
      final String hashedPassword = BCrypt.hashpw(password, salt);

      int userId = await _db.register(name, email, hashedPassword);
      if (userId > 0) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal melakukan registrasi.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat registrasi: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _loggedInUserId = prefs.getInt('userId');
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    _loggedInUserId = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    print('User ID dihapus');
    Navigator.pushReplacementNamed(context, '/login');
    notifyListeners();
  }
}
