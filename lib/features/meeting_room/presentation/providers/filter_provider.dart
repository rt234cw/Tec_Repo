import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tec/core/extensions/localization_extension.dart';
import 'package:tec/core/extensions/string_extension.dart';
import 'package:tec/features/meeting_room/domain/entities/centre.dart';

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});

// 定義篩選狀態的資料結構
class FilterState {
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int minCapacity;
  final List<String> selectedCentreIds; // 這是UI選項的唯一識別符
  final bool isVideoConference;

  const FilterState({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.minCapacity,
    required this.selectedCentreIds,
    this.isVideoConference = false,
  });

  // 預設值
  factory FilterState.initial() {
    final now = DateTime.now();

    int minute = now.minute;
    int remainder = minute % 15;
    int addMinutes = 15 - remainder;
    final startDt = now.add(Duration(minutes: addMinutes));
    // 修正秒數歸零
    final cleanStartDt = DateTime(startDt.year, startDt.month, startDt.day, startDt.hour, startDt.minute);

    // 計算 End Time (Start + 30 mins)
    final endDt = cleanStartDt.add(const Duration(minutes: 30));

    // 轉回 TimeOfDay
    final startTime = TimeOfDay.fromDateTime(cleanStartDt);
    final endTime = TimeOfDay.fromDateTime(endDt);
    return FilterState(
      date: now,
      startTime: startTime,
      endTime: endTime,
      minCapacity: 4,
      selectedCentreIds: [], // 初始為空 ID 列表
      isVideoConference: false,
    );
  }

  DateTime get startDateTime {
    return DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
  }

  DateTime get endDateTime {
    return DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
  }

  FilterState copyWith({
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? minCapacity,
    List<String>? selectedCentreIds,
    bool? isVideoConference,
  }) {
    return FilterState(
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      minCapacity: minCapacity ?? this.minCapacity,
      selectedCentreIds: selectedCentreIds ?? this.selectedCentreIds,
      isVideoConference: isVideoConference ?? this.isVideoConference,
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(FilterState.initial());

  void updateDate(DateTime newDate) {
    state = state.copyWith(date: newDate);
  }

  void updateTimeRange(TimeOfDay start, TimeOfDay end) {
    state = state.copyWith(startTime: start, endTime: end);
  }

  void updateCapacity(int capacity) {
    state = state.copyWith(minCapacity: capacity);
  }

  void updateSelectedCentres(List<String> ids) {
    state = state.copyWith(selectedCentreIds: ids);
  }

  void toggleCentre(String id) {
    final currentList = List<String>.from(state.selectedCentreIds);
    if (currentList.contains(id)) {
      currentList.remove(id);
    } else {
      currentList.add(id);
    }
    state = state.copyWith(selectedCentreIds: currentList);
  }

  void toggleVideoConference(bool value) {
    state = state.copyWith(isVideoConference: value);
  }

  void reset() {
    state = FilterState.initial();
  }

  void applyAllFilters({
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int minCapacity,
    required List<String> selectedCentreIds,
    required bool isVideoConference,
  }) {
    state = state.copyWith(
      date: date,
      startTime: startTime,
      endTime: endTime,
      minCapacity: minCapacity,
      selectedCentreIds: selectedCentreIds,
      isVideoConference: isVideoConference,
    );
  }

  String? validateTimeRange(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    // 條件 1: End Time 不能早於 Start Time
    if (endMinutes <= startMinutes) {
      return "End time must be later than start time";
    }

    // 條件 2: 間隔至少 30 分鐘
    if (endMinutes - startMinutes < 30) {
      return "Minimum booking duration is 30 minutes";
    }
    return null;
  }

  void setStartTime(TimeOfDay newStartTime) {
    final startMinutes = newStartTime.hour * 60 + newStartTime.minute;
    final endMinutes = state.endTime.hour * 60 + state.endTime.minute;

    // 如果新的開始時間 >= 結束時間，自動把結束時間往後推 30 分鐘
    if (startMinutes >= endMinutes - 30) {
      final newEndMinutes = startMinutes + 30;
      final newEndHour = (newEndMinutes ~/ 60) % 24;
      final newEndMinute = newEndMinutes % 60;
      state = state.copyWith(
        startTime: newStartTime,
        endTime: TimeOfDay(hour: newEndHour, minute: newEndMinute),
      );
    } else {
      state = state.copyWith(startTime: newStartTime);
    }
  }

  // 回傳 String? 代表是否有錯誤 (給 UI 顯示 Toast)
  String? setEndTime(TimeOfDay newEndTime) {
    final startMinutes = state.startTime.hour * 60 + state.startTime.minute;
    final endMinutes = newEndTime.hour * 60 + newEndTime.minute;

    // 驗證邏輯
    if (endMinutes <= startMinutes) {
      return "End time must be later than start time";
    }
    // 這裡可以加更多規則，例如最小預訂時間
    if (endMinutes - startMinutes < 15) {
      return "Minimum duration is 15 minutes";
    }

    state = state.copyWith(endTime: newEndTime);
    return null; // 無錯誤
  }

  void setCapacity(int capacity) {
    state = state.copyWith(minCapacity: capacity);
  }

  void setSelectedCentres(List<String> ids) {
    state = state.copyWith(selectedCentreIds: ids);
  }

  void setVideoConference(bool value) {
    state = state.copyWith(isVideoConference: value);
  }
}

extension FilterStatePresentation on FilterState {
  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  String get dateLabel {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String get timeLabel {
    final now = DateTime.now();

    // 將TimeOfDay轉為DateTime
    final startDt = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
    final endDt = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);

    // 定義格式：hh:mm a (例如 01:30 PM)
    final formatter = DateFormat('hh:mm a');

    // 組合字串
    return '${formatter.format(startDt)} - ${formatter.format(endDt)}';
  }

  String capacityLabel(BuildContext context) {
    // 這裡會自動判斷：傳入 1 -> 回傳 "1 Seat"；傳入 5 -> 回傳 "5 Seats"
    return context.loc.capacitySeats(minCapacity);
  }

  String centerLabel(BuildContext context, List<Centre> centres) {
    if (selectedCentreIds.isEmpty) {
      return context.loc.allCentresInTheCity;
    }

    if (selectedCentreIds.length == 1) {
      final selectedId = selectedCentreIds.first;

      // 用ID去centres列表找名字
      try {
        final centre = centres.firstWhere((c) => c.id == selectedId);
        return centre.name; // 成功，回傳中心名稱
      } catch (_) {
        // 特殊情況：如果資料還沒載入完，或是該ID不在列表內
        return '1 Center';
      }
    }

    return context.loc.multipleCentresSelected;
  }

  String getCentreButtonText(BuildContext context, AsyncValue<List<Centre>> centresAsync) {
    return centresAsync.when(
      loading: () => "Loading...",
      error: (_, __) => "Error",
      data: (centres) {
        if (selectedCentreIds.isEmpty) {
          return context.loc.allCentresInTheCity;
        } else if (selectedCentreIds.length == 1) {
          try {
            final selectedId = selectedCentreIds.first;
            final centre = centres.firstWhere((c) => c.id == selectedId);
            return centre.name;
          } catch (_) {
            return "1 Center";
          }
        } else {
          return context.loc.multipleCentresSelected;
        }
      },
    );
  }

  String getAllCentresLabel(BuildContext context, List<Centre> centres) {
    if (centres.isEmpty) return context.loc.allCentresInTheCity;
    return context.loc.allCentresInCity(centres.first.citySlug.capitalize());
  }
}
