// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'centre_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CentreModel _$CentreModelFromJson(Map<String, dynamic> json) => CentreModel(
      newCentreCodesForMtCore:
          (json['newCentreCodesForMtCore'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      name: CentreModel._parseLocalized(json['localizedName']),
      id: json['id'] as String,
      cityCode: json['cityCode'] as String,
      isDeleted: json['isDeleted'] as bool,
      latitude: (CentreModel._readLat(json, 'latitude') as num).toDouble(),
      longitude: (CentreModel._readLng(json, 'longitude') as num).toDouble(),
      citySlug: json['citySlug'] as String,
    );

Map<String, dynamic> _$CentreModelToJson(CentreModel instance) =>
    <String, dynamic>{
      'newCentreCodesForMtCore': instance.newCentreCodesForMtCore,
      'id': instance.id,
      'localizedName': instance.name,
      'cityCode': instance.cityCode,
      'isDeleted': instance.isDeleted,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'citySlug': instance.citySlug,
    };
