import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/centre.dart';
import '../../data/datasources/meeting_room_repository_impl.dart';
import 'selected_city_provider.dart';

final centreListProvider = AsyncNotifierProvider<CentreListNotifier, List<Centre>>(() {
  return CentreListNotifier();
});

class CentreListNotifier extends AsyncNotifier<List<Centre>> {
  @override
  Future<List<Centre>> build() async {
    // 監聽選中的城市
    final selectedCity = ref.watch(selectedCityProvider);

    // 決定要篩選的 City Code
    // 如果有存過就用存的，沒有存過就預設 'HKG'
    final targetCityCode = selectedCity?.code ?? 'HKG';

    final repository = ref.read(meetingRoomRepositoryProvider);

    return await repository.fetchCentresByCity(cityCode: targetCityCode);
  }

  // 支援手動刷新
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final allGlobalCentresProvider = FutureProvider<List<Centre>>((ref) async {
  final repository = ref.read(meetingRoomRepositoryProvider);
  final allCentres = await repository.getCentreGroups();

  // 過濾掉已刪除的據點
  return allCentres.where((c) => c.isDeleted == false).toList();
});
