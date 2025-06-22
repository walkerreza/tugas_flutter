import 'package:flutter/material.dart';
import 'package:baru/custom_drawer.dart';

class PesananAdminPage extends StatefulWidget {
  const PesananAdminPage({super.key});

  @override
  State<PesananAdminPage> createState() => _PesananAdminPageState();
}

class _PesananAdminPageState extends State<PesananAdminPage> {
  // Nanti, data ini akan diambil dari API
  final List<Pesanan> _data = List.generate(
    20, // Contoh 20 data
    (index) => Pesanan(
      id: '${index + 1}',
      produk: 'Produk ${index + 1}',
      quantity: (index % 5) + 1,
      totalTagihan: 50000 * ((index % 5) + 1),
      pengiriman: 'JNE Reguler',
      tipe: 'COD',
      status: ['Pending', 'Processing', 'Shipped', 'Delivered'][index % 4],
      tanggalPesan: DateTime.now().subtract(Duration(days: index)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Masuk'),
        backgroundColor: Colors.blue[600],
      ),
      drawer: const CustomDrawer(),
      body: SizedBox(
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
              DataColumn(label: Text('Tipe')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Cek Bukti')),
              DataColumn(label: Text('Action')),
              DataColumn(label: Text('Tanggal Pesan')),
            ],
            source: PesananDataSource(data: _data, context: context),
          ),
        ),
      ),
    );
  }
}

// Model untuk data pesanan
class Pesanan {
  final String id;
  final String produk;
  final int quantity;
  final double totalTagihan;
  final String pengiriman;
  final String tipe;
  final String status;
  final DateTime tanggalPesan;

  Pesanan({
    required this.id,
    required this.produk,
    required this.quantity,
    required this.totalTagihan,
    required this.pengiriman,
    required this.tipe,
    required this.status,
    required this.tanggalPesan,
  });
}

// DataSource untuk PaginatedDataTable
class PesananDataSource extends DataTableSource {
  final List<Pesanan> data;
  final BuildContext context;

  PesananDataSource({required this.data, required this.context});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final pesanan = data[index];

    return DataRow(cells: [
      DataCell(Text(pesanan.id)),
      DataCell(Text(pesanan.produk)),
      DataCell(Text(pesanan.quantity.toString())),
      DataCell(Text('Rp ${pesanan.totalTagihan.toStringAsFixed(0)}')),
      DataCell(Text(pesanan.pengiriman)),
      DataCell(Text(pesanan.tipe)),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(pesanan.status),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          pesanan.status,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      )),
      DataCell(ElevatedButton(
        onPressed: () {
          // Aksi untuk cek bukti
        },
        child: const Text('Lihat'),
      )),
      DataCell(Row(
        children: [
          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}),
        ],
      )),
      DataCell(Text('${pesanan.tanggalPesan.day}/${pesanan.tanggalPesan.month}/${pesanan.tanggalPesan.year}')),
    ]);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Shipped':
        return Colors.green;
      case 'Delivered':
        return Colors.purple;
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
