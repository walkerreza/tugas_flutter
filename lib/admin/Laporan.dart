import 'package:flutter/material.dart';
import 'package:baru/custom_drawer.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<LaporanTransaksi> _masterData = [];
  List<LaporanTransaksi> _filteredData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredData = _masterData.where((item) {
        return item.produk.toLowerCase().contains(query) ||
            item.invoice.toLowerCase().contains(query) ||
            item.id.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _fetchLaporan() async {
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih rentang tanggal terlebih dahulu.')),
      );
      return;
    }
    setState(() => _isLoading = true);

    // Simulasi panggil API
    await Future.delayed(const Duration(seconds: 2));

    // Generate data dummy
    final random = Random();
    _masterData = List.generate(
      20, 
      (index) => LaporanTransaksi(
        id: 'TRX-${1000 + index}',
        produk: 'Produk ${String.fromCharCode(65 + random.nextInt(26))}',
        quantity: random.nextInt(5) + 1,
        pengiriman: ['JNE', 'GoSend', 'GrabExpress'][random.nextInt(3)],
        invoice: 'INV/${DateTime.now().year}/${100 + index}',
        tanggalOrder: DateTime.now().subtract(Duration(days: random.nextInt(30))),
      ),
    );

    setState(() {
      _filteredData = _masterData;
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        backgroundColor: Colors.blue[600],
      ),
      drawer: const CustomDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateFilterCard(constraints),
                const SizedBox(height: 20),
                _buildTransaksiCard(constraints),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateFilterCard(BoxConstraints constraints) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rentang Waktu Laporan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: constraints.maxWidth > 500 ? 200 : double.infinity,
                  child: _buildDateField(_startDateController, 'Tanggal Awal'),
                ),
                SizedBox(
                  width: constraints.maxWidth > 500 ? 200 : double.infinity,
                  child: _buildDateField(_endDateController, 'Tanggal Akhir'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _fetchLaporan,
                icon: const Icon(Icons.search, color: Colors.white),
                label: const Text('Tampilkan Laporan', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'dd/mm/yyyy',
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () => _selectDate(context, controller),
    );
  }

  Widget _buildTransaksiCard(BoxConstraints constraints) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Laporan Transaksi', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              width: constraints.maxWidth > 400 ? 250 : double.infinity,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Cari Laporan...',
                  hintText: 'ID, Produk, atau Invoice',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: PaginatedDataTable(
                  header: const SizedBox.shrink(), // Header tidak diperlukan lagi di sini
                  rowsPerPage: 10,
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Produk')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Pengiriman')),
                    DataColumn(label: Text('Invoice')),
                    DataColumn(label: Text('Tanggal')),
                  ],
                  source: LaporanDataSource(data: _filteredData, context: context),
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf), label: const Text('PDF')),
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.print), label: const Text('Print')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LaporanTransaksi {
  final String id, produk, pengiriman, invoice;
  final int quantity;
  final DateTime tanggalOrder;

  LaporanTransaksi({
    required this.id,
    required this.produk,
    required this.quantity,
    required this.pengiriman,
    required this.invoice,
    required this.tanggalOrder,
  });
}

class LaporanDataSource extends DataTableSource {
  final List<LaporanTransaksi> data;
  final BuildContext context;

  LaporanDataSource({required this.data, required this.context});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final item = data[index];
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(item.id)),
      DataCell(Text(item.produk)),
      DataCell(Text(item.quantity.toString())),
      DataCell(Text(item.pengiriman)),
      DataCell(Text(item.invoice)),
      DataCell(Text(DateFormat('dd/MM/yy').format(item.tanggalOrder))),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
