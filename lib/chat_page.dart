import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Chat Support'),
        backgroundColor: Colors.blue[600],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'Fitur Chat Segera Hadir!',
              style: TextStyle(fontSize: 22, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              'Hubungi admin melalui halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
