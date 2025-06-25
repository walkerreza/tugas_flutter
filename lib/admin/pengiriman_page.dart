import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:baru/custom_drawer.dart';
import 'package:baru/model/pengiriman.dart';
import 'package:baru/constants.dart';

class PengirimanPage extends StatefulWidget {
  const PengirimanPage({super.key});

  @override
  State<PengirimanPage> createState() => _PengirimanPageState();
}

class _PengirimanPageState extends State<PengirimanPage> {
  late Future<List<Pesanan>> _futurePesanan;

  @override
  void initState() {
    super.initState();
    _futurePesanan = _fetchPesananDikirim();
  }

  Future<List<Pesanan>> _fetchPesananDikirim() async {
        final response = await http.get(Uri.parse('$baseUrl/pesanan/dikirim'));

    // DEBUG: Cetak status code dan body respons
    print('DIKIRIM - Status Code: ${response.statusCode}');
    print('DIKIRIM - Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final pesananList = pesananFromJson(response.body);
      // DEBUG: Cetak jumlah data yang berhasil di-parse
      print('DIKIRIM - Parsed Data Count: ${pesananList.length}');
      return pesananList;
    } else {
      throw Exception('Gagal memuat pesanan dikirim');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pengiriman'),
        backgroundColor: Colors.blue[600],
      ),
      drawer: const CustomDrawer(),
      body: FutureBuilder<List<Pesanan>>(
        future: _futurePesanan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data pengiriman.'));
          } else {
            return SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: PaginatedDataTable(
                  header: const Text('Daftar Pengiriman'),
                  rowsPerPage: 10,
                  columns: const [
                    DataColumn(label: Text('ID Pesanan')),
                    DataColumn(label: Text('Produk')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Invoice')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Tgl Order')),
                  ],
                  source: PesananDataSource(data: snapshot.data!),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class PesananDataSource extends DataTableSource {
  final List<Pesanan> data;

  PesananDataSource({required this.data});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final item = data[index];

    return DataRow(cells: [
      DataCell(Text(item.idPesanan.toString())),
      DataCell(Text(item.namaProduk ?? 'N/A')),
      DataCell(Text(item.quantity?.toString() ?? '0')),
      DataCell(Text(item.invoice ?? 'N/A')),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(item.getStatusString()),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          item.getStatusString(),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      )),
      DataCell(Text(item.tanggalOrder != null ? '${item.tanggalOrder!.day}/${item.tanggalOrder!.month}/${item.tanggalOrder!.year}' : 'N/A')),
    ]);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Diproses':
        return Colors.blue;
      case 'Dikirim':
        return Colors.orange;
      case 'Selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

