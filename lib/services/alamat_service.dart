import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/alamat_model.dart';
import '../constants.dart';

class AlamatService {

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Mendapatkan alamat pengguna (Read)
  Future<Alamat?> getAlamat() async {
    final response = await http.get(
      Uri.parse('$baseUrl/alamat'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Alamat.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null; // Alamat belum ada
    } else {
      throw Exception('Gagal memuat alamat: ${response.body}');
    }
  }

  // Membuat alamat baru (Create)
  Future<Alamat> createAlamat(Alamat alamat) async {
    final response = await http.post(
      Uri.parse('$baseUrl/alamat'),
      headers: await _getHeaders(),
      body: jsonEncode(alamat.toJson()),
    );

    if (response.statusCode == 201) {
      return Alamat.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal membuat alamat: ${response.body}');
    }
  }

  // Memperbarui alamat yang ada (Update)
  Future<Alamat> updateAlamat(int id, Alamat alamat) async {
    final response = await http.put(
      Uri.parse('$baseUrl/alamat/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(alamat.toJson()),
    );

    if (response.statusCode == 200) {
      return Alamat.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memperbarui alamat: ${response.body}');
    }
  }
}
