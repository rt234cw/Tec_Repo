import 'package:equatable/equatable.dart';

class RoomAvailability extends Equatable {
  final String roomCode;
  final bool isAvailable;

  const RoomAvailability({required this.roomCode, required this.isAvailable});

  @override
  List<Object?> get props => [roomCode, isAvailable];
}
