import 'dart:convert';

Alamat alamatFromJson(String str) => Alamat.fromJson(json.decode(str));

String alamatToJson(Alamat data) => json.encode(data.toJson());

class Alamat {
    int? id;
    int? idUser;
    String noTelp;
    String namaPenerima;
    String idProvinsi;
    String namaProv;
    String idKota;
    String namaKota;
    String kodePos;
    String alamatLengkap;
    DateTime? createdAt;
    DateTime? updatedAt;

    Alamat({
        this.id,
        this.idUser,
        required this.noTelp,
        required this.namaPenerima,
        required this.idProvinsi,
        required this.namaProv,
        required this.idKota,
        required this.namaKota,
        required this.kodePos,
        required this.alamatLengkap,
        this.createdAt,
        this.updatedAt,
    });

    factory Alamat.fromJson(Map<String, dynamic> json) {
        return Alamat(
                        id: json["id_alamat"],
            idUser: json["id_user"],
            noTelp: json["no_telp"],
            namaPenerima: json["nama_penerima"],
            idProvinsi: json["id_provinsi"].toString(),
            namaProv: json["nama_prov"],
            idKota: json["id_kota"].toString(),
            namaKota: json["nama_kota"],
            kodePos: json["kode_pos"],
            alamatLengkap: json["alamat_lengkap"],
            createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
            updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        );
    }

    Map<String, dynamic> toJson() {
        return {
            // 'id' is included for updates. The backend will ignore it for creates.
            "id": id,
            // 'id_user' is not sent; the backend uses the authenticated user.
            "no_telp": noTelp,
            "nama_penerima": namaPenerima,
            "id_provinsi": idProvinsi,
            "nama_prov": namaProv,
            "id_kota": idKota,
            "nama_kota": namaKota,
            "kode_pos": kodePos,
            "alamat_lengkap": alamatLengkap,
        };
    }
    // Untuk mengirim data ke API
    Map<String, String> toApiMap() => {
        "no_telp": noTelp,
        "nama_penerima": namaPenerima,
        "id_provinsi": idProvinsi,
        "nama_prov": namaProv,
        "id_kota": idKota,
        "nama_kota": namaKota,
        "kode_pos": kodePos,
        "alamat_lengkap": alamatLengkap,
    };
}
