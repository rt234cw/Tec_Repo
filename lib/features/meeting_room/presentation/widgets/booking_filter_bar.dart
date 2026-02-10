import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tec/core/extensions/localization_extension.dart';
import 'package:tec/features/meeting_room/presentation/providers/centre_list_provider.dart';
import 'package:tec/core/theme/app_colors.dart';
import '../providers/filter_provider.dart';
import 'filter_bottom_sheet.dart';

class BookingFilterBar extends ConsumerWidget {
  const BookingFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final centresAsync = ref.watch(centreListProvider);
    final currentCentres = centresAsync.valueOrNull ?? [];

    // 開啟 BottomSheet 的方法
    void showFilterSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const FilterBottomSheet(),
      );
    }

    return Wrap(
      spacing: 8,
      children: [
        _DynamicChip(
          icon: Icons.tune_outlined,
          label: 'Filter',
          onTap: showFilterSheet,
          labelStyle: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),

        // Date
        _DynamicChip(
          icon: Icons.calendar_today,
          label: filter.dateLabel,
          onTap: showFilterSheet,
        ),

        // Time
        _DynamicChip(
          icon: Icons.access_time,
          label: filter.timeLabel,
          onTap: showFilterSheet,
        ),

        // Seats
        _DynamicChip(
          icon: Icons.people_outline,
          label: filter.capacityLabel(context),
          onTap: showFilterSheet,
        ),

        // Center
        _DynamicChip(
          icon: Icons.business_rounded,
          label: filter.centerLabel(context, currentCentres),
          onTap: showFilterSheet,
        ),

        if (filter.isVideoConference)
          _DynamicChip(
            icon: Icons.videocam_outlined,
            label: context.loc.videoConference,
            onTap: showFilterSheet,
          ),
      ],
    );
  }
}

class _DynamicChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final TextStyle? labelStyle;

  const _DynamicChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon),
      label: Text(label),
      onPressed: onTap,
      labelStyle: labelStyle,
    );
  }
}
