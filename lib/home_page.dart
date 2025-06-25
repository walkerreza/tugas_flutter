import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:baru/constants.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:baru/model/produk.dart';
import 'package:baru/admin/edit_Form.dart';
// import 'package:baru/login/form_login.dart';
import 'package:baru/custom_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:baru/user/MyOrder/LihatPesanan.dart';
import 'package:baru/user/riwayatPesanan.dart';
import 'package:baru/user/detailProduk.dart';

// HomePage widget untuk menampilkan halaman utama aplikasi
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
  String _searchQuery = "";
  List<ProdukResponModel> _allProducts = [];
  List<ProdukResponModel> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  String _sortValue = "Terbaru";

  @override
  void initState() {
    super.initState();
    _loadData();
    getTypeValue();
  }

  void _loadData() async {
    _allProducts = await fetchData();
    _filteredProducts = _allProducts;
    setState(() {});
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts =
            _allProducts
                .where(
                  (product) => product.namaProduk!.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  void _sortProducts(String value) {
    setState(() {
      _sortValue = value;
      switch (value) {
        case "Terbaru":
          _filteredProducts.sort((a, b) => b.idProduk!.compareTo(a.idProduk!));
          break;
        case "Harga Terendah":
          _filteredProducts.sort(
            (a, b) => a.hargaProduk!.compareTo(b.hargaProduk!),
          );
          break;
        case "Harga Tertinggi":
          _filteredProducts.sort(
            (a, b) => b.hargaProduk!.compareTo(a.hargaProduk!),
          );
          break;
        case "Nama A-Z":
          _filteredProducts.sort(
            (a, b) => a.namaProduk!.compareTo(b.namaProduk!),
          );
          break;
        case "Nama Z-A":
          _filteredProducts.sort(
            (a, b) => b.namaProduk!.compareTo(a.namaProduk!),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Belanja Hemat dan Mudah',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          if (!isAdmin)
            IconButton(
              icon: Icon(
                Icons.history,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const riwayatPesanan(),
                  ),
                );
              },
            ),
        ],
      ),
      drawer: isAdmin ? const CustomDrawer() : null,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[600],
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterProducts,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          'assets/images/search_icon.svg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: SvgPicture.asset(
                          'assets/images/filter_icon.svg',
                          width: 20,
                          height: 20,
                        ),
                        onPressed: () {
                          // Show filter options
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder:
                                (context) => Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Filter Produk',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Urutkan berdasarkan:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 10,
                                        children:
                                            [
                                                  'Terbaru',
                                                  'Harga Terendah',
                                                  'Harga Tertinggi',
                                                  'Nama A-Z',
                                                  'Nama Z-A',
                                                ]
                                                .map(
                                                  (option) => ChoiceChip(
                                                    label: Text(option),
                                                    selected:
                                                        _sortValue == option,
                                                    selectedColor: const Color(
                                                      0xFFFF5B5B,
                                                    ).withOpacity(0.2),
                                                    onSelected: (selected) {
                                                      if (selected) {
                                                        Navigator.pop(context);
                                                        _sortProducts(option);
                                                      }
                                                    },
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFFF5B5B,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 15,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text(
                                            'Terapkan Filter',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          );
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Category Title and Sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Semua Produk',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _sortValue,
                  icon: const Icon(Icons.arrow_drop_down),
                  underline: Container(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _sortProducts(newValue);
                    }
                  },
                  items:
                      <String>[
                        'Terbaru',
                        'Harga Terendah',
                        'Harga Tertinggi',
                        'Nama A-Z',
                        'Nama Z-A',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
          // Product Grid
          Expanded(
            child:
                _allProducts.isEmpty
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF5B5B),
                      ),
                    )
                    : _filteredProducts.isEmpty
                    ? const Center(
                      child: Text('Tidak ada produk yang ditemukan'),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        var product = _filteredProducts[index];
                        var gambar = product.fotoProduk.toString();
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                    child: Image.network(
                                      '$gambarUrl/$gambar?v=${DateTime.now().millisecondsSinceEpoch}',
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          height: 140,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Favorite Button hanya untuk non-admin
                                  if (!isAdmin)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        // child: IconButton(
                                        //   icon: SvgPicture.asset(
                                        //     'assets/images/heart_icon.svg',
                                        //     width: 20,
                                        //     height: 20,
                                        //   ),
                                        //   iconSize: 20,
                                        //   onPressed: () {},
                                        //   constraints: const BoxConstraints(
                                        //     minHeight: 36,
                                        //     minWidth: 36,
                                        //   ),
                                        //   padding: EdgeInsets.zero,
                                        // ),
                                      ),
                                    ),
                                  // Removed discount badge
                                ],
                              ),
                              // Product Details
                              Flexible(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Category
                                        Text(
                                          product.namaKategori ?? 'Kategori',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Product Name
                                        Text(
                                          product.namaProduk.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Price
                                        Text(
                                          'Rp ${product.hargaProduk}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFFFF5B5B),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Rating Stars
                                        Row(
                                          children: [
                                            Row(
                                              children: List.generate(
                                                5,
                                                (i) => Icon(
                                                  i < (index % 5 + 3)
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${(index % 5 + 3)}.0',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Stock
                                        Text(
                                          'Stok: ${product.stok}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Add to Cart Button hanya untuk non-admin
                                        if (!isAdmin)
                                          Container(
                                            width: double.infinity,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF5B5B),
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFFFF5B5B,
                                                  ).withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailProdukPage(
                                                        idProduk: product
                                                            .idProduk
                                                            .toString(),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                child: const Center(
                                                  child: Text(
                                                    'View Detail',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (isAdmin == true) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Color(0xFFFF5B5B),
                                                ),
                                                tooltip: 'Edit Produk',
                                                onPressed: () {
                                                  var idBarang =
                                                      product.idProduk
                                                          .toString();
                                                  goEdit(idBarang);
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                tooltip: 'Hapus Produk',
                                                onPressed: () {
                                                  var idBarang =
                                                      product.idProduk
                                                          .toString();
                                                  delete(idBarang);
                                                },
                                              ),
                                            ],
                                          ),
                                        ] else ...[
                                          // Row(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.end,
                                          //   children: [
                                          //     Container(
                                          //       decoration: BoxDecoration(
                                          //         color: const Color(
                                          //           0xFFFF5B5B,
                                          //         ),
                                          //         borderRadius:
                                          //             BorderRadius.circular(15),
                                          //       ),
                                          //       child: IconButton(
                                          //         onPressed: () {},
                                          //         icon: const Icon(
                                          //           Icons.add,
                                          //           color: Colors.white,
                                          //           size: 20,
                                          //         ),
                                          //         padding: EdgeInsets.zero,
                                          //         constraints:
                                          //             const BoxConstraints(
                                          //               minHeight: 30,
                                          //               minWidth: 30,
                                          //             ),
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mengambil data produk dari API
  Future<List<ProdukResponModel>> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getProduk'),
        headers: {
          'Content-Type':
              'application/json; charset=UTF-8; Connection: KeepAlive',
        },
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        List<ProdukResponModel> produkList =
            data.map((e) => ProdukResponModel.fromJson(e)).toList();
        _allProducts = produkList;
        _filteredProducts = _allProducts;
        _sortProducts(_sortValue);
        return produkList;
      } else {
        throw Exception('Failed to load Produk: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load Produk: $e');
    }
  }

  // Fungsi untuk mendapatkan tipe pengguna dari SharedPreferences
  getTypeValue() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? stringValue = prefs.getString('type');
      String? nama = prefs.getString('name');
      String? email1 = prefs.getString('email');
      setState(() {
        if (stringValue == "admin") {
          isAdmin = true;
          name = nama;
          email = email1;
        }
      });
    } catch (e) {
      print('Error getting user type: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error getting user type: $e')));
      }
    }
  }

  // Fungsi untuk logout
  logOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      setState(() {
        isAdmin = false;
        name = null;
        email = null;
      });
      // Refresh halaman setelah logout
      _loadData();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Fungsi untuk navigasi ke halaman edit
  Future<void> goEdit(String idBarang) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditForm(idBarang: idBarang)),
      );
      // Refresh data setelah kembali dari halaman edit
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka halaman edit: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Fungsi untuk menghapus produk
  Future<void> delete(String idBarang) async {
    try {
      // Tampilkan dialog konfirmasi sebelum menghapus
      bool confirmDelete =
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Konfirmasi Hapus'),
                content: const Text(
                  "Apakah Anda yakin ingin menghapus produk ini?",
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: Colors.grey),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5B5B),
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          ) ??
          false;

      if (!confirmDelete) return;

      final response = await http.delete(
        Uri.parse('$baseUrl/deleteApi/$idBarang'),
      );
      if (response.statusCode == 200) {
        if (!mounted) return; // Cek apakah context masih aktif

        // Tampilkan snackbar sebagai pengganti dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil dihapus'),
            backgroundColor: Color(0xFFFF5B5B),
            duration: Duration(seconds: 2),
          ),
        );

        // Refresh data setelah menghapus
        _loadData();
      } else {
        throw Exception('Failed to delete data: ${response.statusCode}');
      }
    } catch (error) {
      print(error);
      if (!mounted) return;

      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus produk: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
