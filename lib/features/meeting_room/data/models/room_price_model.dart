import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/room_price.dart';

part 'room_price_model.g.dart';

@JsonSerializable()
class RoomPriceModel {
  final String roomCode;
  final double finalPrice;
  final String currencyCode;

  const RoomPriceModel({
    required this.roomCode,
    required this.finalPrice,
    required this.currencyCode,
  });

  factory RoomPriceModel.fromJson(Map<String, dynamic> json) => _$RoomPriceModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomPriceModelToJson(this);

  RoomPrice toEntity() {
    return RoomPrice(
      roomCode: roomCode,
      finalPrice: finalPrice,
      currencyCode: currencyCode,
    );
  }
}
