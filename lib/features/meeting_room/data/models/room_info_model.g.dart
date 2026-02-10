// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomInfoModel _$RoomInfoModelFromJson(Map<String, dynamic> json) =>
    RoomInfoModel(
      roomCode: json['roomCode'] as String,
      roomName: json['roomName'] as String,
      centreCode: json['centreCode'] as String,
      capacity: (json['capacity'] as num).toInt(),
      photoUrls:
          (json['photoUrls'] as List<dynamic>).map((e) => e as String).toList(),
      floor: json['floor'] as String?,
      hasVideoConference: json['hasVideoConference'] as bool,
    );

Map<String, dynamic> _$RoomInfoModelToJson(RoomInfoModel instance) =>
    <String, dynamic>{
      'roomCode': instance.roomCode,
      'roomName': instance.roomName,
      'centreCode': instance.centreCode,
      'capacity': instance.capacity,
      'photoUrls': instance.photoUrls,
      'floor': instance.floor,
      'hasVideoConference': instance.hasVideoConference,
    };
