import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:baru/custom_drawer.dart';
import 'package:baru/model/pengiriman.dart'; // Menggunakan model yang sama
import 'package:baru/constants.dart';

class OnProgressPage extends StatefulWidget {
  const OnProgressPage({super.key});

  @override
  State<OnProgressPage> createState() => _OnProgressPageState();
}

class _OnProgressPageState extends State<OnProgressPage> {
  late Future<List<Pesanan>> _futurePesanan;

  @override
  void initState() {
    super.initState();
    _futurePesanan = _fetchPesananOnProgress();
  }

  Future<List<Pesanan>> _fetchPesananOnProgress() async {
        final response = await http.get(Uri.parse('$baseUrl/pesanan/on-progress'));

    // DEBUG: Cetak status code dan body respons
    print('ON PROGRESS - Status Code: ${response.statusCode}');
    print('ON PROGRESS - Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final pesananList = pesananFromJson(response.body);
      // DEBUG: Cetak jumlah data yang berhasil di-parse
      print('ON PROGRESS - Parsed Data Count: ${pesananList.length}');
      return pesananList;
    } else {
      throw Exception('Gagal memuat pesanan yang sedang diproses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Diproses'),
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
            return const Center(child: Text('Tidak ada pesanan yang sedang diproses.'));
          } else {
            return SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: PaginatedDataTable(
                  header: const Text('Daftar Pesanan Diproses'),
                  columns: const [
                    DataColumn(label: Text('ID Pesanan')),
                    DataColumn(label: Text('Produk')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Invoice')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Tanggal Order')),
                    DataColumn(label: Text('Action')),
                  ],
                  source: _PesananDataSource(
                    data: snapshot.data!,
                    context: context,
                    onKirimPressed: (pesanan) => _showKirimDialog(pesanan),
                  ),
                  rowsPerPage: 10,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showKirimDialog(Pesanan pesanan) {
    final resiController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Kirim Pesanan #${pesanan.idPesanan}'),
          content: TextField(
            controller: resiController,
            decoration: const InputDecoration(
              labelText: 'Nomor Resi',
              hintText: 'Masukkan nomor resi pengiriman',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (resiController.text.isNotEmpty) {
                  _kirimPesanan(pesanan.idPesanan, resiController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _kirimPesanan(int idPesanan, String resi) async {
    final url = Uri.parse('$baseUrl/pesanan/kirim/$idPesanan');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode({'resi': resi}),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pesanan #$idPesanan berhasil dikirim!')),
          );
          setState(() {
            _futurePesanan = _fetchPesananOnProgress();
          });
        } else {
          final errorData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengirim: ${errorData['message'] ?? response.body}')),
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

// Menggunakan DataTableSource yang sama dengan PengirimanPage
class _PesananDataSource extends DataTableSource {
  final List<Pesanan> data;
  final BuildContext context;
  final Function(Pesanan) onKirimPressed;

  _PesananDataSource({
    required this.data,
    required this.context,
    required this.onKirimPressed,
  });

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
      DataCell(
        ElevatedButton(
          onPressed: () => onKirimPressed(item),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Kirim'),
        ),
      ),
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
