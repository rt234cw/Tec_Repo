import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/room_availability.dart';

part 'room_availability_model.g.dart';

@JsonSerializable()
class RoomAvailabilityModel {
  final String roomCode;
  final bool isAvailable;

  const RoomAvailabilityModel({
    required this.roomCode,
    required this.isAvailable,
  });

  factory RoomAvailabilityModel.fromJson(Map<String, dynamic> json) => _$RoomAvailabilityModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomAvailabilityModelToJson(this);

  RoomAvailability toEntity() {
    return RoomAvailability(
      roomCode: roomCode,
      isAvailable: isAvailable,
    );
  }
}
