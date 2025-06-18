import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baru/home_Page.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});
  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Future<void> login(String email, String password) async {
    //final apiUrl = 'http://127.0.0.1:8000/api/login';
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/login'),
      body: {'email': email, 'password': password},
    );
    if (response.statusCode == 200) {
      //mengambil data token
      //final token = json.decode(response.body)['token'];
      //mengabil data user
      final user = json.decode(response.body)['user'];
      //menyimpan data token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('id', user['id']);
      await prefs.setString('name', user['name']);
      await prefs.setString('email', user['email']);
      await prefs.setString('type', user['type']);
      // Konversi id ke String
      String id = user['id'].toString();
      String name = user['name'] ?? '';
      String email = user['email'] ?? '';
      String? type = user['type'];

      // Pastikan widget masih mounted sebelum pindah halaman
      if (!mounted) return;

      // Berpindah halaman
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomePage(id: int.parse(id), name: name, email: email, type: type),
        ),
        (route) => false,
      );
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Login Gagal"),
          content: const Text("Username atau Password Salah"),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Selamat Datang Di Dapur Anita")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome 👏', style: TextStyle(fontSize: 24)),
            Text('Login to get started!'),
            SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            // ignore: deprecated_member_use
            ElevatedButton(
              child: Text('Login'),
              onPressed: () {
                print("ok");
                login(emailController.text, passwordController.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
