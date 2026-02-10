import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/meeting_room_repository_impl.dart';
import '../../domain/entities/city.dart';

final cityListProvider = AsyncNotifierProvider<CityListNotifier, List<City>>(() {
  return CityListNotifier();
});

class CityListNotifier extends AsyncNotifier<List<City>> {
  @override
  Future<List<City>> build() async {
    final repository = ref.read(meetingRoomRepositoryProvider);
    return await repository.getCities();
  }
}
