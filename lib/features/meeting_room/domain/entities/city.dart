import 'package:equatable/equatable.dart';

class City extends Equatable {
  final int id;
  final String code;
  final String name;
  final String region;

  const City({
    required this.id,
    required this.code,
    required this.name,
    required this.region,
  });

  @override
  List<Object?> get props => [id, code, name, region];

  // 為了存入 SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'region': region,
    };
  }

  // 為了讀取 SharedPreferences
  factory City.fromJson(Map<String, dynamic> map) {
    return City(
      id: map['id'] as int,
      code: map['code'] as String,
      name: map['name'] as String,
      region: map['region'] as String,
    );
  }
}
