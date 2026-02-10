import 'package:equatable/equatable.dart';

class RoomPrice extends Equatable {
  final String roomCode;
  final double finalPrice;
  final String currencyCode;

  const RoomPrice({
    required this.roomCode,
    required this.finalPrice,
    required this.currencyCode,
  });

  @override
  List<Object?> get props => [
        roomCode,
        finalPrice,
        currencyCode,
      ];
}
