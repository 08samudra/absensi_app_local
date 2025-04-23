import 'package:absensi_app/locals/local_database.dart';
import 'package:absensi_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bcrypt/bcrypt.dart'; // Import bcrypt

class RegisterProvider with ChangeNotifier {
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

  Future<void> register(
    BuildContext context,
    String name,
    String email,
    String password,
  ) async {
    setLoading(true);
    setErrorMessage('');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Check if the email already exists
      final existingUser = await _db.getUserByEmail(email);
      if (existingUser != null) {
        setErrorMessage('Email ini sudah terdaftar.');
        return;
      }

      // Hash the password
      final salt = BCrypt.gensalt();
      final String hashedPassword = BCrypt.hashpw(password, salt);

      // Insert the new user into the local database using the register method
      int userId = await _db.register(name, email, hashedPassword);

      if (userId > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );
        Navigator.pop(context); // Kembali ke halaman login
      } else {
        setErrorMessage('Gagal melakukan registrasi.');
      }
    } catch (e) {
      setErrorMessage('Terjadi kesalahan saat registrasi: $e');
    } finally {
      setLoading(false);
    }
  }
}
