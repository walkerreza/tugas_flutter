import 'package:flutter/material.dart';
import 'package:baru/custom_drawer.dart';

class PengirimanPage extends StatefulWidget {
  const PengirimanPage({super.key});

  @override
  State<PengirimanPage> createState() => _PengirimanPageState();
}

class _PengirimanPageState extends State<PengirimanPage> {
  // Data dummy, untuk diganti dengan data dari API
  final List<Pengiriman> _data = List.generate(
    15, // Contoh 15 data
    (index) => Pengiriman(
      id: '${100 + index}',
      produk: 'Produk Pesanan ${index + 1}',
      quantity: (index % 3) + 1,
      pengiriman: 'GoSend Same Day',
      invoice: 'INV/20250622/${100 + index}',
      status: ['Dikemas', 'Dikirim', 'Tiba di Tujuan'][index % 3],
      tanggalOrder: DateTime.now().subtract(Duration(days: index, hours: index * 2)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pengiriman'),
        backgroundColor: Colors.blue[600],
      ),
      drawer: const CustomDrawer(),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: PaginatedDataTable(
            header: const Text('Daftar Pengiriman'),
            rowsPerPage: 8,
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Produk')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Pengiriman')),
              DataColumn(label: Text('Invoice')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Tanggal Order')),
            ],
            source: PengirimanDataSource(data: _data),
          ),
        ),
      ),
    );
  }
}

// Model data untuk Pengiriman
class Pengiriman {
  final String id;
  final String produk;
  final int quantity;
  final String pengiriman;
  final String invoice;
  final String status;
  final DateTime tanggalOrder;

  Pengiriman({
    required this.id,
    required this.produk,
    required this.quantity,
    required this.pengiriman,
    required this.invoice,
    required this.status,
    required this.tanggalOrder,
  });
}

// DataTableSource untuk PaginatedDataTable
class PengirimanDataSource extends DataTableSource {
  final List<Pengiriman> data;

  PengirimanDataSource({required this.data});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }
    final item = data[index];

    return DataRow(cells: [
      DataCell(Text(item.id)),
      DataCell(Text(item.produk)),
      DataCell(Text(item.quantity.toString())),
      DataCell(Text(item.pengiriman)),
      DataCell(Text(item.invoice)),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(item.status),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          item.status,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      )),
      DataCell(Text('${item.tanggalOrder.day}/${item.tanggalOrder.month}/${item.tanggalOrder.year}')),
    ]);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Dikemas':
        return Colors.blue;
      case 'Dikirim':
        return Colors.orange;
      case 'Tiba di Tujuan':
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
