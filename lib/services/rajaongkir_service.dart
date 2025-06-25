import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../model/province_model.dart';
import '../model/city_model.dart';

class RajaOngkirService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  Future<List<Province>> getProvinces() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rajaongkir/provinces'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return provinceFromJson(response.body);
    } else {
      throw Exception('Gagal memuat data provinsi');
    }
  }

  Future<List<City>> getCities(String provinceId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rajaongkir/cities/$provinceId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return cityFromJson(response.body);
    } else {
      throw Exception('Gagal memuat data kota');
    }
  }
}
