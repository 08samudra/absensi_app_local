import 'package:absensi_app/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    _nameController.text =
        homeProvider.profileData['name'] ?? ''; // Isi nama awal
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Consumer<HomeProvider>(
            // Gunakan Consumer untuk HomeProvider
            builder: (context, homeProvider, child) {
              return Column(
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama wajib diisi.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        homeProvider.isLoading
                            ? null
                            : () {
                              if (_formKey.currentState!.validate()) {
                                homeProvider.updateProfile(
                                  context,
                                  _nameController.text,
                                );
                              }
                            },
                    child: const Text('Simpan'),
                  ),
                  if (homeProvider.isLoading) const CircularProgressIndicator(),
                  if (homeProvider.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        homeProvider.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (homeProvider.updateMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        homeProvider.updateMessage,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
