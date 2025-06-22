import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Model untuk data pengiriman
class PengirimanData {
  final String id;
  final String namaProduk;
  final String imageUrl;
  final String ekspedisi;
  final int quantity;
  final String alamatPengiriman;
  final String invoice;
  final String status;
  final DateTime tanggalKirim;

  PengirimanData({
    required this.id,
    required this.namaProduk,
    required this.imageUrl,
    required this.ekspedisi,
    required this.quantity,
    required this.alamatPengiriman,
    required this.invoice,
    required this.status,
    required this.tanggalKirim,
  });
}

class Pengiriman extends StatefulWidget {
  const Pengiriman({super.key});

  @override
  State<Pengiriman> createState() => _PengirimanState();
}

class _PengirimanState extends State<Pengiriman> {
  // Data dummy, untuk saat ini kosong sesuai desain.
  // Anda bisa menambahkan data di sini untuk melihat tabelnya.
  final List<PengirimanData> _pengirimanList = [
    // Contoh data jika ingin diisi:
    /*
    PengirimanData(
      id: '#PP006',
      namaProduk: 'Gegeh',
      imageUrl: 'https://via.placeholder.com/150',
      ekspedisi: 'JNE Express',
      quantity: 1,
      alamatPengiriman: 'Padang | Sumatera Barat',
      invoice: 'INV/2025/06/22/001',
      status: 'Dalam Perjalanan',
      tanggalKirim: DateTime(2025, 6, 22),
    ),
    */
  ];

  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan DiKirim'),
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
                    columnSpacing: 20,
                    columns: _buildTableHeaders(),
                    rows: _pengirimanList.map((data) => _buildDataRow(data)).toList(),
                  ),
                ),
              ),
            ),
            if (_pengirimanList.isEmpty) _buildEmptyState(),
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
              Icons.local_shipping_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'Belum Ada Pengiriman',
              style: TextStyle(fontSize: 22, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              'Semua status pengiriman akan muncul di sini.',
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
      DataColumn(label: Text('ID', style: style)),
      DataColumn(label: Text('Produk', style: style)),
      DataColumn(label: Text('Ekspedisi', style: style)),
      DataColumn(label: Text('Quantity', style: style)),
      DataColumn(label: Text('Pengiriman', style: style)),
      DataColumn(label: Text('Invoice', style: style)),
      DataColumn(label: Text('Status', style: style)),
      DataColumn(label: Text('Tanggal Di Kirim', style: style)),
      DataColumn(label: Text('Action', style: style)),
    ];
  }

  DataRow _buildDataRow(PengirimanData data) {
    return DataRow(
      cells: [
        DataCell(Text(data.id)),
        DataCell(
          Row(
            children: [
              const Icon(Icons.image_outlined, size: 32, color: Colors.grey), // Placeholder
              const SizedBox(width: 10),
              Text(data.namaProduk),
            ],
          ),
        ),
        DataCell(Text(data.ekspedisi)),
        DataCell(Text('${data.quantity} / Pcs')),
        DataCell(Text(data.alamatPengiriman)),
        DataCell(Text(data.invoice)),
        DataCell(_buildStatusChip(data.status)),
        DataCell(Text(_dateFormatter.format(data.tanggalKirim))),
        DataCell(
          TextButton(
            onPressed: () { /* TODO: Implement action */ },
            child: const Text('Lacak'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status) {
      case 'Dalam Perjalanan':
        chipColor = Colors.orange;
        break;
      case 'Tiba di Tujuan':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }
    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
