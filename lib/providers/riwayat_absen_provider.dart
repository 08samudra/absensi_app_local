import 'package:absensi_app/locals/local_database.dart';
import 'package:absensi_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RiwayatAbsenProvider with ChangeNotifier {
  final LocalDatabase _db = LocalDatabase();
  List<Map<String, dynamic>> _historyAbsens = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _totalAbsen = 0;
  int _totalIzin = 0;

  List<Map<String, dynamic>> get historyAbsens => _historyAbsens;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get totalAbsen => _totalAbsen;
  int get totalIzin => _totalIzin;

  void setLoading(bool value) {
    _isLoading = value;
    _errorMessage = '';
    notifyListeners();
  }

  void setHistoryAbsens(List<Map<String, dynamic>> value) {
    _historyAbsens = value;
    notifyListeners();
  }

  void setErrorMessage(String value) {
    _errorMessage = value;
    notifyListeners();
  }

  Future<void> getHistoryAbsens({
    BuildContext? context,
    String? startDate,
    String? endDate,
  }) async {
    setLoading(true);
    setErrorMessage(''); // Reset error message saat memulai loading
    final authProvider = Provider.of<AuthProvider>(context!, listen: false);
    final userId = authProvider.loggedInUserId;

    if (userId == null) {
      setErrorMessage('Pengguna tidak terautentikasi.');
      setLoading(false);
      return;
    }

    try {
      List<Map<String, dynamic>> absens = await _db.getAbsenHistory(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
      setHistoryAbsens(absens);
      _totalAbsen =
          absens
              .where(
                (absen) =>
                    absen['status'] == 'masuk' && absen['check_out'] != null,
              )
              .length;
      _totalIzin = absens.where((absen) => absen['status'] == 'izin').length;
    } catch (e) {
      setErrorMessage('Gagal mengambil riwayat absen: $e');
    } finally {
      setLoading(false);
    }
  }
}
