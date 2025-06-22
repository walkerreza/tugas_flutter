import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Model untuk item di keranjang
class CartItem {
  final String id;
  final String imageUrl;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

class UserKeranjangPage extends StatefulWidget {
  const UserKeranjangPage({super.key});

  @override
  State<UserKeranjangPage> createState() => _UserKeranjangPageState();
}

class _UserKeranjangPageState extends State<UserKeranjangPage> {
  // Data dummy, nantinya diganti dengan data dari state management/API
  final List<CartItem> _cartItems = [
    CartItem(
      id: 'p1',
      name: 'Nastar Nanas',
      imageUrl: 'https://via.placeholder.com/150', // Ganti dengan URL gambar produk asli
      price: 56160,
      quantity: 1,
    ),
    CartItem(
      id: 'p2',
      name: 'Kue Coklat Premium',
      imageUrl: 'https://via.placeholder.com/150', // Ganti dengan URL gambar produk asli
      price: 45000,
      quantity: 2,
    ),
  ];

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  void _updateQuantity(CartItem item, String newQuantityStr) {
    final newQuantity = int.tryParse(newQuantityStr);
    if (newQuantity != null && newQuantity > 0) {
      setState(() {
        item.quantity = newQuantity;
      });
    }
  }

  void _removeItem(CartItem item) {
    setState(() {
      _cartItems.removeWhere((cartItem) => cartItem.id == item.id);
    });
  }

  double get _grandTotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Saya'),
        backgroundColor: Colors.blue[600],
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : SingleChildScrollView(
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
                          DataColumn(label: Text('Produk', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Harga', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Kuantitas', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _cartItems.map((item) => _buildCartItemRow(item)).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _cartItems.isEmpty ? null : _buildSummaryAndCheckout(),
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'Keranjang Anda kosong',
            style: TextStyle(fontSize: 22, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Text(
            'Ayo, isi dengan produk favoritmu!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  DataRow _buildCartItemRow(CartItem item) {
    final quantityController = TextEditingController(text: item.quantity.toString());
    quantityController.selection = TextSelection.fromPosition(TextPosition(offset: quantityController.text.length));

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              // Ganti Image.network dengan placeholder untuk mengatasi error di desktop
              const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
              const SizedBox(width: 10),
              Text(item.name),
            ],
          ),
        ),
        DataCell(Text(currencyFormatter.format(item.price))),
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _updateQuantity(item, quantityController.text),
                child: const Text('Perbarui'),
              ),
            ],
          ),
        ),
        DataCell(Text(currencyFormatter.format(item.total))),
        DataCell(
          TextButton(
            onPressed: () { /* TODO: Navigasi ke checkout item ini */ },
            child: const Text('Checkout →'),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeItem(item),
            tooltip: 'Hapus item',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryAndCheckout() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: ${currencyFormatter.format(_grandTotal)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () { /* TODO: Navigasi ke halaman checkout utama */ },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              textStyle: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            child: const Text('Checkout Semua'),
          ),
        ],
      ),
    );
  }
}
