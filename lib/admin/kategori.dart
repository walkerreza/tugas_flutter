import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:baru/constants.dart';
import 'package:baru/custom_drawer.dart';
import 'package:baru/model/kategori.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();

  late Future<List<KategoriModel>> _kategoriFuture;
  KategoriModel? _kategoriDiedit;

  @override
  void initState() {
    super.initState();
    _kategoriFuture = _fetchKategori();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // --- API Communication ---

  Future<List<KategoriModel>> _fetchKategori() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/kategoriApi'), headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => KategoriModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> _addKategori(String nama, String deskripsi) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kategoriStoreApi'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({'nama_kategori': nama, 'deskripsi_kategori': deskripsi}),
      );
      if (response.statusCode == 201) {
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori berhasil ditambahkan'), backgroundColor: Colors.green));
      } else {
        throw Exception('Gagal menambah data. Respon: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _updateKategori(int id, String nama, String deskripsi) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/kategoriUpdateApi/$id'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({'nama_kategori': nama, 'deskripsi_kategori': deskripsi}),
      );
      if (response.statusCode == 200) {
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori berhasil diperbarui'), backgroundColor: Colors.green));
      } else {
        throw Exception('Gagal memperbarui data. Respon: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _deleteKategori(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/kategoriDeleteApi/$id'), headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori berhasil dihapus'), backgroundColor: Colors.green));
      } else {
        throw Exception('Gagal menghapus data. Respon: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // --- UI Logic ---

  void _refreshData() {
    setState(() {
      _kategoriFuture = _fetchKategori();
    });
  }

  void _simpanKategori() {
    if (_formKey.currentState!.validate()) {
      final nama = _namaController.text;
      final deskripsi = _deskripsiController.text;

      if (_kategoriDiedit == null) {
        _addKategori(nama, deskripsi);
      } else {
        _updateKategori(_kategoriDiedit!.idKategori!, nama, deskripsi);
      }
      _resetForm();
    }
  }

  void _editKategori(KategoriModel kategori) {
    setState(() {
      _kategoriDiedit = kategori;
      _namaController.text = kategori.namaKategori ?? '';
      _deskripsiController.text = kategori.deskripsiKategori ?? '';
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _namaController.clear();
    _deskripsiController.clear();
    setState(() {
      _kategoriDiedit = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Produk'),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData, tooltip: 'Refresh Data'),
        ],
      ),
      drawer: const CustomDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          return isDesktop
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 1, child: _buildFormCard()),
                  Expanded(flex: 2, child: _buildDataTableCard()),
                ])
              : SingleChildScrollView(
                  child: Column(children: [_buildFormCard(), _buildDataTableCard()]),
                );
        },
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_kategoriDiedit == null ? 'Kategori Baru' : 'Edit Kategori', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Masukan Kategori baru', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 24),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Kategori', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi Kategori', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: _resetForm, child: const Text('Batal')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _simpanKategori, child: const Text('Simpan Kategori')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTableCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Data Kategori', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Daftar Kategori Produk Yang Akan Di Pasarkan', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            FutureBuilder<List<KategoriModel>>(
              future: _kategoriFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data kategori.'));
                }

                final kategoriList = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Nama Kategori')),
                      DataColumn(label: Text('Deskripsi')),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows: kategoriList.map((kategori) {
                      return DataRow(
                        cells: [
                          DataCell(Text(kategori.idKategori.toString())),
                          DataCell(Text(kategori.namaKategori ?? 'N/A')),
                          DataCell(Text(kategori.deskripsiKategori ?? 'N/A')),
                          DataCell(
                            PopupMenuButton(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editKategori(kategori);
                                } else if (value == 'hapus') {
                                  _deleteKategori(kategori.idKategori!);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'hapus', child: Text('Hapus')),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
