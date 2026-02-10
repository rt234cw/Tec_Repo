import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/storage/local_storage_provider.dart';
import '../../domain/entities/centre.dart';
import '../../domain/entities/city.dart';
import 'centre_list_provider.dart';
import 'city_list_provider.dart';

final selectedCityProvider = NotifierProvider<SelectedCityNotifier, City?>(() {
  return SelectedCityNotifier();
});

class SelectedCityNotifier extends Notifier<City?> {
  static const _key = 'selected_city';

  @override
  City? build() {
    // 監聽SharedPreferences
    final prefs = ref.watch(sharedPreferencesProvider);

    // 初始化，讀取本地資料
    final jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      try {
        return City.fromJson(jsonDecode(jsonStr));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // 設定並儲存
  Future<void> setAndSaveCity(City city) async {
    state = city;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, jsonEncode(city.toJson()));
  }
}

final nearestCityProvider = FutureProvider.autoDispose<City?>((ref) async {
  // 取得使用者位置
  final locationResult = await ref.read(locationServiceProvider).getCurrentPosition();

  // 如果取得位置失敗(沒開GPS、沒權限、錯誤)，直接回傳null
  if (locationResult.type != LocationResultType.success || locationResult.position == null) {
    // 回傳null顯示通用錯誤
    return null;
  }

  final userPosition = locationResult.position!;

  // 取得所有 Centre 列表
  // 使用.future 確保等待資料載入完成
  final allCentres = await ref.watch(allGlobalCentresProvider.future);

  if (allCentres.isEmpty) {
    return null;
  }

  // 找出距離使用者最近的 Centre
  Centre? nearestCentre;
  double minDistance = double.infinity;

  for (final centre in allCentres) {
    // 排除無效座標
    if ((centre.latitude == 0 && centre.longitude == 0)) {
      continue;
    }

    //  geolocator有提供計算距離的方法
    final distance = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      centre.latitude,
      centre.longitude,
    );

    if (distance < minDistance) {
      minDistance = distance;
      nearestCentre = centre;
    }
  }

  if (nearestCentre == null) {
    return null;
  }

  // 用Centre的cityCode去找對應的city
  final allCities = await ref.watch(cityListProvider.future);

  try {
    final targetCity = allCities.firstWhere(
      (city) => city.code == nearestCentre!.cityCode,
    );
    return targetCity;
  } catch (e) {
    // 找不到對應的城市
    return null;
  }
});
