import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tec/core/extensions/localization_extension.dart';
import 'package:tec/core/theme/app_colors.dart';
import 'package:toastification/toastification.dart';
import 'dart:math' as math;
import '../../../../core/services/location_service.dart';
import '../providers/city_selection_provider.dart';
import '../providers/city_list_provider.dart';
import '../../domain/entities/city.dart';
import '../providers/selected_city_provider.dart';

class CitySelectionDialog extends ConsumerStatefulWidget {
  const CitySelectionDialog({super.key});

  @override
  ConsumerState<CitySelectionDialog> createState() => _CitySelectionDialogState();
}

class _CitySelectionDialogState extends ConsumerState<CitySelectionDialog> {
  final TextEditingController _controller = TextEditingController();

  bool isLocating = false;

  @override
  void initState() {
    super.initState();
    // 初始化Controller文字
    final initialCity = ref.read(citySelectionProvider).tempSelectedCity;
    if (initialCity != null) {
      _controller.text = initialCity.name;
    }

    // 綁定搜尋監聽
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  // 搜尋改變時，要更新文字
  void _onSearchChanged() {
    // 避免在 build 過程中更新狀態，延後到下一幀執行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 確保 widget 還在樹上 (防止非同步回來後頁面已關閉)
      if (mounted) {
        ref.read(citySelectionProvider.notifier).onSearchChanged(_controller.text);
      }
    });
  }

  Future<void> _handleNearestCity() async {
    if (isLocating) return;

    // 設定為 Loading 狀態 -> UI 會變更
    setState(() {
      isLocating = true;
    });

    try {
      // 模擬一點延遲，讓 Loading 狀態更明顯 (實際上可能不需要這麼久)
      await Future.delayed(const Duration(milliseconds: 500));
      final result = await ref.read(locationServiceProvider).getCurrentPosition();
      if (!mounted) return;

      // 根據狀態顯示對應UI
      switch (result.type) {
        case LocationResultType.serviceDisabled:
          _showServiceDisabledToast();
          break;
        case LocationResultType.permissionDenied:
          _showErrorToast(context.loc.locationPermissionDenied, "Permission is required.");
          break;
        case LocationResultType.permissionDeniedForever:
          _showPermissionDialog();
          break;
        case LocationResultType.error:
          _showErrorToast("Error", result.message ?? "Unknown error");
          break;
        case LocationResultType.success:
          // 只有成功時才呼叫 API 並更新狀態
          try {
            final nearestCity = await ref.refresh(nearestCityProvider.future);
            if (!mounted) return;

            if (nearestCity != null) {
              ref.read(citySelectionProvider.notifier).selectCity(nearestCity);
              // 更新 UI Controller
              _controller.text = nearestCity.name;
              // 顯示成功 Toast
              _showSuccessToast(nearestCity.name);
            } else {
              _showErrorToast(context.loc.unableToDetermineLocation, "");
            }
          } catch (e) {
            if (mounted) _showErrorToast("Error", e.toString());
          }
          break;
      }
    } finally {
      if (mounted) {
        setState(() {
          isLocating = false;
        });
      }
    }
  }

  void _showServiceDisabledToast() {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.flat,
      title: Text(context.loc.locationServiceDisabled, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Please enable GPS to use this feature."),
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: OutlinedButton(
              onPressed: () {
                Geolocator.openLocationSettings();
                toastification.dismissAll();
              },
              child: Text(context.loc.settings),
            ),
          ),
        ],
      ),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 6),
    );
  }

  void _showErrorToast(String title, String desc) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(title),
      description: desc.isNotEmpty ? Text(desc) : null,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  void _showSuccessToast(String cityName) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(context.loc.locatedNearestCity),
      description: Text(cityName),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.loc.locationPermissionRequired),
        content: Text(context.loc.locationPermissionPermanentlyDeniedMessage),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.loc.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Geolocator.openAppSettings();
            },
            child: Text(context.loc.openSettings),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(citySelectionProvider);
    final notifier = ref.read(citySelectionProvider.notifier);
    final cityListAsync = ref.watch(cityListProvider);

    /// 用來處理當鍵盤上彈時會影響到dropdown menu的顯示
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final screenH = MediaQuery.sizeOf(context).height;
    final availableForMenu = screenH - keyboard - 360;
    final effectiveMenuHeight = math.max(200, math.min(300, availableForMenu));

    /// --- END ---

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.black12,
                child: CloseButton(color: Colors.white),
              ),
              const SizedBox(width: 16),
            ],
          ),
          const SizedBox(height: 4),
          Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.9),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.loc.location,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      context.loc.pleaseSelectYourCity,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 24),

                    // DropdownMenu
                    cityListAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (cities) {
                        return SizedBox(
                          height: 48,
                          child: cityDropdownMenu(effectiveMenuHeight, keyboard, state, notifier),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Nearest Button
                    InkWell(
                      onTap: isLocating ? null : _handleNearestCity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.dialogShadow,
                              blurRadius: 8,
                              offset: Offset(2, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLocating ? "Locating..." : context.loc.selectNearestCity,
                              ),
                              const SizedBox(width: 8),
                              isLocating
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray),
                                      ),
                                    )
                                  : Icon(
                                      Icons.near_me_outlined,
                                      color: AppColors.brand,
                                      size: 16,
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Save Button
                    ElevatedButton(
                      onPressed: () async {
                        await notifier.saveSelection();
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Text(context.loc.save),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenu<City?> cityDropdownMenu(
      num effectiveMenuHeight, double keyboard, CitySelectionState state, CitySelectionNotifier notifier) {
    return DropdownMenu<City?>(
      label: const Text('City'),
      menuHeight: effectiveMenuHeight.toDouble(),
      expandedInsets: EdgeInsets.only(bottom: keyboard + 16),
      controller: _controller,
      enableFilter: false,
      enableSearch: true,
      requestFocusOnTap: true,
      initialSelection: state.tempSelectedCity,
      dropdownMenuEntries: state.menuEntries,
      onSelected: (City? city) {
        // 透過notifier 更新所選城市
        notifier.selectCity(city);
      },
      inputDecorationTheme: InputDecorationTheme(
        isCollapsed: true,
        isDense: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.borderLight,
          ),
        ),
      ),
      trailingIcon: const Icon(
        Icons.keyboard_arrow_down_outlined,
        color: AppColors.gray,
      ),
      selectedTrailingIcon: const Icon(
        Icons.keyboard_arrow_up_outlined,
        color: AppColors.gray,
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
