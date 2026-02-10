import 'package:equatable/equatable.dart';

class RoomInfo extends Equatable {
  final String roomCode;
  final String roomName;
  final String centreCode;
  final int capacity;
  final List<String> photoUrls;
  final String? floor;
  final bool hasVideoConference;

  const RoomInfo({
    required this.roomCode,
    required this.roomName,
    required this.centreCode,
    required this.capacity,
    required this.photoUrls,
    required this.floor,
    required this.hasVideoConference,
  });

  String get firstImage => photoUrls.isNotEmpty ? photoUrls.first : '';

  @override
  List<Object?> get props => [
        roomCode,
        roomName,
        centreCode,
        capacity,
        photoUrls,
        floor,
        hasVideoConference,
      ];
}
