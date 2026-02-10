import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/centre_model.dart';
import '../models/city_model.dart';
import '../models/room_availability_model.dart';
import '../models/room_info_model.dart';
import '../models/room_price_model.dart';

final meetingRoomRemoteDataSourceProvider = Provider<MeetingRoomRemoteDataSource>((ref) {
  // 讀取全域的 dioProvider
  final dio = ref.watch(dioProvider);
  return MeetingRoomRemoteDataSourceImpl(dio);
});

abstract class MeetingRoomRemoteDataSource {
  Future<List<CityModel>> getCities({int pageNumber = 1, int pageSize = 100});

  Future<List<RoomAvailabilityModel>> getAvailabilities({
    required String cityCode,
    required String startDate,
    required String endDate,
  });

  Future<List<RoomInfoModel>> getRoomInfo({required String cityCode});

  Future<List<RoomPriceModel>> getRoomPrices({
    required String cityCode,
    required String startDate,
    required String endDate,
  });

  Future<List<CentreModel>> getCentreGroups();
}

class MeetingRoomRemoteDataSourceImpl implements MeetingRoomRemoteDataSource {
  final Dio _dio;

  MeetingRoomRemoteDataSourceImpl(this._dio);

  @override
  Future<List<CityModel>> getCities({int pageNumber = 1, int pageSize = 100}) async {
    final response = await _dio.get(
      '/core-api/api/v1/cities',
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    // 在這裡處理轉換邏輯
    final data = response.data;
    final List list = (data is Map && data.containsKey('items')) ? data['items'] : data;
    return list.map((e) => CityModel.fromJson(e)).toList();
  }

  @override
  Future<List<RoomAvailabilityModel>> getAvailabilities({
    required String cityCode,
    required String startDate,
    required String endDate,
  }) async {
    final response = await _dio.get(
      '/core-api-me/api/v1/meetingrooms/availabilities',
      queryParameters: {
        'cityCode': cityCode,
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    return (response.data as List).map((e) => RoomAvailabilityModel.fromJson(e)).toList();
  }

  @override
  Future<List<RoomInfoModel>> getRoomInfo({required String cityCode}) async {
    List<RoomInfoModel> allRooms = [];
    int currentPage = 1;
    int totalPages = 1;

    // 自動翻頁迴圈
    do {
      final response = await _dio.get(
        '/core-api-me/api/v1/meetingrooms',
        queryParameters: {
          'pageSize': 100, // 按postman實測，正常是一頁就能全部讀完了
          'pageNumber': currentPage,
          'cityCode': cityCode, // 只抓這個城市的房間
        },
      );

      final data = response.data;
      final items = data['items'] as List;
      allRooms.addAll(items.map((e) => RoomInfoModel.fromJson(e)));
      totalPages = data['pageCount'] ?? 1;
      currentPage++;
    } while (currentPage <= totalPages);

    return allRooms;
  }

  @override
  Future<List<RoomPriceModel>> getRoomPrices({
    required String cityCode,
    required String startDate,
    required String endDate,
  }) async {
    final response = await _dio.get(
      '/core-api-me/api/v1/meetingrooms/pricings',
      queryParameters: {
        'cityCode': cityCode,
        'startDate': startDate,
        'endDate': endDate,
        'isVcBooking': 'true',
        'profileId': '{{ProfileId}}',
      },
    );
    return (response.data as List).map((e) => RoomPriceModel.fromJson(e)).toList();
  }

  @override
  Future<List<CentreModel>> getCentreGroups() async {
    final response = await _dio.get('/core-api-me/api/v1/centregroups');
    return (response.data as List).map((e) => CentreModel.fromJson(e)).toList();
  }
}
