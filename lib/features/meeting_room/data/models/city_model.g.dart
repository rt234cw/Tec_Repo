// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityModel _$CityModelFromJson(Map<String, dynamic> json) => CityModel(
      id: (json['cityId'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      region: CityModel._readRegionName(json, 'region') as String,
    );

Map<String, dynamic> _$CityModelToJson(CityModel instance) => <String, dynamic>{
      'cityId': instance.id,
      'code': instance.code,
      'name': instance.name,
      'region': instance.region,
    };
