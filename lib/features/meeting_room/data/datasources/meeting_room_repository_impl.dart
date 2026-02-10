import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tec/features/meeting_room/domain/entities/room_availability.dart';
import '../../domain/entities/centre.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/room_info.dart';
import '../../domain/entities/room_price.dart';
import '../../domain/repositories/meeting_room_repository.dart';
import 'meeting_room_remote_source_impl.dart';

final meetingRoomRepositoryProvider = Provider<MeetingRoomRepository>((ref) {
  final remoteDataSource = ref.watch(meetingRoomRemoteDataSourceProvider);
  return MeetingRoomRepositoryImpl(
    remoteDataSource,
  );
});

class MeetingRoomRepositoryImpl implements MeetingRoomRepository {
  final MeetingRoomRemoteDataSource _remoteDataSource;

  MeetingRoomRepositoryImpl(
    this._remoteDataSource,
  );

  @override
  Future<List<City>> getCities({int pageNumber = 1, int pageSize = 100}) async {
    final models = await _remoteDataSource.getCities(pageNumber: pageNumber, pageSize: pageSize);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<RoomAvailability>> getAvailabilities({
    required String cityCode,
    required String startDate,
    required String endDate,
  }) async {
    final models = await _remoteDataSource.getAvailabilities(
      cityCode: cityCode,
      startDate: startDate,
      endDate: endDate,
    );

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<RoomInfo>> getMeetingRooms({required String cityCode}) async {
    final models = await _remoteDataSource.getRoomInfo(cityCode: cityCode);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<RoomPrice>> getRoomPrices({
    required String cityCode,
    required String startDate,
    required String endDate,
  }) async {
    final models = await _remoteDataSource.getRoomPrices(
      cityCode: cityCode,
      startDate: startDate,
      endDate: endDate,
    );

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Centre>> getCentreGroups() async {
    final models = await _remoteDataSource.getCentreGroups();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Centre>> fetchCentresByCity({required String cityCode}) async {
    final all = await getCentreGroups();
    final filtered = all.where((c) {
      final matchesCity = c.cityCode == cityCode;
      final valid = c.isDeleted == false;
      return matchesCity && valid;
    }).toList();

    return filtered;
  }
}
