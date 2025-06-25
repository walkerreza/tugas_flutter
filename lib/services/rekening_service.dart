import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/rekening.dart';
import '../constants.dart';

class RekeningService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('[RekeningService] Menggunakan token untuk API call: $token');
    return token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<RekeningModel>> getRekening() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rekening'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((item) => RekeningModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data rekening: ${response.body}');
    }
  }

  Future<void> addRekening(String nama, String bank, String nomor) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rekening'),
      headers: await _getHeaders(),
      body: json.encode({'nama_pemilik': nama, 'jenis_bank': bank, 'nomor_rekening': nomor}),
    );
    if (response.statusCode != 201) {
      final error = json.decode(response.body)['message'] ?? 'Gagal menambahkan data';
      throw Exception('Error: $error');
    }
  }

  Future<void> updateRekening(int id, String nama, String bank, String nomor) async {
    final response = await http.put(
      Uri.parse('$baseUrl/rekening/$id'),
      headers: await _getHeaders(),
      body: json.encode({'nama_pemilik': nama, 'jenis_bank': bank, 'nomor_rekening': nomor}),
    );
    if (response.statusCode != 200) {
      final error = json.decode(response.body)['message'] ?? 'Gagal memperbarui data';
      throw Exception('Error: $error');
    }
  }

  Future<void> deleteRekening(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/rekening/$id'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      final error = json.decode(response.body)['message'] ?? 'Gagal menghapus data';
      throw Exception('Error: $error');
    }
  }
}
