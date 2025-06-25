import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../alamat_page.dart';
import '../../model/keranjang_model.dart';
import 'LihatPesanan.dart';
import '../../model/alamat_model.dart';
import '../../services/alamat_service.dart';
import '../../model/rekening.dart';
import '../../services/rekening_service.dart';

class CheckoutPage extends StatefulWidget {
  final List<KeranjangItem> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final AlamatService _alamatService = AlamatService();
  Alamat? _alamat;
  bool _isAlamatLoading = true;
  String? _alamatError;

  final RekeningService _rekeningService = RekeningService();
  List<RekeningModel> _rekeningList = [];
  bool _isRekeningLoading = true;
  String? _rekeningError;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  bool _isLoading = false;
  String _selectedMetode = 'lunas';

  // Biaya pengiriman bisa dibuat dinamis nanti
  final double _shippingCost = 46000;

  double get _subtotal =>
      widget.cartItems.fold(0.0, (sum, item) => sum + (item.hargaProduk * item.quantity));
  double get _grandTotal => _subtotal + _shippingCost;
  double get _dpAmount => _grandTotal * 0.5;

  @override
  void initState() {
    super.initState();
    _fetchAlamat();
    _fetchRekening();
  }

  Future<void> _fetchAlamat() async {
    setState(() {
      _isAlamatLoading = true;
      _alamatError = null;
    });
    try {
      final alamat = await _alamatService.getAlamat();
      setState(() {
        _alamat = alamat;
        _isAlamatLoading = false;
      });
    } catch (e) {
      setState(() {
        _alamatError = "Gagal memuat alamat. Silakan coba lagi.";
        _isAlamatLoading = false;
      });
    }
  }

  Future<void> _fetchRekening() async {
    setState(() {
      _isRekeningLoading = true;
      _rekeningError = null;
    });
    try {
      final rekening = await _rekeningService.getRekening();
      setState(() {
        _rekeningList = rekening;
        _isRekeningLoading = false;
      });
    } catch (e) {
      setState(() {
        _rekeningError = "Gagal memuat rekening. Silakan coba lagi.";
        _isRekeningLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadOrder() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih bukti pembayaran terlebih dahulu.')),
      );
      return;
    }

    if (widget.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang Anda kosong.')),
      );
      return;
    }

    if (_alamat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat pengiriman belum diatur.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final token = prefs.getString('token');

    if (userId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User tidak ditemukan. Silakan login ulang.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final firstItem = widget.cartItems.first;

    var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/customer/pesanan/store'));

    // Menambahkan headers untuk otentikasi
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields.addAll({
      'id_keranjang': firstItem.idKeranjang.toString(),
      'id_produk': firstItem.idProduk.toString(),
      'id_user': userId.toString(),
      'id_alamat': _alamat!.id.toString(),
      'quantity': firstItem.quantity.toString(),
      'harga_produk': (firstItem.hargaProduk * firstItem.quantity).toString(),
      'ongkir': _shippingCost.toString(),
      'total_harga': (firstItem.hargaProduk * firstItem.quantity).toString(),
      'total_bayar': _grandTotal.toString(),
      'metode': _selectedMetode,
      'dp': _selectedMetode == 'dp' ? _dpAmount.toString() : '0',
    });

    request.files.add(await http.MultipartFile.fromPath('bukti_bayar', _imageFile!.path));

    try {
      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();
      // Mencetak body mentah untuk debugging
      print('DEBUG: Upload response body: $responseBody');
      final decodedBody = json.decode(responseBody);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibuat!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Lihatpesanan()),
          (Route<dynamic> route) => false,
        );
      } else {
        final errors = decodedBody['errors'] as Map<String, dynamic>?;
        String errorMessage = decodedBody['message'] ?? 'Gagal membuat pesanan.';
        if (errors != null && errors.isNotEmpty) {
          errorMessage = errors.values.map((e) => e.join('\n')).join('\n');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.blue[600],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOrderSummaryCard(),
            const SizedBox(height: 16),
            _buildShippingAddressCard(),
            const SizedBox(height: 16),
            _buildPaymentAccountsCard(),
            const SizedBox(height: 16),
            _buildUploadCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: const TextStyle(fontSize: 15))),
          Text(value,
              style: TextStyle(
                  fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sekilas Pesanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...widget.cartItems
                .map((item) => _buildInfoRow(
                    '${item.namaProduk} (x${item.quantity})',
                    currencyFormatter.format(item.hargaProduk * item.quantity)))
                ,
            const Divider(height: 24),
            _buildInfoRow('Subtotal', currencyFormatter.format(_subtotal)),
            _buildInfoRow('Berat Produk', '12 Gram'), // TODO: Buat dinamis
            _buildInfoRow('Pengiriman (Ongkir)', currencyFormatter.format(_shippingCost)),
            _buildInfoRow('Estimasi Tiba', '3-4 Hari'), // TODO: Buat dinamis
            const Divider(height: 24),
            _buildInfoRow('Total', currencyFormatter.format(_grandTotal), isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddressCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alamat Pengiriman',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_isAlamatLoading)
              const Center(child: CircularProgressIndicator())
            else if (_alamatError != null)
              Center(
                child: Column(
                  children: [
                    Text(_alamatError!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _fetchAlamat,
                      child: const Text('Coba Lagi'),
                    )
                  ],
                ),
              )
            else if (_alamat == null)
              const Center(child: Text('Alamat pengiriman belum diatur.'))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama Penerima: ${_alamat!.namaPenerima}'),
                  Text('Alamat: ${_alamat!.alamatLengkap}, ${_alamat!.namaKota}, ${_alamat!.namaProv}, ${_alamat!.kodePos}'),
                  Text('Nomor Telp: ${_alamat!.noTelp}'),
                ],
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AlamatPage()));
                  _fetchAlamat();
                },
                child: const Text('Ubah Alamat →'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentAccountsCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rekening Pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_isRekeningLoading)
              const Center(child: CircularProgressIndicator())
            else if (_rekeningError != null)
              Center(
                child: Column(
                  children: [
                    Text(_rekeningError!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _fetchRekening,
                      child: const Text('Coba Lagi'),
                    )
                  ],
                ),
              )
            else if (_rekeningList.isEmpty)
              const Center(child: Text('Tidak ada data rekening tersedia.'))
            else
              ..._rekeningList.map((rekening) => _buildRekeningTile(
                  rekening.jenisBank, rekening.namaPemilik, rekening.nomorRekening)),
          ],
        ),
      ),
    );
  }

  Widget _buildRekeningTile(String bank, String nama, String nomor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Image.asset('images/$bank.png', height: 25,
          errorBuilder: (c, o, s) => const Icon(Icons.business, size: 25)),
      title: Text('Nama Rekening: $nama',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Nomor Rekening: $nomor'),
    );
  }

  Widget _buildUploadCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload Bukti Bayar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _imageFile == null
                ? Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(child: Text('No Image Available')),
                  )
                : Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              items: [
                DropdownMenuItem(
                    value: 'lunas',
                    child: Text(
                        'Lunas [ Tagihan: ${currencyFormatter.format(_grandTotal)} ]')),
                DropdownMenuItem(
                    value: 'dp',
                    child: Text(
                        'DP 50% [ Tagihan: ${currencyFormatter.format(_dpAmount)} ]')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMetode = value;
                  });
                }
              },
              value: _selectedMetode,
              decoration: const InputDecoration(
                  labelText: 'Jenis Transaksi', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Choose File'),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _uploadOrder,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Upload Bukti Pembayaran',
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
