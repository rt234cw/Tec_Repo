import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tec/core/theme/app_colors.dart';
import '../../domain/entities/city.dart';
import 'city_list_provider.dart';
import 'selected_city_provider.dart';

// 定義 UI State
class CitySelectionState {
  final List<DropdownMenuEntry<City?>> menuEntries;
  final City? tempSelectedCity;

  CitySelectionState({
    required this.menuEntries,
    this.tempSelectedCity,
  });

  CitySelectionState copyWith({
    List<DropdownMenuEntry<City?>>? menuEntries,
    City? tempSelectedCity,
  }) {
    return CitySelectionState(
      menuEntries: menuEntries ?? this.menuEntries,
      tempSelectedCity: tempSelectedCity ?? this.tempSelectedCity,
    );
  }
}

class CitySelectionNotifier extends AutoDisposeNotifier<CitySelectionState> {
  List<City> _allCities = [];

  @override
  CitySelectionState build() {
    // 初始載入 City List
    final cityListAsync = ref.watch(cityListProvider);
    final currentSelected = ref.read(selectedCityProvider);

    cityListAsync.whenData((cities) {
      _allCities = cities;
    });

    // 初始生成 Menu Entries
    final entries = _generateMenuEntries(_allCities, '');

    return CitySelectionState(
      menuEntries: entries,
      tempSelectedCity: currentSelected,
    );
  }

  // 設定搜尋關鍵字
  void onSearchChanged(String query) {
    if (_allCities.isEmpty) return;
    final newEntries = _generateMenuEntries(_allCities, query);
    state = state.copyWith(menuEntries: newEntries);
  }

  // 設定暫存城市
  void selectCity(City? city) {
    state = state.copyWith(tempSelectedCity: city);
  }

  // 儲存並關閉
  Future<void> saveSelection() async {
    if (state.tempSelectedCity != null) {
      await ref.read(selectedCityProvider.notifier).setAndSaveCity(state.tempSelectedCity!);
    }
  }

  List<DropdownMenuEntry<City?>> _generateMenuEntries(List<City> cities, String query) {
    final lowerQuery = query.toLowerCase();
    final filteredCities = cities.where((city) => city.name.toLowerCase().contains(lowerQuery)).toList();

    final groupedCities = <String, List<City>>{};
    for (var city in filteredCities) {
      if (!groupedCities.containsKey(city.region)) {
        groupedCities[city.region] = [];
      }
      groupedCities[city.region]!.add(city);
    }

    final newEntries = <DropdownMenuEntry<City?>>[];
    for (var region in groupedCities.keys) {
      newEntries.add(
        DropdownMenuEntry<City?>(
          value: null,
          label: region,
          enabled: false,
          style: MenuItemButton.styleFrom(
            disabledBackgroundColor: AppColors.selectedBackground,
            disabledForegroundColor: AppColors.textPrimary,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          ),
        ),
      );
      for (var city in groupedCities[region]!) {
        newEntries.add(
          DropdownMenuEntry<City?>(
            value: city,
            label: city.name,
            style: MenuItemButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
          ),
        );
      }
    }

    if (newEntries.isEmpty) {
      newEntries.add(const DropdownMenuEntry<City?>(
        value: null,
        label: 'No cities found',
        enabled: false,
      ));
    }
    return newEntries;
  }
}

final citySelectionProvider = NotifierProvider.autoDispose<CitySelectionNotifier, CitySelectionState>(() {
  return CitySelectionNotifier();
});
