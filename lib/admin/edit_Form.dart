import 'package:flutter/material.dart';
import 'package:baru/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:baru/model/kategori.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditForm extends StatefulWidget {
  const EditForm({super.key, this.idBarang});
  final String? idBarang;
  @override
  State<EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController beratController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final TextEditingController hargaProdukController = TextEditingController();
  final TextEditingController deskripsiProdukController =
      TextEditingController();

  String? _valKategori;

  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    namaController.dispose();
    beratController.dispose();
    stokController.dispose();
    hargaProdukController.dispose();
    deskripsiProdukController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // _ambilKategori akan dipanggil oleh FutureBuilder
      await _ambilDataEdit(widget.idBarang!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data awal: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<KategoriModel>> _ambilKategori() async {
    // 1. URL diperbaiki agar sesuai dengan api.php
    final response = await http.get(Uri.parse('$baseUrl/kategoriApi'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<KategoriModel> kategoriList = (data as List)
          .map((item) => KategoriModel.fromJson(item))
          .toList();
      return kategoriList;
    } else {
      throw Exception('Gagal mengambil data kategori');
    }
  }

  Future<void> _ambilDataEdit(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/editApi/$id'));
      if (response.statusCode == 200) {
        final user = json.decode(response.body)['user'];
        if (mounted) {
          setState(() {
            namaController.text = user['nama_produk'];
            _valKategori = user['id_kategori']?.toString();
            beratController.text = user['berat']?.toString() ?? '';
            stokController.text = user['stok']?.toString() ?? '';
            hargaProdukController.text = user['harga_produk']?.toString() ?? '';
            deskripsiProdukController.text = user['deskripsi_produk'] ?? '';
            _imageUrl = user['foto_produk'];
          });
        }
      } else {
        throw Exception('Gagal mengambil data produk');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
    }
  }

  Future<void> _onSubmit() async {
    if (namaController.text.isEmpty || _valKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama produk dan kategori wajib diisi.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Metode dikembalikan ke PUT agar sesuai dengan api.php
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/updateApi/${widget.idBarang}'),
      );

      // Method spoofing untuk Laravel menangani file uploads dengan PUT
      request.fields['_method'] = 'PUT';

      // Tambahkan header untuk memastikan respons JSON dan mengirim cookie
      request.headers['Accept'] = 'application/json';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cookie = prefs.getString('cookie');
      if (cookie != null) {
        request.headers['cookie'] = cookie;
      }

      request.fields['nama_produk'] = namaController.text;
      request.fields['kategori_produk'] = _valKategori!;
      request.fields['berat_produk'] = beratController.text;
      request.fields['stok_produk'] = stokController.text;
      request.fields['harga_produk'] = hargaProdukController.text;
      request.fields['deskripsi_produk'] = deskripsiProdukController.text;

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('img1', _imageFile!.path),
        );
      }

      final response = await request.send();

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        final respStr = await response.stream.bytesToString();
        throw Exception(
          'Gagal menyimpan data: ${response.statusCode} - $respStr',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Produk")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: "Nama Produk",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<KategoriModel>>(
                      future: _ambilKategori(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const LinearProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text("Gagal memuat kategori: ${snapshot.error}");
                        }
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          // Cek jika nilai kategori yang ada masih valid
                          if (_valKategori != null && !snapshot.data!.any((item) => item.idKategori.toString() == _valKategori)) {
                            _valKategori = null;
                          }
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Kategori",
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text("Pilih Kategori"),
                            value: _valKategori,
                            items: snapshot.data!
                                .map((isi) => DropdownMenuItem<String>(
                                      value: isi.idKategori.toString(),
                                      child: Text(isi.namaKategori.toString()),
                                    ))
                                .toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _valKategori = newValue;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Kategori tidak boleh kosong' : null,
                          );
                        }
                        return const Text("Tidak ada data kategori.");
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: beratController,
                      decoration: const InputDecoration(
                        labelText: "Berat (gram)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: stokController,
                      decoration: const InputDecoration(
                        labelText: "Stok",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: hargaProdukController,
                      decoration: const InputDecoration(
                        labelText: "Harga",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: deskripsiProdukController,
                      decoration: const InputDecoration(
                        labelText: "Deskripsi",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Image preview and picker
                    Center(
                      child: Column(
                        children: [
                          if (_imageFile != null)
                            Image.file(
                              _imageFile!,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                          else if (_imageUrl != null)
                            Image.network(
                              '$gambarUrl/$_imageUrl',
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 100),
                            ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text('Ganti Gambar'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5B5B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
