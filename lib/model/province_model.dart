import 'dart:convert';

List<Province> provinceFromJson(String str) => List<Province>.from(json.decode(str).map((x) => Province.fromJson(x)));

String provinceToJson(List<Province> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Province {
    String provinceId;
    String province;

    Province({
        required this.provinceId,
        required this.province,
    });

    factory Province.fromJson(Map<String, dynamic> json) => Province(
        provinceId: json["province_id"],
        province: json["province"],
    );

    Map<String, dynamic> toJson() => {
        "province_id": provinceId,
        "province": province,
    };

    @override
    String toString() => province;
}
