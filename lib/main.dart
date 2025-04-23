import 'package:absensi_app/locals/local_database.dart';
import 'package:absensi_app/pages_app/absent_page.dart';
import 'package:absensi_app/pages_app/edit_profile_page.dart';
import 'package:absensi_app/pages_app/home_page.dart';
import 'package:absensi_app/pages_app/login_page.dart';
import 'package:absensi_app/pages_app/profil_page.dart';
import 'package:absensi_app/pages_app/register_page.dart';
import 'package:absensi_app/pages_app/riwayat_absen_page.dart';
import 'package:absensi_app/providers/absen_provider.dart';
import 'package:absensi_app/providers/auth_provider.dart';
import 'package:absensi_app/providers/home_providers.dart';
import 'package:absensi_app/providers/register_provider.dart';
import 'package:absensi_app/providers/riwayat_absen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final LocalDatabase localDatabase = LocalDatabase();
  await localDatabase.database; // Initialize the database early

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => RegisterProvider()),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => AbsenProvider()),
        ChangeNotifierProvider(create: (context) => RiwayatAbsenProvider()),
        // Anda bisa menambahkan provider lain di sini jika ada
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/edit_profile': (context) => EditProfilePage(),
        '/absent': (context) => AbsentPage(),
        '/history_absen': (context) => RiwayatAbsenPage(),
        // Tambahkan rute lain sesuai kebutuhan aplikasi Anda
      },
    );
  }
}
