import 'package:absensi_app/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final profileData = homeProvider.profileData;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF728796)),
            accountName: Text(
              profileData.isNotEmpty
                  ? (profileData['name'] ?? 'Nama Pengguna')
                  : 'Nama Pengguna',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              profileData.isNotEmpty
                  ? (profileData['email'] ?? 'Email tidak tersedia')
                  : '',
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  text: 'Profil',
                  routeName: '/profile',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.history,
                  text: 'Riwayat Absen',
                  routeName: '/history_absen',
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Logout'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required String routeName,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[700]),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context); // close drawer
        Navigator.pushNamed(context, routeName);
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda yakin ingin logout?'),
            actions: [
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text('Logout'),
                onPressed: () async {
                  await Provider.of<HomeProvider>(
                    context,
                    listen: false,
                  ).removeToken(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
    );
  }
}
