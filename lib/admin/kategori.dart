import 'package:flutter/material.dart';
import 'package:baru/custom_drawer.dart';

// Model untuk data kategori
class Kategori {
  final String id;
  String nama;
  String deskripsi;

  Kategori({required this.id, required this.nama, required this.deskripsi});
}

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();

  // Data dummy, nantinya bisa diganti dengan data dari API
  final List<Kategori> _kategoriList = [
    Kategori(id: '#K0-4', nama: 'Nastar Nanas', deskripsi: 'Kue kering isi selai nanas.'),
    Kategori(id: '#K0-3', nama: 'Basreng Pedas', deskripsi: 'Bakso goreng renyah dengan bumbu pedas.'),
    Kategori(id: '#K0-2', nama: 'Makaroni Mantap', deskripsi: 'Makaroni kering aneka rasa.'),
  ];

  Kategori? _kategoriDiedit;

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _simpanKategori() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        if (_kategoriDiedit == null) {
          // Tambah kategori baru
          final newId = '#K0-${_kategoriList.length + 1}'; // Logika ID sederhana
          _kategoriList.add(Kategori(
            id: newId,
            nama: _namaController.text,
            deskripsi: _deskripsiController.text,
          ));
        } else {
          // Update kategori yang ada
          _kategoriDiedit!.nama = _namaController.text;
          _kategoriDiedit!.deskripsi = _deskripsiController.text;
        }
        _resetForm();
      });
    }
  }

  void _editKategori(Kategori kategori) {
    setState(() {
      _kategoriDiedit = kategori;
      _namaController.text = kategori.nama;
      _deskripsiController.text = kategori.deskripsi;
    });
  }

  void _hapusKategori(Kategori kategori) {
    setState(() {
      _kategoriList.removeWhere((item) => item.id == kategori.id);
      if (_kategoriDiedit?.id == kategori.id) {
        _resetForm();
      }
    });
  }

  void _resetForm() {
    _formKey.currentState!.reset();
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
      ),
      drawer: const CustomDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Tampilan layar lebar (desktop)
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildFormCard()),
                Expanded(flex: 2, child: _buildDataTableCard()),
              ],
            );
          } else {
            // Tampilan layar sempit (mobile)
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildFormCard(),
                  _buildDataTableCard(),
                ],
              ),
            );
          }
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID Kategori')),
                  DataColumn(label: Text('Nama Kategori')),
                  DataColumn(label: Text('Deskripsi')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: _kategoriList.map((kategori) {
                  return DataRow(
                    cells: [
                      DataCell(Text(kategori.id)),
                      DataCell(Text(kategori.nama)),
                      DataCell(Text(kategori.deskripsi)),
                      DataCell(
                        PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editKategori(kategori);
                            } else if (value == 'hapus') {
                              _hapusKategori(kategori);
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
            ),
          ],
        ),
      ),
    );
  }
}
