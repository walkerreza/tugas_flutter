import 'dart:convert';

List<City> cityFromJson(String str) => List<City>.from(json.decode(str).map((x) => City.fromJson(x)));

String cityToJson(List<City> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class City {
    String cityId;
    String provinceId;
    String province;
    String type;
    String cityName;
    String postalCode;

    City({
        required this.cityId,
        required this.provinceId,
        required this.province,
        required this.type,
        required this.cityName,
        required this.postalCode,
    });

    factory City.fromJson(Map<String, dynamic> json) => City(
        cityId: json["city_id"],
        provinceId: json["province_id"],
        province: json["province"],
        type: json["type"],
        cityName: json["city_name"],
        postalCode: json["postal_code"],
    );

    Map<String, dynamic> toJson() => {
        "city_id": cityId,
        "province_id": provinceId,
        "province": province,
        "type": type,
        "city_name": cityName,
        "postal_code": postalCode,
    };

    @override
    String toString() => '$type $cityName';
}
