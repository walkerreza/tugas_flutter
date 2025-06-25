import 'dart:convert';

List<KeranjangItem> keranjangFromJson(String str) => List<KeranjangItem>.from(json.decode(str).map((x) => KeranjangItem.fromJson(x)));

String keranjangToJson(List<KeranjangItem> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class KeranjangItem {
    int idKeranjang;
    int idUser;
    int idProduk;
    int quantity;
    DateTime? createdAt;
    DateTime? updatedAt;
    String namaProduk;
    int hargaProduk;
    String fotoProduk;
    String namaKategori;

    KeranjangItem({
        required this.idKeranjang,
        required this.idUser,
        required this.idProduk,
        required this.quantity,
        this.createdAt,
        this.updatedAt,
        required this.namaProduk,
        required this.hargaProduk,
        required this.fotoProduk,
        required this.namaKategori,
    });

    factory KeranjangItem.fromJson(Map<String, dynamic> json) => KeranjangItem(
        idKeranjang: json["id_keranjang"],
        idUser: json["id_user"],
        idProduk: json["id_produk"],
        quantity: json["quantity"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        namaProduk: json["nama_produk"],
        hargaProduk: json["harga_produk"],
        fotoProduk: json["foto_produk"],
        namaKategori: json["nama_kategori"],
    );

    Map<String, dynamic> toJson() => {
        "id_keranjang": idKeranjang,
        "id_user": idUser,
        "id_produk": idProduk,
        "quantity": quantity,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "nama_produk": namaProduk,
        "harga_produk": hargaProduk,
        "foto_produk": fotoProduk,
        "nama_kategori": namaKategori,
    };
}
