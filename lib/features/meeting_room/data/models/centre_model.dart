import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/centre.dart';

part 'centre_model.g.dart';

@JsonSerializable()
class CentreModel {
  // JSON: "newCentreCodesForMtCore": ["AUH.ADM.01"]
  final List<String> newCentreCodesForMtCore;

  final String id;

  // JSON: "localizedName": { "en": "...", "zhHant": "..." }
  @JsonKey(name: 'localizedName', fromJson: _parseLocalized)
  final String name;

  final String cityCode;
  final bool isDeleted;

  @JsonKey(readValue: _readLat)
  final double latitude;

  @JsonKey(readValue: _readLng)
  final double longitude;

  final String citySlug;

  const CentreModel({
    required this.newCentreCodesForMtCore,
    required this.name,
    required this.id,
    required this.cityCode,
    required this.isDeleted,
    required this.latitude,
    required this.longitude,
    required this.citySlug,
  });

  factory CentreModel.fromJson(Map<String, dynamic> json) => _$CentreModelFromJson(json);

  Map<String, dynamic> toJson() => _$CentreModelToJson(this);

  // 取出英文或預設字串
  static String _parseLocalized(dynamic value) {
    if (value is Map) {
      return value['en']?.toString() ?? value.values.first.toString();
    }
    return '';
  }

  // 解析 Mapbox 座標
  static Object? _readLat(Map map, String key) {
    return map['mapboxCoordinates']?['latitude'] ?? 0.0;
  }

  static Object? _readLng(Map map, String key) {
    return map['mapboxCoordinates']?['longitude'] ?? 0.0;
  }

  Centre toEntity() {
    return Centre(
      id: id,
      name: name,
      cityCode: cityCode,
      newCentreCodesForMtCore: newCentreCodesForMtCore,
      isDeleted: isDeleted,
      longitude: longitude,
      latitude: latitude,
      citySlug: citySlug,
    );
  }
}
