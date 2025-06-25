import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../model/keranjang_model.dart';

class KeranjangService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<KeranjangItem>> getKeranjang() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/keranjang'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(response.body);
        List<KeranjangItem> keranjangItems = body.map((dynamic item) => KeranjangItem.fromJson(item)).toList();
        return keranjangItems;
      } catch (e) {
        // Mencetak error jika parsing JSON gagal
        debugPrint('Error parsing keranjang JSON: $e');
        debugPrint('Response body: ${response.body}');
        throw Exception('Gagal memproses data keranjang.');
      }
    } else {
      // Mencetak status code dan body untuk respons non-200
      debugPrint('Gagal memuat keranjang. Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      throw Exception('Gagal memuat keranjang. Status: ${response.statusCode}');
    }
  }

  Future<void> updateItemQuantity(int idKeranjang, int quantity) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/keranjang/$idKeranjang'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['message'];
      throw Exception('Gagal memperbarui kuantitas: $error');
    }
  }

  Future<void> deleteItem(int idKeranjang) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/keranjang/$idKeranjang'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Gagal menghapus item');
    }
  }
}
