import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tec/core/extensions/localization_extension.dart';
import 'package:tec/core/extensions/string_extension.dart';
import 'package:tec/core/theme/app_colors.dart';
import 'package:tec/features/meeting_room/domain/entities/centre.dart';
import 'package:tec/features/meeting_room/presentation/providers/filter_provider.dart';
import 'package:toastification/toastification.dart';
import '../providers/centre_list_provider.dart';
import '../providers/filter_sheet_provider.dart';

import 'custom_wheel_pickers.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  void _showTopError(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: const Text("Invalid Time Selection"),
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: highModeShadow,
      showProgressBar: false,
    );
  }

  void _showWheelSheet(BuildContext context, Widget picker) {
    showModalBottomSheet(
      context: context,
      builder: (_) => picker,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftState = ref.watch(filterSheetProvider);

    // 用來呼叫方法 (setDate, apply, reset...)
    final controller = ref.read(filterSheetProvider.notifier);

    // 取得中心列表資料
    final centresAsyncValue = ref.watch(centreListProvider);
    final mediaHeight = MediaQuery.sizeOf(context).height;
    return Container(
      constraints: BoxConstraints(
        minHeight: mediaHeight * 0.4,
        maxHeight: mediaHeight * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // reset button + close button
          header(controller, context),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // 各類型的篩選條件
          filters(context, draftState, controller, centresAsyncValue),
          applyButton(controller, context),
        ],
      ),
    );
  }

  SafeArea applyButton(FilterSheetNotifier controller, BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: ElevatedButton(
          onPressed: () {
            // 呼叫 apply 並取得結果
            final error = controller.apply();

            if (error != null) {
              // 顯示置頂錯誤訊息
              _showTopError(context, error);
            } else {
              // 成功後關閉視窗
              Navigator.pop(context);
            }
          },
          child: Text(context.loc.apply),
        ),
      ),
    );
  }

  Flexible filters(BuildContext context, FilterState draftState, FilterSheetNotifier controller,
      AsyncValue<List<Centre>> centresAsyncValue) {
    return Flexible(
      fit: FlexFit.loose,
      child: ListView(
        primary: false,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
        children: [
          // --- Date ---
          _buildRow(
            context,
            title: context.loc.date,
            child: _buildButton(
              context,
              text: DateFormat('yyyy-MM-dd').format(draftState.date),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: draftState.date,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                // Date Update
                if (picked != null) controller.setDate(picked);
              },
            ),
          ),

          const SizedBox(height: 16),

          // --- Start Time ---
          _buildRow(
            context,
            title: context.loc.startTime,
            child: _buildButton(
              context,
              text: draftState.formatTime(draftState.startTime),
              onTap: () => _showWheelSheet(
                context,
                TimeWheelPicker(
                  title: context.loc.startTime,
                  initialTime: draftState.startTime,
                  // Start Time Update
                  onConfirm: (t) {
                    final error = controller.setStartTime(t);
                    if (error != null) {
                      _showTopError(context, error);
                    }
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- End Time ---
          _buildRow(
            context,
            title: context.loc.endTime,
            child: _buildButton(
              context,
              text: draftState.formatTime(draftState.endTime),
              onTap: () => _showWheelSheet(
                context,
                TimeWheelPicker(
                  title: context.loc.endTime,
                  initialTime: draftState.endTime,
                  onConfirm: (t) {
                    // End Time Update
                    final error = controller.setEndTime(t);
                    if (error != null) {
                      _showTopError(context, error);
                    }
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- Capacity ---
          _buildRow(
            context,
            title: context.loc.capacity,
            child: _buildButton(
              context,
              text: '${draftState.minCapacity}',
              onTap: () => _showWheelSheet(
                context,
                CapacityWheelPicker(
                  title: context.loc.capacity,
                  initialValue: draftState.minCapacity,
                  // Capacity Update
                  onConfirm: (v) => controller.setCapacity(v),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- Centres ---
          _buildRow(
            context,
            title: context.loc.centres,
            child: _buildButton(
              context,
              text: draftState.getCentreButtonText(context, centresAsyncValue),
              onTap: () {
                centresAsyncValue.whenData((centres) {
                  _showCentreSelectionDialog(context, controller, centres, draftState.selectedCentreIds);
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // --- Video Conference ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.loc.videoConference,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Switch.adaptive(
                value: draftState.isVideoConference,
                activeTrackColor: AppColors.brand,
                onChanged: (val) => controller.setVideoConference(val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding header(FilterSheetNotifier controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => controller.reset(),
            child: Text(context.loc.reset),
          ),
          CloseButton(
            onPressed: () {
              toastification.dismissAll(); // 關閉所有 Toast (如果有的話)
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // --- UI Components Builders ---
  Widget _buildRow(BuildContext context, {required String title, required Widget child}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        child,
      ],
    );
  }

  Widget _buildButton(BuildContext context, {required String text, required VoidCallback onTap}) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.5;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: buttonWidth,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.dialogShadow,
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.gray),
          ],
        ),
      ),
    );
  }

  // --- Centre Selection Dialog ---
  void _showCentreSelectionDialog(
    BuildContext context,
    FilterSheetNotifier controller,
    List<Centre> centres,
    List<String> currentSelectedIds,
  ) {
    final Set<String> tempIdsInDialog = currentSelectedIds.toSet();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final isAllSelected = tempIdsInDialog.isEmpty;

            return Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 標題
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Text(
                      context.loc.selectCentres,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),

                  // All Centres 選項
                  CheckboxListTile(
                    title: Text(
                      context.loc.allCentresInCity(centres.first.citySlug.capitalize()),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    value: isAllSelected,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    onChanged: (val) {
                      setStateDialog(() {
                        tempIdsInDialog.clear();
                      });
                    },
                  ),

                  // 個別中心列表 (可滾動區域)
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.gray.withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: [
                          // 這裡只放個別中心
                          ...centres.map((centre) {
                            final isSelected = tempIdsInDialog.contains(centre.id);
                            return CheckboxListTile(
                              visualDensity: VisualDensity.compact,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              title: Text(
                                centre.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              value: isSelected,
                              onChanged: (val) {
                                setStateDialog(() {
                                  if (val == true) {
                                    tempIdsInDialog.add(centre.id);
                                  } else {
                                    tempIdsInDialog.remove(centre.id);
                                  }
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // 按鈕區
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            context.loc.cancel,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.setSelectedCentres(tempIdsInDialog.toList());
                            Navigator.pop(context);
                          },
                          child: Text(
                            context.loc.done,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
