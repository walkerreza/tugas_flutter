import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// CustomDrawer dengan tampilan yang lebih modern dan menarik
class CustomDrawer extends StatefulWidget {
  final String? name;
  final String? email;
  final bool isAdmin;
  final VoidCallback onLogout;
  final VoidCallback onAddProduct;

  const CustomDrawer({
    super.key, 
    this.name, 
    this.email, 
    required this.isAdmin,
    required this.onLogout,
    required this.onAddProduct,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? type;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      type = sp.getString("type");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 5,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header dengan profil pengguna
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFFF5B5B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Avatar pengguna
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: Color(0xFFFF5B5B),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Informasi pengguna
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name ?? "Guest User",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.email ?? "guest@example.com",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                // Home
                _buildMenuItem(
                  icon: Icons.home_rounded,
                  title: "Home",
                  onTap: () {
                    Navigator.pushNamed(context, "/home");
                  },
                ),
                
                // Login
                _buildMenuItem(
                  icon: Icons.login_rounded,
                  title: "Login",
                  onTap: () {
                    Navigator.pushNamed(context, "/login");
                  },
                ),
                
                // Tambah Barang (hanya untuk admin)
                if (widget.isAdmin)
                  _buildMenuItem(
                    icon: Icons.add_circle_rounded,
                    title: "Tambah Barang",
                    onTap: widget.onAddProduct,
                  ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Divider(height: 1),
                ),
                
                // Logout
                _buildMenuItem(
                  icon: Icons.logout_rounded,
                  title: "Log Out",
                  onTap: widget.onLogout,
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              "App Version 1.0.0",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method untuk membuat item menu dengan tampilan yang konsisten
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFF5B5B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
