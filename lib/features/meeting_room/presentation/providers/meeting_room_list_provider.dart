import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../data/datasources/meeting_room_repository_impl.dart';
import '../../domain/entities/meeting_room_ui_model.dart';
import '../../domain/entities/room_info.dart';
import '../../domain/entities/room_availability.dart';
import '../../domain/entities/room_price.dart';
import 'selected_city_provider.dart';
import 'filter_provider.dart';
import 'centre_list_provider.dart';

final meetingRoomListProvider = FutureProvider.autoDispose<List<MeetingRoomUiModel>>((ref) async {
  // 監聽 City
  final city = ref.watch(selectedCityProvider);
  if (city == null) return [];

  // 監聽 Centre List (用來做 ID -> Code 的對照表)
  // valueOrNull 確保還沒載入時給空陣列，避免報錯
  final centres = ref.watch(centreListProvider).valueOrNull ?? [];

  // 監聽 Filter
  final filter = ref.watch(filterProvider);

  // 4. 準備 API 參數 (時間格式化)
  final startDateTime = DateTime(
    filter.date.year,
    filter.date.month,
    filter.date.day,
    filter.startTime.hour,
    filter.startTime.minute,
  );

  final endDateTime = DateTime(
    filter.date.year,
    filter.date.month,
    filter.date.day,
    filter.endTime.hour,
    filter.endTime.minute,
  );

  final startDateStr = startDateTime.toIso8601String();
  final endDateStr = endDateTime.toIso8601String();

  final repository = ref.watch(meetingRoomRepositoryProvider);

  // 並行呼叫 API
  final results = await Future.wait([
    // A. 取得該城市的所有房間
    repository.getMeetingRooms(cityCode: city.code),

    // B. 取得可用性
    repository.getAvailabilities(
      cityCode: city.code,
      startDate: startDateStr,
      endDate: endDateStr,
    ),

    // C. 取得價格
    repository.getRoomPrices(
      cityCode: city.code,
      startDate: startDateStr,
      endDate: endDateStr,
    ),
  ]);

  final allRooms = results[0] as List<RoomInfo>;
  final availabilities = results[1] as List<RoomAvailability>;
  final prices = results[2] as List<RoomPrice>;

  // 轉換成 Map 加速查找
  final availabilityMap = {for (var item in availabilities) item.roomCode: item};
  final priceMap = {for (var item in prices) item.roomCode: item};

  // 目標：把使用者選的 ID (如 a3KB...) 轉換成房間的 Code (如 TPE.NAN.01)
  Set<String> allowedCentreCodes = {};

  if (filter.selectedCentreIds.isNotEmpty) {
    // A. 從 Centre List 中，找出使用者選中的那些 Centre 物件
    final selectedCentres = centres.where((c) => filter.selectedCentreIds.contains(c.id));

    // B. 取出它們的 newCentreCodesForMtCore (這才是 API 回傳房間時用的代碼)
    for (var centre in selectedCentres) {
      allowedCentreCodes.addAll(centre.newCentreCodesForMtCore);
    }
  }

  final uiList = <MeetingRoomUiModel>[];

  for (final room in allRooms) {
    // 篩選人數 (Capacity)
    if (room.capacity < filter.minCapacity) {
      continue;
    }

    // 中心篩選邏輯 (比對 Codes 而不是 ID)
    if (filter.selectedCentreIds.isNotEmpty) {
      if (!allowedCentreCodes.contains(room.centreCode)) {
        continue;
      }
    }

    // 篩選video conference
    if (filter.isVideoConference && !room.hasVideoConference) {
      continue;
    }

    /// 資料關聯mapping
    /// 找出這間房間所屬的Centre，用於顯示名字
    final matchedCentre =
        centres.firstWhereOrNull((centre) => centre.newCentreCodesForMtCore.contains(room.centreCode));

    uiList.add(MeetingRoomUiModel(
      info: room,
      availability: availabilityMap[room.roomCode],
      price: priceMap[room.roomCode],
      centre: matchedCentre,
    ));
  }

  return uiList;
});
