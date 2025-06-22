import 'package:flutter/material.dart';
import 'package:baru/custom_drawer.dart';

class ProfilPage extends StatelessWidget {
  final String? name;
  final String? email;
  final VoidCallback onLogout;

  const ProfilPage({
    super.key,
    required this.name,
    required this.email,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Admin'),
        backgroundColor: Colors.blue[600],
      ),
            drawer: const CustomDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),
          Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0x33FF5B5B),
                child: Icon(Icons.person, size: 50, color: Color(0xFFFF5B5B)),
              ),
              const SizedBox(height: 20),
              Text(
                name ?? 'Guest User',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                email ?? 'guest@example.com',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
            title: const Text('Ubah Profil'),
            onTap: () {
              // TODO: Navigate to Edit Profile Page
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined, color: Colors.green),
            title: const Text('Alamat Saya'),
            onTap: () {
              // TODO: Navigate to Address Page
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
