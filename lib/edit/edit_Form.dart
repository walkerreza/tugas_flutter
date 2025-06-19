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
                  child: const Text('Edit'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onSubmit(id!);
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        gambar = pickedFile.path;
      });
    }
  }

  Future<void> ambilDataEdit(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/editApi/$id'));
    if (response.statusCode == 200) {
      final user = json.decode(response.body)['user'];
      //print(user['berat']);
      namaController.text = user['nama_produk'];
      //var katergori = user['id_kategori'];
      kategoriController.text = user['id_kategori'].toString();
      beratController.text = user['berat'];
      stokController.text = user['stok'].toString();
      hargaProdukController.text = user['harga_produk'].toString();
      deskripsiProdukController.text = user['deskripsi_produk'];
      gambar = user['foto_produk'];
    }
  }

  Future<void> onSubmit(String id) async {
    //print("jalan edit");
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
    print(response.statusCode);
    //var status = response.body.contains('error');
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final result = json.decode(response.body);
      print(response);
      if (!mounted) return; // Cek apakah context masih aktif
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Pesan'),
          content: Text(
            'Data Berhasil disimpan, Silahkan kembali ke Menu Utama',
          ),
        ),
      );
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.throw Exception(response.body);
    }
  }
}
