// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:intl/intl.dart';

// class LocalDatabase {
//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<String> get fullPath async {
//     const name = 'absensi_app.db';
//     final path = await getDatabasesPath();
//     return join(path, name);
//   }

//   Future<Database> _initDatabase() async {
//     final path = await fullPath;
//     return await openDatabase(
//       path,
//       version: 2,
//       onUpgrade: _upgradeDatabase,
//       onCreate: _createDatabase,
//     );
//   }

//   Future<void> _upgradeDatabase(
//     Database db,
//     int oldVersion,
//     int newVersion,
//   ) async {
//     if (oldVersion < 2) {
//       await db.execute(
//         'ALTER TABLE attendance ADD COLUMN location_in_name TEXT',
//       );
//     }
//     // Tambahkan upgrade lain jika ada versi database selanjutnya
//   }

//   Future<void> _createDatabase(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE users (
//         user_id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL,
//         email TEXT UNIQUE NOT NULL,
//         password TEXT NOT NULL
//       )
//     ''');
//     await db.execute('''
//       CREATE TABLE profile (
//         user_id INTEGER PRIMARY KEY,
//         name TEXT,
//         email TEXT,
//         FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
//       )
//     ''');
//     await db.execute('''
//       CREATE TABLE attendance (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         user_id INTEGER NOT NULL,
//         check_in TEXT NOT NULL,
//         check_out TEXT,
//         latitude_in REAL,
//         longitude_in REAL,
//         latitude_out REAL,
//         longitude_out REAL,
//         status TEXT NOT NULL,
//         alasan_izin TEXT,
//         created_at TEXT DEFAULT CURRENT_TIMESTAMP,
//         location_in_name TEXT, -- Tambahkan kolom ini
//         FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
//       )
//     ''');
//   }

//   // Fungsi untuk login (hanya mengambil user berdasarkan email)
//   Future<Map<String, dynamic>?> getUserByEmail(String email) async {
//     final db = await database;
//     final List<Map<String, dynamic>> result = await db.query(
//       'users',
//       where: 'email = ?',
//       whereArgs: [email],
//     );
//     if (result.isNotEmpty) {
//       return result.first;
//     }
//     return null;
//   }

//   // Fungsi untuk register
//   Future<int> register(String name, String email, String password) async {
//     final db = await database;
//     final int userId = await db.insert('users', {
//       'name': name,
//       'email': email,
//       'password': password,
//     });
//     if (userId > 0) {
//       await db.insert('profile', {
//         'user_id': userId,
//         'name': name,
//         'email': email,
//       });
//     }
//     return userId;
//   }

//   // Fungsi untuk mendapatkan profil pengguna
//   Future<Map<String, dynamic>?> getProfile(int userId) async {
//     final db = await database;
//     final List<Map<String, dynamic>> result = await db.query(
//       'profile',
//       where: 'user_id = ?',
//       whereArgs: [userId],
//     );
//     if (result.isNotEmpty) {
//       return result.first;
//     }
//     return null;
//   }

//   // Fungsi untuk memperbarui profil pengguna
//   Future<int> updateProfile(Map<String, dynamic> data) async {
//     final db = await database;
//     return await db.update(
//       'profile',
//       {'name': data['name']},
//       where: 'user_id = ?',
//       whereArgs: [data['user_id']],
//     );
//   }

//   // Fungsi untuk menyimpan data absensi
//   Future<int> insertAbsen(Map<String, dynamic> absenData) async {
//     final db = await database;
//     return await db.insert('attendance', absenData);
//   }

//   // Fungsi untuk memperbarui data absensi (saat check-out)
//   Future<int> updateAbsen(Map<String, dynamic> absenData) async {
//     final db = await database;
//     return await db.update(
//       'attendance',
//       {
//         'check_out': absenData['check_out'],
//         'latitude_out': absenData['latitude_out'],
//         'longitude_out': absenData['longitude_out'],
//       },
//       where: 'id = ?',
//       whereArgs: [absenData['id']],
//     );
//   }

//   // Fungsi untuk mendapatkan riwayat absensi pengguna berdasarkan rentang tanggal
//   Future<List<Map<String, dynamic>>> getAbsenHistory(
//     int userId, {
//     String? startDate,
//     String? endDate,
//   }) async {
//     final db = await database;
//     String whereClause = 'user_id = ?';
//     List<dynamic> whereArgs = [userId];

//     if (startDate != null && endDate != null) {
//       whereClause +=
//           ' AND DATE(check_in) >= DATE(?) AND DATE(check_in) <= DATE(?)';
//       whereArgs.addAll([startDate, endDate]);
//     } else if (startDate != null) {
//       whereClause += ' AND DATE(check_in) = DATE(?)';
//       whereArgs.add(startDate);
//     }

//     final List<Map<String, dynamic>> result = await db.query(
//       'attendance',
//       where: whereClause,
//       whereArgs: whereArgs,
//       orderBy: 'check_in DESC',
//     );
//     return result;
//   }

//   // Fungsi untuk mendapatkan absensi hari ini yang belum check-out
//   Future<List<Map<String, dynamic>>> getTodayUncheckedOutAbsen(
//     int userId,
//   ) async {
//     final db = await database;
//     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     final List<Map<String, dynamic>> result = await db.query(
//       'attendance',
//       where: 'user_id = ? AND DATE(check_in) = DATE(?) AND check_out IS NULL',
//       whereArgs: [userId, today],
//     );
//     return result;
//   }

//   // Fungsi untuk menghapus data absensi berdasarkan ID
//   Future<int> deleteAbsen(int id) async {
//     final db = await database;
//     return await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
//   }
// }
