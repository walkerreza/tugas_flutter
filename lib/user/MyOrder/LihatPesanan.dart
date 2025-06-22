import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Model untuk data pesanan
class Pesanan {
  final String id;
  final String namaProduk;
  final String imageUrl;
  final int quantity;
  final double hargaProduk;
  final String pengiriman;
  final double totalPembayaran;
  final String tipe;
  final String status;

  Pesanan({
    required this.id,
    required this.namaProduk,
    required this.imageUrl,
    required this.quantity,
    required this.hargaProduk,
    required this.pengiriman,
    required this.totalPembayaran,
    required this.tipe,
    required this.status,
  });
}

class Lihatpesanan extends StatefulWidget {
  const Lihatpesanan({super.key});

  @override
  State<Lihatpesanan> createState() => _LihatpesananState();
}

class _LihatpesananState extends State<Lihatpesanan> {
  // Data dummy, nantinya diganti dengan data dari API
  final List<Pesanan> _pesananList = [
    Pesanan(
      id: '#PP006',
      namaProduk: 'Gegeh',
      imageUrl: 'https://via.placeholder.com/150',
      quantity: 1,
      hargaProduk: 56160,
      pengiriman: 'Padang | Sumatera Barat',
      totalPembayaran: 102616,
      tipe: 'LUNAS',
      status: 'Pembayaran Sedang Di Tinjau',
    ),
    Pesanan(
      id: '#PP007',
      namaProduk: 'Kue Coklat',
      imageUrl: 'https://via.placeholder.com/150',
      quantity: 2,
      hargaProduk: 45000,
      pengiriman: 'Jakarta | DKI Jakarta',
      totalPembayaran: 98000,
      tipe: 'COD',
      status: 'Sedang Dikemas',
    ),
  ];

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        backgroundColor: Colors.blue[600],
      ),
      body: _pesananList.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
                    child: DataTable(
                      columnSpacing: 20,
                      columns: _buildTableHeaders(),
                      rows: _pesananList.map((pesanan) => _buildPesananRow(pesanan)).toList(),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'Belum Ada Pesanan',
            style: TextStyle(fontSize: 22, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Text(
            'Semua pesanan yang telah Anda buat akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildTableHeaders() {
    const style = TextStyle(fontWeight: FontWeight.bold);
    return const [
      DataColumn(label: Text('ID', style: style)),
      DataColumn(label: Text('Produk', style: style)),
      DataColumn(label: Text('Quantity', style: style)),
      DataColumn(label: Text('Total Produk', style: style)),
      DataColumn(label: Text('Pengiriman', style: style)),
      DataColumn(label: Text('Total Pembayaran', style: style)),
      DataColumn(label: Text('Tipe', style: style)),
      DataColumn(label: Text('Status', style: style)),
      DataColumn(label: Text('Action', style: style)),
    ];
  }

  DataRow _buildPesananRow(Pesanan pesanan) {
    return DataRow(
      cells: [
        DataCell(Text(pesanan.id)),
        DataCell(
          Row(
            children: [
              const Icon(Icons.image_outlined, size: 32, color: Colors.grey), // Placeholder
              const SizedBox(width: 10),
              Text(pesanan.namaProduk),
            ],
          ),
        ),
        DataCell(Text('${pesanan.quantity} / Pcs')),
        DataCell(Text(currencyFormatter.format(pesanan.hargaProduk * pesanan.quantity))),
        DataCell(Text(pesanan.pengiriman)),
        DataCell(Text(currencyFormatter.format(pesanan.totalPembayaran))),
        DataCell(_buildChip(pesanan.tipe, Colors.lightBlue.shade100, Colors.blue.shade800)),
        DataCell(_buildChip(pesanan.status, Colors.orange.shade100, Colors.orange.shade800)),
        DataCell(
          TextButton(
            onPressed: () { /* TODO: Implement action */ },
            child: const Text('Lihat Detail'),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
