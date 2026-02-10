// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_availability_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomAvailabilityModel _$RoomAvailabilityModelFromJson(
        Map<String, dynamic> json) =>
    RoomAvailabilityModel(
      roomCode: json['roomCode'] as String,
      isAvailable: json['isAvailable'] as bool,
    );

Map<String, dynamic> _$RoomAvailabilityModelToJson(
        RoomAvailabilityModel instance) =>
    <String, dynamic>{
      'roomCode': instance.roomCode,
      'isAvailable': instance.isAvailable,
    };
