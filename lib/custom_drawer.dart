import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:baru/admin/PesananaAdmin.dart';
import 'package:baru/admin/pengiriman_page.dart';
import 'package:baru/admin/Laporan.dart';
import 'package:baru/admin/kategori.dart';
import 'package:baru/admin/rekening.dart';
import 'package:baru/admin/tambah_produk.dart';
import 'package:baru/home_page.dart';
import 'package:baru/login/form_login.dart';
import 'package:baru/chat_page.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, String?>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data ?? {};
          final name = userData['name'];
          final email = userData['email'];

          return _buildAdminDrawer(context, name, email);
        },
      ),
    );
  }

  Widget _buildAdminDrawer(BuildContext context, String? name, String? email) {
    final adminName = name ?? 'Admin';
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(adminName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          accountEmail: Text(email ?? 'admin@example.com'),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A', style: TextStyle(fontSize: 40.0, color: Colors.blue[600])),
          ),
          decoration: BoxDecoration(
            color: Colors.blue[600],
          ),
        ),
        _createDrawerItem(context, icon: Icons.storefront_outlined, text: 'Produk', page: const HomePage()),
                _createDrawerItem(context, icon: Icons.shopping_cart_outlined, text: 'Pesanan', page: const PesananAdminPage()),
                _createDrawerItem(context, icon: Icons.category_outlined, text: 'Kategori', page: const KategoriPage()),
        _createDrawerItem(context, icon: Icons.account_balance_wallet_outlined, text: 'Rekening', page: const RekeningPage()),
                _createDrawerItem(context, icon: Icons.receipt_long_outlined, text: 'Laporan', page: const LaporanPage()),
        _createDrawerItem(context, icon: Icons.local_shipping_outlined, text: 'Pengiriman', page: const PengirimanPage()),
                _createDrawerItem(context, icon: Icons.add_box_outlined, text: 'Tambah Produk', page: const AddProduk()),
        const Divider(),
        _createDrawerItem(context, icon: Icons.chat_bubble_outline, text: 'Live Chat', page: const ChatPage()),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  Widget _createDrawerItem(BuildContext context, {required IconData icon, required String text, required Widget page}) {
    final destinationPageName = page.runtimeType.toString();
    final currentPageName = ModalRoute.of(context)?.settings.name;

    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      selected: currentPageName == destinationPageName,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);
        if (currentPageName != destinationPageName) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => page,
              settings: RouteSettings(name: destinationPageName),
            ),
          );
        }
      },
    );
  }

  Future<Map<String, String?>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name'),
      'email': prefs.getString('email'),
    };
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const PageLogin()),
        (Route<dynamic> route) => false,
      );
    }
  }
}
