import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final bool isAdmin;
  final Function(int) onTap;

  const BottomNavigationWidget({
    Key? key,
    required this.currentIndex,
    required this.isAdmin,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: const Color(0xFFFF5B5B),
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: isAdmin
          ? _adminNavigationItems
          : _userNavigationItems,
    );
  }

  // Item navigasi untuk pengguna biasa
  List<BottomNavigationBarItem> get _userNavigationItems => const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];

  // Item navigasi untuk admin
  List<BottomNavigationBarItem> get _adminNavigationItems => const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          label: 'Pembayaran',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Pembelian',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping),
          label: 'Resi',
        ),
      ];
}