import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/city.dart';

part 'city_model.g.dart';

@JsonSerializable()
class CityModel {
  @JsonKey(name: 'cityId')
  final int id;

  final String code;
  final String name;

  // 使用readValue提取nested的region name
  @JsonKey(readValue: _readRegionName)
  final String region;

  const CityModel({
    required this.id,
    required this.code,
    required this.name,
    required this.region,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) => _$CityModelFromJson(json);

  Map<String, dynamic> toJson() => _$CityModelToJson(this);

  City toEntity() {
    return City(
      id: id,
      code: code,
      name: name,
      region: region,
    );
  }

  // 從JSON結構中取出需要的字串
  static Object? _readRegionName(Map map, String key) {
    try {
      // JSON 結構: "region": { "name": { "en": "Greater China" } }
      final regionData = map['region'];
      if (regionData is Map) {
        final nameData = regionData['name'];
        if (nameData is Map) {
          return nameData['en']?.toString() ?? 'Other';
        }
      }
      return 'Other';
    } catch (e) {
      return 'Other';
    }
  }
}
