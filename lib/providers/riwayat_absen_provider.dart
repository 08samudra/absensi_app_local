import 'package:absensi_app/db/data_access_object/attendace_dao.dart';
import 'package:absensi_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RiwayatAbsenProvider with ChangeNotifier {
  final AttendanceDao _attendanceDao = AttendanceDao(); // Gunakan AttendanceDao
  List<Map<String, dynamic>> _historyAbsens = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _totalAbsen = 0;
  int _totalIzin = 0;
  DateTime? _selectedDate; // Untuk menyimpan tanggal yang dipilih

  List<Map<String, dynamic>> get historyAbsens => _historyAbsens;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get totalAbsen => _totalAbsen;
  int get totalIzin => _totalIzin;
  DateTime? get selectedDate => _selectedDate;

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

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> getHistoryAbsens({
    BuildContext? context,
    String? startDate,
    String? endDate,
  }) async {
    setLoading(true);
    setErrorMessage('');
    final authProvider = Provider.of<AuthProvider>(context!, listen: false);
    final userId = authProvider.loggedInUserId;

    if (userId == null) {
      setErrorMessage('Pengguna tidak terautentikasi.');
      setLoading(false);
      return;
    }

    try {
      List<Map<String, dynamic>> absens = await _attendanceDao.getAbsenHistory(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
      setHistoryAbsens(absens);
      _totalAbsen =
          absens
              .where(
                (absen) =>
                    absen['status'] == 'Masuk' && absen['check_out'] != null,
              )
              .length;
      _totalIzin = absens.where((absen) => absen['status'] == 'izin').length;
    } catch (e) {
      setErrorMessage('Gagal mengambil riwayat absen: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> deleteHistoryAbsen(BuildContext context, int absenId) async {
    setLoading(true);
    setErrorMessage('');
    try {
      final int deletedRows = await _attendanceDao.deleteAbsen(absenId);

      if (deletedRows > 0) {
        // Refresh riwayat setelah hapus
        await getHistoryAbsens(
          context: context,
          startDate:
              _selectedDate != null
                  ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                  : null,
          endDate:
              _selectedDate != null
                  ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                  : null,
        );
        return true; // << KEMBALIKAN TRUE kalau berhasil
      } else {
        setErrorMessage('Gagal menghapus riwayat absen.');
        return false; // << KEMBALIKAN FALSE kalau gagal
      }
    } catch (e) {
      setErrorMessage('Terjadi kesalahan saat menghapus riwayat absen: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
}
