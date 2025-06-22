import 'package:flutter/material.dart';
import 'package:baru/custom_drawer.dart';

// Model untuk data rekening
class Rekening {
  final String id;
  String namaPemilik;
  String jenisBank;
  String nomorRekening;

  Rekening({
    required this.id,
    required this.namaPemilik,
    required this.jenisBank,
    required this.nomorRekening,
  });
}

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

  // Data dummy
  final List<Rekening> _rekeningList = [
    Rekening(id: '#K0-5', namaPemilik: 'Sina', jenisBank: 'BSI', nomorRekening: '12828723'),
    Rekening(id: '#K0-4', namaPemilik: 'Tata', jenisBank: 'MANDIRI', nomorRekening: '232893841'),
    Rekening(id: '#K0-3', namaPemilik: 'Mabok', jenisBank: 'BRI', nomorRekening: '2893938'),
    Rekening(id: '#K0-2', namaPemilik: 'Ari', jenisBank: 'BCA', nomorRekening: '90232839743'),
    Rekening(id: '#K0-1', namaPemilik: 'Rizki Ratih 2', jenisBank: 'BNI', nomorRekening: '081877236012'),
  ];

  Rekening? _rekeningDiedit;

  @override
  void dispose() {
    _namaController.dispose();
    _nomorController.dispose();
    super.dispose();
  }

  void _simpanRekening() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        if (_rekeningDiedit == null) {
          final newId = '#K0-${_rekeningList.length + 1}';
          _rekeningList.add(Rekening(
            id: newId,
            namaPemilik: _namaController.text,
            jenisBank: _selectedBank!,
            nomorRekening: _nomorController.text,
          ));
        } else {
          _rekeningDiedit!.namaPemilik = _namaController.text;
          _rekeningDiedit!.jenisBank = _selectedBank!;
          _rekeningDiedit!.nomorRekening = _nomorController.text;
        }
        _resetForm();
      });
    }
  }

  void _editRekening(Rekening rekening) {
    setState(() {
      _rekeningDiedit = rekening;
      _namaController.text = rekening.namaPemilik;
      _nomorController.text = rekening.nomorRekening;
      _selectedBank = rekening.jenisBank;
    });
  }

  void _hapusRekening(Rekening rekening) {
    setState(() {
      _rekeningList.removeWhere((item) => item.id == rekening.id);
      if (_rekeningDiedit?.id == rekening.id) {
        _resetForm();
      }
    });
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID Rekening')),
                  DataColumn(label: Text('Nama Pemilik')),
                  DataColumn(label: Text('Jenis Rekening')),
                  DataColumn(label: Text('Nomor Rekening')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: _rekeningList.map((rekening) {
                  return DataRow(
                    cells: [
                      DataCell(Text(rekening.id)),
                      DataCell(Text(rekening.namaPemilik)),
                      DataCell(Text(rekening.jenisBank)),
                      DataCell(Text(rekening.nomorRekening)),
                      DataCell(
                        PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'edit') _editRekening(rekening);
                            if (value == 'hapus') _hapusRekening(rekening);
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
