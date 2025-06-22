import 'package:flutter/material.dart';
import 'package:baru/home_page.dart'; // Akan kita ganti nanti
import 'package:baru/user/user_keranjang_page.dart';
import 'package:baru/user/MyOrder/LihatPesanan.dart';
import 'package:baru/user/MyOrder/Pengiriman.dart';
import 'package:baru/user/user_profil_page.dart';
import 'package:baru/chat_page.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  int _selectedIndex = 0;

  // Daftar halaman untuk setiap tab
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(), // Untuk sementara pakai HomePage
    UserKeranjangPage(),
    Lihatpesanan(),
    Pengiriman(),
    UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            activeIcon: Icon(Icons.local_shipping),
            label: 'Pengiriman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
        },
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }
}
