// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_price_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomPriceModel _$RoomPriceModelFromJson(Map<String, dynamic> json) =>
    RoomPriceModel(
      roomCode: json['roomCode'] as String,
      finalPrice: (json['finalPrice'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
    );

Map<String, dynamic> _$RoomPriceModelToJson(RoomPriceModel instance) =>
    <String, dynamic>{
      'roomCode': instance.roomCode,
      'finalPrice': instance.finalPrice,
      'currencyCode': instance.currencyCode,
    };
