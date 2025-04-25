import 'package:absensi_app/db/db_helper.dart';
// import 'package:absensi_app/db/local_db.dart';
import 'package:absensi_app/pages/edit_profile_page.dart';
import 'package:absensi_app/pages/home_page.dart';
import 'package:absensi_app/pages/login_page.dart';
import 'package:absensi_app/pages/profil_page.dart';
import 'package:absensi_app/pages/register_page.dart';
import 'package:absensi_app/pages/riwayat_absen_page.dart';
import 'package:absensi_app/pages/splash_page.dart';
import 'package:absensi_app/providers/absen_provider.dart';
import 'package:absensi_app/providers/auth_provider.dart';
import 'package:absensi_app/providers/home_provider.dart';
import 'package:absensi_app/providers/riwayat_absen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import untuk inisialisasi locale data

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final DatabaseHelper localDatabase = DatabaseHelper();
  await localDatabase.database;

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final int? initialUserId = prefs.getInt('userId');

  // Inisialisasi data locale untuk Bahasa Indonesia
  await initializeDateFormatting('id_ID', null).then(
    (_) => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) {
              final authProvider = AuthProvider();
              authProvider.setInitialLoggedInUserId(initialUserId);
              return authProvider;
            },
          ),
          ChangeNotifierProvider(create: (context) => HomeProvider()),
          ChangeNotifierProvider(create: (context) => AbsenProvider()),
          ChangeNotifierProvider(create: (context) => RiwayatAbsenProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return MaterialApp(
      title: 'Absensi App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: authProvider.isLoggedIn ? '/home' : '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/edit_profile': (context) => EditProfilePage(),
        '/history_absen': (context) => RiwayatAbsenPage(),
      },
    );
  }
}
