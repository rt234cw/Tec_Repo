import 'package:tec/features/meeting_room/domain/entities/centre.dart';
import 'package:tec/features/meeting_room/domain/entities/room_availability.dart';
import 'package:tec/features/meeting_room/domain/entities/room_price.dart';

import '../entities/city.dart';
import '../entities/room_info.dart';

abstract class MeetingRoomRepository {
  Future<List<City>> getCities({int pageNumber, int pageSize});

  Future<List<RoomAvailability>> getAvailabilities({
    required String cityCode,
    required String startDate,
    required String endDate,
  });

  Future<List<RoomInfo>> getMeetingRooms({
    required String cityCode,
  });

  Future<List<RoomPrice>> getRoomPrices({
    required String cityCode,
    required String startDate,
    required String endDate,
  });

  /// 因為get centres api沒辦法只選特定城市，一次回傳全世界的資料
  /// 所以要先fetch全部之後，再按cityCode挑選特定城市
  /// [fetchCentresByCity] 就是要篩選特定城市
  Future<List<Centre>> getCentreGroups();

  Future<List<Centre>> fetchCentresByCity({required String cityCode});
}
