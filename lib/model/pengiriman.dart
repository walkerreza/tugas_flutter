import 'dart:convert';

List<Pesanan> pesananFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> dataList = jsonData is List ? jsonData : [jsonData];

  final List<Pesanan> pesananList = [];
  for (var item in dataList) {
    try {
      if (item is Map<String, dynamic> && item['id_pesanan'] != null) {
        pesananList.add(Pesanan.fromJson(item));
      }
    } catch (e, stacktrace) {
      // Jika terjadi error saat parsing satu item, item tersebut akan dilewati.
      // Ini diaktifkan untuk debugging.
      print('Gagal mem-parsing item pesanan: $e');
      print('Stacktrace: $stacktrace');
    }
  }
  return pesananList;
}

class Pesanan {
    final int idPesanan;
    final String? namaProduk;
    final String? fotoProduk;
    final int? quantity;
    final int? totalOngkir;
    final String? namaPenerima;
    final String? namaKota;
    final String? namaProv;
    final int? status;
    final DateTime? tanggalOrder;
    final String? invoice;

    Pesanan({
        required this.idPesanan,
        this.namaProduk,
        this.fotoProduk,
        this.quantity,
        this.totalOngkir,
        this.namaPenerima,
        this.namaKota,
        this.namaProv,
        this.status,
        this.tanggalOrder,
        this.invoice,
    });

    factory Pesanan.fromJson(Map<String, dynamic> json) {
      return Pesanan(
        idPesanan: json["id_pesanan"],
        namaProduk: json["nama_produk"],
        fotoProduk: json["foto_produk"],
        quantity: json["quantity"],
        totalOngkir: json["total_ongkir"],
        namaPenerima: json["nama_penerima"],
        namaKota: json["nama_kota"],
        namaProv: json["nama_prov"],
        // PENTING: Mengubah status dari String ke int dengan aman
        status: int.tryParse(json["status"]?.toString() ?? ''),
        // Menggunakan updated_at untuk tanggal terakhir, lebih relevan
        tanggalOrder: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        // Mengisi invoice dengan ID untuk referensi
        invoice: json["id_pesanan"]?.toString(),
      );
    }

    String getStatusString() {
      switch (status) {
        case 1:
          return 'Menunggu Konfirmasi';
        case 2:
          return 'Diproses';
        case 3:
          return 'Dikirim';
        case 4:
          return 'Selesai';
        case 0:
          return 'Dibatalkan';
        default:
          return 'Unknown';
      }
    }
}
