import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baru/login/form_login.dart';
import 'alamat_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? _name;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name');
      _email = prefs.getString('email');
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data session
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const PageLogin()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.blue[600],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (_name != null && _email != null)
            ListTile(
              leading: const Icon(Icons.person, size: 40),
              title: Text(_name!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(_email!),
            ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined, color: Colors.blueAccent),
            title: const Text('Alamat Saya'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlamatPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Konfirmasi Logout'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Batal'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Logout', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                          _logout();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
