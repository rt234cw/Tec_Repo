import 'package:equatable/equatable.dart';

class Centre extends Equatable {
  final String id;
  final String name;
  final String cityCode;

  final List<String> newCentreCodesForMtCore;
  final bool isDeleted;
  final double latitude;
  final double longitude;
  final String citySlug;

  const Centre({
    required this.id,
    required this.name,
    required this.cityCode,
    required this.newCentreCodesForMtCore,
    required this.isDeleted,
    required this.latitude,
    required this.longitude,
    required this.citySlug,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        cityCode,
        newCentreCodesForMtCore,
        isDeleted,
        latitude,
        longitude,
        citySlug,
      ];
}
