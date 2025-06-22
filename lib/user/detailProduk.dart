import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:baru/constants.dart';
import 'package:baru/model/produk.dart';

class DetailProdukPage extends StatefulWidget {
  final String idProduk;

  const DetailProdukPage({super.key, required this.idProduk});

  @override
  _DetailProdukPageState createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  Future<ProdukResponModel?>? _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _fetchProductDetails();
  }

  Future<ProdukResponModel?> _fetchProductDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produk/${widget.idProduk}'),
      );

      if (response.statusCode == 200) {
        // API baru mengembalikan satu objek JSON, bukan array
        final data = json.decode(response.body);
        return ProdukResponModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching product details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat detail produk: $e')),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProdukResponModel?>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Memuat...'),
              backgroundColor: Colors.blue[600],
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: Colors.red[400],
            ),
            body: const Center(child: Text('Gagal memuat data produk.')),
          );
        }

        final product = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(product.namaProduk ?? 'Detail Produk'),
            backgroundColor: Colors.blue[600],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: product.fotoProduk != null
                      ? Image.network(
                          '$baseUrl/storage/images/${product.fotoProduk}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
                          },
                        )
                      : const Icon(Icons.image, size: 100, color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.namaProduk ?? 'Nama Produk',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kategori: ${product.namaKategori ?? 'Tidak ada kategori'}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Rp ${product.hargaProduk?.toStringAsFixed(0) ?? '0'}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF5B5B),
                        ),
                      ),
                      const Divider(height: 32),
                      const Text(
                        'Deskripsi Produk',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.deskripsiProduk ?? 'Tidak ada deskripsi.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.namaProduk ?? "Produk"} ditambahkan ke keranjang'),
                    backgroundColor: const Color(0xFFFF5B5B),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5B5B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Add to Cart',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}

