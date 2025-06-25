import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:baru/custom_drawer.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal dan angka
import 'package:baru/constants.dart'; // Menggunakan baseUrl dari constants

class PesananAdminPage extends StatefulWidget {
  const PesananAdminPage({super.key});

  @override
  State<PesananAdminPage> createState() => _PesananAdminPageState();
}

class _PesananAdminPageState extends State<PesananAdminPage> {
  List<Pesanan> _data = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPesanan();
  }

  Future<void> _fetchPesanan() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pesanan-masuk'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          _data = jsonResponse.map((data) => Pesanan.fromJson(data)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Masuk'),
        backgroundColor: Colors.blue[600],
      ),
      drawer: const CustomDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_data.isEmpty) {
      return const Center(child: Text('Tidak ada pesanan masuk.'));
    }

    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: PaginatedDataTable(
          header: const Text('Daftar Pesanan'),
          rowsPerPage: 10,
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Produk')),
            DataColumn(label: Text('Quantity')),
            DataColumn(label: Text('Total Tagihan')),
            DataColumn(label: Text('Pengiriman')),
            DataColumn(label: Text('Tipe Bayar')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Cek Bukti')),
            DataColumn(label: Text('Action')),
            DataColumn(label: Text('Tanggal Pesan')),
          ],
          source: PesananDataSource(
            data: _data,
            context: context,
            onTerima: (id) => _updatePesananStatus(id, 'terima'),
            onTolak: (id) => _updatePesananStatus(id, 'tolak'),
          ),
        ),
      ),
    );
  }

  Future<void> _updatePesananStatus(int id, String action) async {
    final url = Uri.parse('$baseUrl/pesanan/$action/$id');
    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (mounted) {
        final responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Aksi berhasil.')),
          );
          // Refresh data
          setState(() {
            _isLoading = true;
          });
          _fetchPesanan();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: ${responseData['message'] ?? 'Terjadi kesalahan'}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }
}

class Pesanan {
  final int idPesanan;
  final String namaProduk;
  final String fotoProduk;
  final int quantity;
  final int totalOngkir;
  final String namaPenerima;
  final String namaKota;
  final String tipePembayaran;
  final String? buktiBayar;
  final String? buktiBayarDp;
  final DateTime updatedAt;

  Pesanan({
    required this.idPesanan,
    required this.namaProduk,
    required this.fotoProduk,
    required this.quantity,
    required this.totalOngkir,
    required this.namaPenerima,
    required this.namaKota,
    required this.tipePembayaran,
    this.buktiBayar,
    this.buktiBayarDp,
    required this.updatedAt,
  });

  factory Pesanan.fromJson(Map<String, dynamic> json) {
    return Pesanan(
      idPesanan: json['id_pesanan'],
      namaProduk: json['nama_produk'],
      fotoProduk: json['foto_produk'],
      quantity: json['quantity'],
      totalOngkir: json['total_ongkir'],
      namaPenerima: json['nama_penerima'],
      namaKota: json['nama_kota'],
      tipePembayaran: json['tipe_pembayaran'],
      buktiBayar: json['bukti_bayar'],
      buktiBayarDp: json['bukti_bayar_dp'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class PesananDataSource extends DataTableSource {
  final Function(int) onTerima; // Callback
  final Function(int) onTolak;   // Callback
  final List<Pesanan> data;
  final BuildContext context;

    PesananDataSource({
    required this.data,
    required this.context,
    required this.onTerima,
    required this.onTolak,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final pesanan = data[index];
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return DataRow(cells: [
      DataCell(Text('#PP00${pesanan.idPesanan}')),
      DataCell(Text(pesanan.namaProduk)),
      DataCell(Text(pesanan.quantity.toString())),
      DataCell(Text(currencyFormatter.format(pesanan.totalOngkir))),
      DataCell(Text(pesanan.namaPenerima)),
      DataCell(Text(pesanan.tipePembayaran.toUpperCase())),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 42, 255), // Status 1 = Pesanan Masuk
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Masuk',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      )),
      DataCell(ElevatedButton(
        onPressed: () {
          // TODO: Implementasi lihat bukti pembayaran
        },
        child: const Text('Lihat'),
      )),
      DataCell(Row(
        children: [
                    IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => onTerima(pesanan.idPesanan),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => onTolak(pesanan.idPesanan),
          ),
        ],
      )),
      DataCell(Text(DateFormat('d MMM yyyy').format(pesanan.updatedAt))),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
