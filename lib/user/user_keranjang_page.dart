import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/keranjang_service.dart';
import '../model/keranjang_model.dart';
import '../constants.dart';
import 'MyOrder/checkout.dart';


class UserKeranjangPage extends StatefulWidget {
  const UserKeranjangPage({super.key});

  @override
  State<UserKeranjangPage> createState() => _UserKeranjangPageState();
}

class _UserKeranjangPageState extends State<UserKeranjangPage> {
  final KeranjangService _keranjangService = KeranjangService();
  Future<List<KeranjangItem>>? _keranjangFuture;

  @override
  void initState() {
    super.initState();
    _fetchKeranjang();
  }

  void _fetchKeranjang() {
    setState(() {
      _keranjangFuture = _keranjangService.getKeranjang();
    });
  }



  void _updateQuantity(int idKeranjang, String quantity) {
    final int? newQuantity = int.tryParse(quantity);
    if (newQuantity == null || newQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan kuantitas yang valid.'), backgroundColor: Colors.red),
      );
      return;
    }

    _keranjangService.updateItemQuantity(idKeranjang, newQuantity).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kuantitas berhasil diperbarui.'), backgroundColor: Colors.green),
      );
      _fetchKeranjang();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    });
  }

  void _deleteItem(int idKeranjang) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus item ini dari keranjang?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _keranjangService.deleteItem(idKeranjang).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item berhasil dihapus.'), backgroundColor: Colors.green),
                  );
                  _fetchKeranjang();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
                  );
                });
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchKeranjang,
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: FutureBuilder<List<KeranjangItem>>(
        future: _keranjangFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat keranjang: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyCart();
          } else {
            final items = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                      child: DataTable(
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Harga', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: items.map((item) => _buildCartItemRow(context, item)).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: FutureBuilder<List<KeranjangItem>>(
        future: _keranjangFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return _buildSummaryAndCheckout(context, snapshot.data!);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text('Keranjang Anda kosong', style: TextStyle(fontSize: 22, color: Colors.grey)),
        ],
      ),
    );
  }

  DataRow _buildCartItemRow(BuildContext context, KeranjangItem item) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final quantityController = TextEditingController(text: item.quantity.toString());
    quantityController.selection = TextSelection.fromPosition(TextPosition(offset: quantityController.text.length));
    final total = item.hargaProduk * item.quantity;

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Image.network('$gambarUrl/${item.fotoProduk}', width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.error)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.namaProduk, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(item.namaKategori, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        DataCell(Text(currencyFormatter.format(item.hargaProduk))),
        DataCell(
          Row(
            children: [
              SizedBox(
                width: 50,
                height: 38,
                child: TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.zero),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _updateQuantity(item.idKeranjang, quantityController.text),
                child: const Text('Perbarui'),
              ),
            ],
          ),
        ),
        DataCell(Text(currencyFormatter.format(total))),
        DataCell(
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CheckoutPage(cartItems: [item])),
              );
            },
            child: const Text('Checkout →'),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteItem(item.idKeranjang),
            tooltip: 'Hapus item',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryAndCheckout(BuildContext context, List<KeranjangItem> items) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final double totalAmount = items.fold(0, (sum, item) => sum + (item.quantity * item.hargaProduk));

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -3))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total: ${currencyFormatter.format(totalAmount)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CheckoutPage(cartItems: items)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            child: const Text('Checkout Semua', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
