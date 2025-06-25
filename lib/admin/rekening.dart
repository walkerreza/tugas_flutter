import 'package:flutter/material.dart';
import 'package:baru/services/rekening_service.dart';
import 'package:baru/custom_drawer.dart';
import 'package:baru/model/rekening.dart';

class RekeningPage extends StatefulWidget {
  const RekeningPage({super.key});

  @override
  State<RekeningPage> createState() => _RekeningPageState();
}

class _RekeningPageState extends State<RekeningPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nomorController = TextEditingController();
  String? _selectedBank;

  final List<String> _bankList = ['BNI', 'BSI', 'MANDIRI', 'BRI', 'BCA'];
  late Future<List<RekeningModel>> _rekeningFuture;
  RekeningModel? _rekeningDiedit;

  // Instance RekeningService dibuat per panggilan untuk memastikan tidak ada state yang tersisa.

  @override
  void initState() {
    super.initState();
    _rekeningFuture = RekeningService().getRekening();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nomorController.dispose();
    super.dispose();
  }

  // --- API Communication ---

  Future<void> _addRekening(String nama, String bank, String nomor) async {
    try {
      await RekeningService().addRekening(nama, bank, nomor);
      if (!mounted) return;
      _refreshData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rekening berhasil ditambahkan'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  Future<void> _updateRekening(int id, String nama, String bank, String nomor) async {
    try {
      await RekeningService().updateRekening(id, nama, bank, nomor);
      if (!mounted) return;
      _refreshData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rekening berhasil diperbarui'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  Future<void> _deleteRekening(int id) async {
    try {
      await RekeningService().deleteRekening(id);
      if (!mounted) return;
      _refreshData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rekening berhasil dihapus'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  // --- UI Logic ---
  void _refreshData() {
    setState(() {
      _rekeningFuture = RekeningService().getRekening();
    });
  }

  void _simpanRekening() {
    if (_formKey.currentState!.validate()) {
      final nama = _namaController.text;
      final nomor = _nomorController.text;
      final bank = _selectedBank!;

      if (_rekeningDiedit == null) {
        _addRekening(nama, bank, nomor);
      } else {
        _updateRekening(_rekeningDiedit!.idRekening, nama, bank, nomor);
      }
      _resetForm();
    }
  }

  void _editRekening(RekeningModel rekening) {
    setState(() {
      _rekeningDiedit = rekening;
      _namaController.text = rekening.namaPemilik;
      _nomorController.text = rekening.nomorRekening;
      _selectedBank = rekening.jenisBank;
    });
  }

  void _hapusRekening(int id) {
    _deleteRekening(id);
    if (_rekeningDiedit?.idRekening == id) {
      _resetForm();
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _namaController.clear();
    _nomorController.clear();
    setState(() {
      _selectedBank = null;
      _rekeningDiedit = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekening'),
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
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: _buildFormCard()),
                    Expanded(flex: 2, child: _buildDataTableCard()),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [_buildFormCard(), _buildDataTableCard()],
                  ),
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
              Text(_rekeningDiedit == null ? 'Rekening Baru' : 'Edit Rekening', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Pemilik Rekening', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedBank,
                decoration: const InputDecoration(labelText: 'Jenis Rekening', border: OutlineInputBorder()),
                items: _bankList.map((String bank) {
                  return DropdownMenuItem<String>(value: bank, child: Text(bank));
                }).toList(),
                onChanged: (newValue) => setState(() => _selectedBank = newValue),
                validator: (value) => value == null ? 'Pilih jenis bank' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomorController,
                decoration: const InputDecoration(labelText: 'Nomor Rekening', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Nomor tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: _resetForm, child: const Text('Batal')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _simpanRekening, child: const Text('Simpan Rekening')),
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
            Text('Data Rekening', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            FutureBuilder<List<RekeningModel>>(
              future: _rekeningFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data rekening.'));
                }

                final rekeningList = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Nama Pemilik')),
                      DataColumn(label: Text('Jenis Rekening')),
                      DataColumn(label: Text('Nomor Rekening')),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows: rekeningList.map((rekening) {
                      return DataRow(
                        cells: [
                          DataCell(Text(rekening.idRekening.toString())),
                          DataCell(Text(rekening.namaPemilik)),
                          DataCell(Text(rekening.jenisBank)),
                          DataCell(Text(rekening.nomorRekening)),
                          DataCell(
                            PopupMenuButton(
                              onSelected: (value) {
                                if (value == 'edit') _editRekening(rekening);
                                if (value == 'hapus') _hapusRekening(rekening.idRekening);
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
