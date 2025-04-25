import 'package:absensi_app/db/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class UserDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get _db async => await _databaseHelper.database;

  // Fungsi untuk login (hanya mengambil user berdasarkan email)
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await _db;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Fungsi untuk register
  Future<int> register(String name, String email, String password) async {
    final db = await _db;
    final int userId = await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
    });
    if (userId > 0) {
      await db.insert('profile', {
        'user_id': userId,
        'name': name,
        'email': email,
      });
    }
    return userId;
  }

  // Fungsi untuk mendapatkan profil pengguna
  Future<Map<String, dynamic>?> getProfile(int userId) async {
    final db = await _db;
    final List<Map<String, dynamic>> result = await db.query(
      'profile',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Fungsi untuk memperbarui profil pengguna
  Future<int> updateProfile(Map<String, dynamic> data) async {
    final db = await _db;
    return await db.update(
      'profile',
      {'name': data['name']},
      where: 'user_id = ?',
      whereArgs: [data['user_id']],
    );
  }
}
