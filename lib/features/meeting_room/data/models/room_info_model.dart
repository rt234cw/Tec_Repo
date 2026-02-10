import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/room_info.dart';

part 'room_info_model.g.dart';

@JsonSerializable()
class RoomInfoModel {
  final String roomCode;
  final String roomName;
  final String centreCode; // 用來關聯Centre Model
  final int capacity;
  final List<String> photoUrls;
  final String? floor;
  final bool hasVideoConference;

  const RoomInfoModel({
    required this.roomCode,
    required this.roomName,
    required this.centreCode,
    required this.capacity,
    required this.photoUrls,
    required this.floor,
    required this.hasVideoConference,
  });

  factory RoomInfoModel.fromJson(Map<String, dynamic> json) => _$RoomInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomInfoModelToJson(this);

  RoomInfo toEntity() {
    return RoomInfo(
      roomCode: roomCode,
      roomName: roomName,
      centreCode: centreCode,
      capacity: capacity,
      photoUrls: photoUrls,
      floor: floor,
      hasVideoConference: hasVideoConference,
    );
  }
}
