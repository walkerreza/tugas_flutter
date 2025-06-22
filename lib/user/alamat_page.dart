import 'package:flutter/material.dart';

class AlamatPage extends StatefulWidget {
  const AlamatPage({super.key});

  @override
  State<AlamatPage> createState() => _AlamatPageState();
}

class _AlamatPageState extends State<AlamatPage> {
  final _formKey = GlobalKey<FormState>();

  // Dummy data untuk dropdown
  final List<String> _provinsiList = ['Sumatera Barat', 'Jawa Barat', 'DKI Jakarta'];
  final List<String> _kotaList = ['Padang', 'Bandung', 'Jakarta Pusat'];
  String? _selectedProvinsi;
  String? _selectedKota;

  @override
  void initState() {
    super.initState();
    // Set nilai awal jika ada data yang tersimpan
    _selectedProvinsi = _provinsiList.first;
    _selectedKota = _kotaList.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat'),
        backgroundColor: Colors.blue[600],
        // Tombol kembali akan muncul secara otomatis karena halaman ini di-push
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alamat Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildTextField(label: 'Nama Penerima *', initialValue: 'tere'),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDropdownField(label: 'Provinsi *', value: _selectedProvinsi, items: _provinsiList, onChanged: (val) => setState(() => _selectedProvinsi = val))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDropdownField(label: 'Kota / Kabupaten *', value: _selectedKota, items: _kotaList, onChanged: (val) => setState(() => _selectedKota = val))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTextField(label: 'Kode Pos *', initialValue: '30151', keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(label: 'Nomor Telp *', initialValue: '081218113193', keyboardType: TextInputType.phone)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Alamat *', initialValue: 'jl. suka bangun', maxLines: 3),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Logika untuk menyimpan data
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Alamat berhasil diperbarui')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1a56db),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Perbaharui Alamat Pengiriman', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, String? initialValue, int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Field ini tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true, // Mencegah overflow pada teks yang panjang
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              // Menambahkan ellipsis jika teks terlalu panjang
              child: Text(item, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          validator: (value) {
            if (value == null) {
              return 'Pilih salah satu';
            }
            return null;
          },
        ),
      ],
    );
  }
}
