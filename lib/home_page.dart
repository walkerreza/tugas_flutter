import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:baru/constants.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:baru/model/produk.dart';
import 'package:baru/edit/edit_Form.dart';
import 'package:baru/login/form_login.dart';
import 'package:baru/admin/tambah_produk.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.id, this.name, this.email, this.type});
  final int? id;
  final String? name;
  final String? email;
  final String? type;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? id;
  bool isAdmin = false;
  String? name;
  String? email;
  @override
  void initState() {
    super.initState();
    fetchData();
    getTypeValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Belanja Hemat dan Mudah'),
        backgroundColor: const Color.fromARGB(255, 14, 107, 45),
      ),

      ///untuk drawer
      ///
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color.fromARGB(255, 77, 189, 43)),
              accountName: Text(
                name ?? "Belum Login",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                email ?? "Belum Login",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              currentAccountPicture: Image.asset('lib/img/logo1.png'),
            ),
            if (isAdmin == false) ...[
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Login'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: ((context) => PageLogin())),
                  );
                },
              ),
            ] else ...[
              ListTile(
                leading: Icon(Icons.train),
                title: const Text('Tambah Barang'),
                onTap: () {
                  //Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: ((context) => AddProduk())),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: const Text('Log Out'),
                onTap: () {
                  logOut();
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: ((context) => HomePage())));
                },
              ),
            ],
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FutureBuilder<List<ProdukResponModel>>(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var gambar = snapshot.data![index].fotoProduk.toString();
                    return Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                      width: double.infinity,
                      height: 160,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            width: 177,
                            height: 128,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Color(0xffdbd8dd),
                              image: DecorationImage(
                                image: NetworkImage(
                                  '$gambarUrl/produk/$gambar' ??
                                      "'$gambarUrl/produk/download.jpg'",
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            height: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(
                                      2,
                                      0,
                                      0,
                                      10,
                                    ),
                                    child: Text(
                                      snapshot.data![index].namaProduk
                                          .toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Text(
                                    "Harga:${snapshot.data![index].hargaProduk.toString()}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Text(
                                    "Stok :${snapshot.data![index].stok.toString()}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isAdmin == true) ...[
                                  Container(
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            var idBarang = snapshot
                                                .data![index]
                                                .idProduk
                                                .toString();
                                            goEdit(idBarang);
                                          },
                                          icon: const Icon(Icons.edit),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            var idBarang = snapshot
                                                .data![index]
                                                .idProduk
                                                .toString();
                                            delete(idBarang);
                                          },
                                          icon: const Icon(Icons.delete),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  Container(
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.add_box),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.linked_camera),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  Future<List<ProdukResponModel>> fetchData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/getProduk'),
      headers: {
        'Content-Type':
            'application/json; charset=UTF-8; Connection: KeepAlive',
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //final Map<String, dynamic> result =
      jsonDecode(response.body);
      //return ProdukResponModel.fromJson(result);
      List data = jsonDecode(response.body);
      List<ProdukResponModel> produkList = data
          .map((e) => ProdukResponModel.fromJson(e))
          .toList();
      return produkList;
    } else {
      throw Exception('Failed to load Produk');
    }
  }

  getTypeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValue = prefs.getString('type');
    String? nama = prefs.getString('name');
    String? email1 = prefs.getString('email');
    setState(() {
      fetchData();
      if (stringValue == "admin") {
        isAdmin = true;
        name = nama;
        email = email1;
      }
    });
  }

  logOut() async {
    // untuk logout
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  goEdit(idBarang) {
    //untuk edit
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditForm(idBarang: idBarang)),
    );
  }

  Future<void> delete(String idBarang) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deleteApi/$idBarang'),
      );
      if (response.statusCode == 200) {
        if (!mounted) return; // Cek apakah context masih aktif
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Data Berhasil dihapus'),
              content: const Text("Data Berhasil dihapus"),
              actions: <Widget>[
                // ignore: deprecated_member_use
                ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () {
                    setState(() {
                      fetchData();
                    });
                  },
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to delete data');
      }
    } catch (error) {
      print(error);
    }
  }
}
