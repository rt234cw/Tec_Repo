import 'package:geolocator/geolocator.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationServiceProvider = Provider((ref) => LocationService());

// 定義Result類型處理定位的結果
enum LocationResultType {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

class LocationResult {
  final LocationResultType type;
  final Position? position;
  final String? message;

  LocationResult({required this.type, this.position, this.message});
}

class LocationService {
  Future<LocationResult> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 檢查服務
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationResult(type: LocationResultType.serviceDisabled);
    }

    // 檢查權限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationResult(type: LocationResultType.permissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationResult(type: LocationResultType.permissionDeniedForever);
    }

    // 取得位置
    try {
      // 加入超時避免卡住
      final position = await Geolocator.getCurrentPosition(
        locationSettings: AppleSettings(timeLimit: Duration(seconds: 10)),
      );
      return LocationResult(type: LocationResultType.success, position: position);
    } catch (e) {
      return LocationResult(type: LocationResultType.error, message: e.toString());
    }
  }
}
