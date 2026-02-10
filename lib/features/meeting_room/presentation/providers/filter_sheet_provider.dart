import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'filter_provider.dart';

final filterSheetProvider = NotifierProvider.autoDispose<FilterSheetNotifier, FilterState>(() {
  return FilterSheetNotifier();
});

class FilterSheetNotifier extends AutoDisposeNotifier<FilterState> {
  @override
  FilterState build() {
    // 直接讀取全域的 filterProvider 作為初始值 (複製一份出來改)
    return ref.read(filterProvider);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  String? setStartTime(TimeOfDay newStartTime) {
    // 組合完整的 DateTime (日期 + 新的時間)
    final targetDateTime = DateTime(
      state.date.year,
      state.date.month,
      state.date.day,
      newStartTime.hour,
      newStartTime.minute,
    );

    // 檢查是否早於現在
    final now = DateTime.now();
    if (targetDateTime.isBefore(now)) {
      return "Start time cannot be in the past";
    }

    // 驗證通過，執行原本的連動邏輯
    final startMin = newStartTime.hour * 60 + newStartTime.minute;
    final currentEndMin = state.endTime.hour * 60 + state.endTime.minute;

    // 規則：至少間隔 30 分鐘
    final minEndMin = startMin + 30;

    TimeOfDay newEndTime = state.endTime;

    // 自動推算結束時間
    if (currentEndMin < minEndMin) {
      final newEndHour = (minEndMin ~/ 60) % 24;
      final newEndMinute = minEndMin % 60;
      newEndTime = TimeOfDay(hour: newEndHour, minute: newEndMinute);
    }

    state = state.copyWith(startTime: newStartTime, endTime: newEndTime);

    return null; // 回傳 null 代表成功
  }

  String? setEndTime(TimeOfDay newEndTime) {
    final globalNotifier = ref.read(filterProvider.notifier);
    final error = globalNotifier.validateTimeRange(state.startTime, newEndTime);

    if (error != null) {
      return error;
    }

    state = state.copyWith(endTime: newEndTime);
    return null;
  }

  void setCapacity(int capacity) {
    state = state.copyWith(minCapacity: capacity);
  }

  void setVideoConference(bool value) {
    state = state.copyWith(isVideoConference: value);
  }

  void reset() {
    state = FilterState.initial();
  }

  String? apply() {
    // 最終檢查：Start Time 是否已經變成過去
    final now = DateTime.now();
    final targetStartDateTime = DateTime(
      state.date.year,
      state.date.month,
      state.date.day,
      state.startTime.hour,
      state.startTime.minute,
    );

    if (targetStartDateTime.isBefore(now.subtract(const Duration(minutes: 1)))) {
      return "Selected start time has passed. Please update.";
    }

    // 最終檢查：End Time 是否合法
    final startMinutes = state.startTime.hour * 60 + state.startTime.minute;
    final endMinutes = state.endTime.hour * 60 + state.endTime.minute;
    if (endMinutes <= startMinutes) {
      return "End time must be later than start time.";
    }

    // 通過所有檢查，執行Apply
    ref.read(filterProvider.notifier).applyAllFilters(
          date: state.date,
          startTime: state.startTime,
          endTime: state.endTime,
          minCapacity: state.minCapacity,
          selectedCentreIds: state.selectedCentreIds,
          isVideoConference: state.isVideoConference,
        );

    return null; // 回傳 null 代表成功
  }

  // 用來更新選中的中心列表
  void setSelectedCentres(List<String> ids) {
    state = state.copyWith(selectedCentreIds: ids);
  }
}
