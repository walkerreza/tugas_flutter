import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:baru/constants.dart';
import 'package:baru/login/form_login.dart';

class PageRegister extends StatefulWidget {
  const PageRegister({super.key});

  @override
  State<PageRegister> createState() => _PageRegisterState();
}

class _PageRegisterState extends State<PageRegister> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordConfirmationController.text.isEmpty) {
      _showErrorDialog('Semua kolom harus diisi.');
      return;
    }

    if (passwordController.text != passwordConfirmationController.text) {
      _showErrorDialog('Password dan konfirmasi password tidak cocok.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/registerApi'),
        headers: {'Accept': 'application/json'},
        body: {
          'name': nameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'password_confirmation': passwordConfirmationController.text,
        },
      );

      if (!mounted) return;

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        _showSuccessDialog(responseData['message']);
      } else {
        // Menangani error validasi dari Laravel
        String errorMessage = responseData['message'] ?? 'Terjadi kesalahan.';
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.map((e) => e[0]).join('\n');
        }
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog('Gagal terhubung ke server: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrasi Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrasi Berhasil'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              Navigator.of(context).pushReplacement( // Kembali ke halaman login
                MaterialPageRoute(builder: (context) => const PageLogin()),
              );
            },
            child: const Text('Login Sekarang'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[800]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(controller: nameController, label: 'Nama Lengkap', icon: Icons.person),
                const SizedBox(height: 20),
                _buildTextField(controller: emailController, label: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildPasswordField(controller: passwordController, label: 'Password'),
                const SizedBox(height: 20),
                _buildPasswordField(controller: passwordConfirmationController, label: 'Konfirmasi Password'),
                const SizedBox(height: 40),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('DAFTAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Sudah punya akun? Masuk',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPasswordField({required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
