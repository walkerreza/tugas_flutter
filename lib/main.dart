import 'package:flutter/material.dart';
import 'package:baru/splashscreen.dart';
import 'package:baru/login/form_login.dart';
import 'package:baru/home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const PageLogin(),
      },
    );
  }
}
