import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baru/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:baru/model/kategori.dart';
import 'package:baru/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AddProduk extends StatefulWidget {
const AddProduk({super.key});
@override
State<AddProduk> createState() => _AddProdukState();
}
class _AddProdukState extends State<AddProduk> {
  String? _valKategori;

  // Gunakan lowerCamelCase untuk nama variabel dan controller
  final TextEditingController namaProdukController = TextEditingController();
  final TextEditingController beratProdukController = TextEditingController();
  final TextEditingController stokProdukController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController deskripsiProdukController = TextEditingController();
  File? image;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Lakukan dispose pada controller untuk membebaskan resource
    namaProdukController.dispose();
    beratProdukController.dispose();
    stokProdukController.dispose();
    hargaController.dispose();
    deskripsiProdukController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Data Produk"),
        leading: BackButton(
          onPressed: () {
            // Gunakan pushReplacement agar tidak menumpuk halaman
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: namaProdukController,
              decoration: const InputDecoration(labelText: "Nama Produk"),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<KategoriModel>>(
              future: ambilKategori(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                if (snapshot.hasData) {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Kategori"),
                    hint: const Text("Pilih Kategori"),
                    value: _valKategori,
                    items: snapshot.data
                        ?.map((isi) => DropdownMenuItem<String>(
                              value: isi.idKategori.toString(),
                              child: Text(isi.namaKategori.toString()),
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      setState(() => _valKategori = newValue);
                    },
                  );
                }
                return const Text("Tidak ada data kategori");
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: beratProdukController,
              decoration: const InputDecoration(labelText: "Berat Produk (gram)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: stokProdukController,
              decoration: const InputDecoration(labelText: "Stok Produk"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: "Harga Produk (Rp)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: deskripsiProdukController,
              decoration: const InputDecoration(labelText: "Deskripsi Produk"),
              maxLines: 3,
            ),
            const SizedBox(height: 20.0),
            if (image != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Image.file(
                  image!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pilih Gambar'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.save),
              label: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5B5B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<KategoriModel>> ambilKategori() async {
    final response = await http.get(Uri.parse('$baseUrl/kategoriApi'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<KategoriModel> kategoriList = (data as List)
          .map((item) => KategoriModel.fromJson(item))
          .toList();
      return kategoriList;
    } else {
      throw Exception('Gagal memuat data kategori');
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompresi gambar untuk mengurangi ukuran
      );
      if (pickedImage == null) return;
      final imageTemp = File(pickedImage.path);
      setState(() {
        image = imageTemp;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showValidationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Data Belum Lengkap"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      // Validasi input sebelum mengirim
      if (namaProdukController.text.isEmpty) {
        _showValidationDialog("Nama produk tidak boleh kosong.");
        return;
      }
      if (_valKategori == null) {
        _showValidationDialog("Silakan pilih kategori produk.");
        return;
      }
      if (image == null) {
        _showValidationDialog("Silakan pilih gambar produk.");
        return;
      }
      if (beratProdukController.text.isEmpty) {
        _showValidationDialog("Berat produk tidak boleh kosong.");
        return;
      }
      if (stokProdukController.text.isEmpty) {
        _showValidationDialog("Stok produk tidak boleh kosong.");
        return;
      }
      if (hargaController.text.isEmpty) {
        _showValidationDialog("Harga produk tidak boleh kosong.");
        return;
      }

      // Tampilkan indikator loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Menyimpan data..."),
                ],
              ),
            ),
          );
        },
      );

      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/storeApi'));

      // Tambahkan header untuk memastikan respons JSON dan mengirim cookie
      request.headers['Accept'] = 'application/json';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cookie = prefs.getString('cookie');
      if (cookie != null) {
        request.headers['cookie'] = cookie;
      }

      request.fields['nama_produk'] = namaProdukController.text;
      request.fields['kategori_produk'] = _valKategori!;
      request.fields['berat_produk'] = beratProdukController.text;
      request.fields['stok_produk'] = stokProdukController.text;
      request.fields['harga_produk'] = hargaController.text;
      request.fields['deskripsi_produk'] = deskripsiProdukController.text;

      request.files.add(await http.MultipartFile.fromPath('img1', image!.path));

      final response = await request.send();

      if (!mounted) return;

      // Tutup dialog loading
      Navigator.of(context).pop();

      final responseStatusCode = response.statusCode;
      final namaProduk = namaProdukController.text;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(responseStatusCode == 200 ? 'Berhasil' : 'Gagal'),
            content: Text(
              responseStatusCode == 200
                  ? "Produk '$namaProduk' berhasil disimpan."
                  : "Gagal menyimpan produk. Status: $responseStatusCode",
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5B5B),
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                  if (responseStatusCode == 200) {
                    // Kembali ke halaman utama dengan refresh data
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Tutup dialog loading jika masih ada
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
