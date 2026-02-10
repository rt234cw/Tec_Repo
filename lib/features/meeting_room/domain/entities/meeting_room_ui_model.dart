import 'package:equatable/equatable.dart';

import '../../domain/entities/room_info.dart';
import '../../domain/entities/room_availability.dart';
import '../../domain/entities/room_price.dart';
import 'centre.dart';

class MeetingRoomUiModel extends Equatable {
  final RoomInfo info;
  final RoomAvailability? availability;
  final RoomPrice? price;
  final Centre? centre;

  const MeetingRoomUiModel({
    required this.info,
    this.availability,
    this.price,
    this.centre,
  });

  // 判斷是否可預訂
  bool get isBookable => availability?.isAvailable ?? false;

  // 取得顯示價格
  String get displayPrice => price != null ? '${price!.currencyCode} ${price!.finalPrice}' : 'N/A';

  @override
  List<Object?> get props => [info, availability, price];
}
