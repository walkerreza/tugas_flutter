class RekeningModel {
  final int idRekening;
  final String namaPemilik;
  final String jenisBank;
  final String nomorRekening;
  final String? createdAt;
  final String? updatedAt;

  RekeningModel({
    required this.idRekening,
    required this.namaPemilik,
    required this.jenisBank,
    required this.nomorRekening,
    this.createdAt,
    this.updatedAt,
  });

  factory RekeningModel.fromJson(Map<String, dynamic> json) {
    return RekeningModel(
      idRekening: json['id_rekening'],
      namaPemilik: json['nama_pemilik'],
      jenisBank: json['jenis_bank'],
      nomorRekening: json['nomor_rekening'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
