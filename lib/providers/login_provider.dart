import 'package:absensi_app/locals/local_database.dart';
import 'package:absensi_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bcrypt/bcrypt.dart'; // Import bcrypt
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class LoginProvider with ChangeNotifier {
  final LocalDatabase _db = LocalDatabase();
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

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
    String username,
    String password,
  ) async {
    setLoading(true);
    setErrorMessage('');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      List<Map<String, dynamic>> users = await _db.getUserByUsername(username);
      if (users.isNotEmpty) {
        Map<String, dynamic> user = users.first;
        final String storedPassword = user['password'];

        if (BCrypt.checkpw(password, storedPassword)) {
          authProvider.setLoggedInUserId(user['id']);
          authProvider.setAuthenticated(true);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', user['id']);
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setErrorMessage('Username atau password salah.');
        }
      } else {
        setErrorMessage('Username atau password salah.');
      }
    } catch (e) {
      setErrorMessage('Terjadi kesalahan: $e');
    } finally {
      setLoading(false);
    }
  }
}
