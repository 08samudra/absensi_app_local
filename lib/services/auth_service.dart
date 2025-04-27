import 'package:absensi_app/db/data_access_object/user_dao.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';

class AuthProvider with ChangeNotifier {
  final UserDao _userDao = UserDao(); // Gunakan UserDao

  bool _isLoading = false;
  String? _errorMessage = '';
  int? _loggedInUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get loggedInUserId => _loggedInUserId;
  bool get isLoggedIn => _loggedInUserId != null;

  void setInitialLoggedInUserId(int? userId) {
    _loggedInUserId = userId;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String value) {
    _errorMessage = value;
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
      final user = await _userDao.getUserByEmail(email); // Gunakan UserDao
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

  Future<bool> register(
    BuildContext context,
    String name,
    String email,
    String password,
  ) async {
    setLoading(true);
    setErrorMessage('');

    try {
      // Check if the email already exists
      final existingUser = await _userDao.getUserByEmail(
        email,
      ); // Gunakan UserDao
      if (existingUser != null) {
        setErrorMessage('Email ini sudah terdaftar.');
        return false;
      }

      // Hash the password
      final salt = BCrypt.gensalt();
      final String hashedPassword = BCrypt.hashpw(password, salt);

      // Insert the new user into the local database using UserDao
      int userId = await _userDao.register(
        name,
        email,
        hashedPassword,
      ); // Gunakan UserDao

      if (userId > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );
        Navigator.pop(context); // Kembali ke halaman login
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
