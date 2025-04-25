import 'package:absensi_app/db/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class AttendanceDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get _db async => await _databaseHelper.database;

  // Fungsi untuk menyimpan data absensi
  Future<int> insertAbsen(Map<String, dynamic> absenData) async {
    final db = await _db;
    return await db.insert('attendance', absenData);
  }

  // Fungsi untuk memperbarui data absensi (saat check-out)
  Future<int> updateAbsen(Map<String, dynamic> absenData) async {
    final db = await _db;
    return await db.update(
      'attendance',
      {
        'check_out': absenData['check_out'],
        'latitude_out': absenData['latitude_out'],
        'longitude_out': absenData['longitude_out'],
      },
      where: 'id = ?',
      whereArgs: [absenData['id']],
    );
  }

  // Fungsi untuk mendapatkan riwayat absensi pengguna berdasarkan rentang tanggal
  Future<List<Map<String, dynamic>>> getAbsenHistory(
    int userId, {
    String? startDate,
    String? endDate,
  }) async {
    final db = await _db;
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (startDate != null && endDate != null) {
      whereClause +=
          ' AND DATE(check_in) >= DATE(?) AND DATE(check_in) <= DATE(?)';
      whereArgs.addAll([startDate, endDate]);
    } else if (startDate != null) {
      whereClause += ' AND DATE(check_in) = DATE(?)';
      whereArgs.add(startDate);
    }

    final List<Map<String, dynamic>> result = await db.query(
      'attendance',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'check_in DESC',
    );
    return result;
  }

  // Fungsi untuk mendapatkan absensi hari ini yang belum check-out
  Future<List<Map<String, dynamic>>> getTodayUncheckedOutAbsen(
    int userId,
  ) async {
    final db = await _db;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final List<Map<String, dynamic>> result = await db.query(
      'attendance',
      where: 'user_id = ? AND DATE(check_in) = DATE(?) AND check_out IS NULL',
      whereArgs: [userId, today],
    );
    return result;
  }

  // Fungsi untuk menghapus data absensi berdasarkan ID
  Future<int> deleteAbsen(int id) async {
    final db = await _db;
    return await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }
}
