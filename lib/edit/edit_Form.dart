import 'package:flutter/material.dart';
import 'package:baru/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';



class EditForm extends StatefulWidget {
  const EditForm({super.key, this.idBarang});
  final String? idBarang;
  @override
  State<EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  String? id;
  TextEditingController namaController = TextEditingController();
  TextEditingController kategoriController = TextEditingController();
  TextEditingController beratController = TextEditingController();
  TextEditingController stokController = TextEditingController();
  TextEditingController hargaProdukController = TextEditingController();
  TextEditingController deskripsiProdukController = TextEditingController();
  String? gambar;
    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var idBaranga = widget.idBarang;
    id = idBaranga;
    ambilDataEdit(id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Barang")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: namaController,
              decoration: const InputDecoration(labelText: "Nama Produk"),
            ),
            TextFormField(
              controller: kategoriController,
              decoration: const InputDecoration(labelText: "Kategori"),
            ),
            TextFormField(
              controller: beratController,
              decoration: const InputDecoration(labelText: "Berat"),
            ),
            TextFormField(
              controller: stokController,
              decoration: const InputDecoration(labelText: "Stok"),
            ),
            TextFormField(
              controller: hargaProdukController,
              decoration: const InputDecoration(labelText: "Harga"),
            ),
            TextFormField(
              controller: deskripsiProdukController,
              decoration: const InputDecoration(labelText: "Deskripsi"),
            ),
        ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pilih Gambar'),
            ),
            if (gambar != null)
              Image.file(File(gambar!), height: 100),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onSubmit(id!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5B5B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Reset form fields
                    setState(() {
                      namaController.clear();
                      kategoriController.clear();
                      beratController.clear();
                      stokController.clear();
                      hargaProdukController.clear();
                      deskripsiProdukController.clear();
                    });
                    // Reload data
                    ambilDataEdit(id!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompresi gambar untuk mengurangi ukuran
      );
      if (pickedFile != null) {
        setState(() {
          gambar = pickedFile.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Future<void> ambilDataEdit(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/editApi/$id'));
      if (response.statusCode == 200) {
        final user = json.decode(response.body)['user'];
        //print(user['berat']);
        setState(() {
          namaController.text = user['nama_produk'];
          //var katergori = user['id_kategori'];
          kategoriController.text = user['id_kategori'].toString();
          beratController.text = user['berat'];
          stokController.text = user['stok'].toString();
          hargaProdukController.text = user['harga_produk'].toString();
          deskripsiProdukController.text = user['deskripsi_produk'];
          gambar = user['foto_produk'];
        });
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> onSubmit(String id) async {
    try {
      // Validasi input
      if (namaController.text.isEmpty) {
        throw Exception('Nama produk tidak boleh kosong');
      }
      
      final response = await http.put(
        Uri.parse('$baseUrl/updateApi/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          "nama_produk": namaController.text,
          "kategori_produk": kategoriController.text,
          "berat_produk": beratController.text,
          "stok_produk": stokController.text,
          "harga_produk": hargaProdukController.text,
          "deskripsi_produk": deskripsiProdukController.text,
          "img1": gambar,
        }),
      );
      
      if (!mounted) return; // Cek apakah context masih aktif
      
      if (response.statusCode == 200) {
        // Tampilkan dialog sukses
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Pesan'),
            content: const Text(
              'Data Berhasil disimpan, Silahkan kembali ke Menu Utama',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                  Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Gagal menyimpan data: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
