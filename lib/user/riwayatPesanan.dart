import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Model untuk data riwayat pesanan
class RiwayatPesananData {
  final String noPesanan;
  final String namaProduk;
  final int quantity;
  final String status;
  final double totalBelanja;
  final String invoice;

  RiwayatPesananData({
    required this.noPesanan,
    required this.namaProduk,
    required this.quantity,
    required this.status,
    required this.totalBelanja,
    required this.invoice,
  });
}

class riwayatPesanan extends StatefulWidget {
  const riwayatPesanan({super.key});

  @override
  State<riwayatPesanan> createState() => _riwayatPesananState();
}

class _riwayatPesananState extends State<riwayatPesanan> {
  // Data dummy, untuk saat ini kosong sesuai desain.
  final List<RiwayatPesananData> _riwayatList = [
    // Contoh data jika ingin diisi:
    /*
    RiwayatPesananData(
      noPesanan: '#PP001',
      namaProduk: 'Nastar Nanas',
      quantity: 2,
      status: 'Selesai',
      totalBelanja: 112320,
      invoice: 'INV/2025/06/20/001',
    ),
    */
  ];

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: Colors.blue[600],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
                  child: DataTable(
                    columnSpacing: 30,
                    columns: _buildTableHeaders(),
                    rows: _riwayatList.map((data) => _buildDataRow(data)).toList(),
                  ),
                ),
              ),
            ),
            if (_riwayatList.isEmpty) _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 100),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'Riwayat pesanan Anda kosong',
              style: TextStyle(fontSize: 22, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              'Semua pesanan yang sudah selesai akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  List<DataColumn> _buildTableHeaders() {
    const style = TextStyle(fontWeight: FontWeight.bold);
    return const [
      DataColumn(label: Text('No Pesanan', style: style)),
      DataColumn(label: Text('Nama Produk', style: style)),
      DataColumn(label: Text('Quantity', style: style)),
      DataColumn(label: Text('Status', style: style)),
      DataColumn(label: Text('Total Belanja', style: style)),
      DataColumn(label: Text('Invoice', style: style)),
    ];
  }

  DataRow _buildDataRow(RiwayatPesananData data) {
    return DataRow(
      cells: [
        DataCell(Text(data.noPesanan)),
        DataCell(Text(data.namaProduk)),
        DataCell(Text(data.quantity.toString())),
        DataCell(_buildStatusChip(data.status)),
        DataCell(Text(currencyFormatter.format(data.totalBelanja))),
        DataCell(TextButton(onPressed: () {}, child: Text(data.invoice))),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor = Colors.white;
    switch (status) {
      case 'Selesai':
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'Dibatalkan':
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      default:
        chipColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }
    return Chip(
      label: Text(status, style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 12)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide.none,
      ),
    );
  }
}