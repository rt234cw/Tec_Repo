import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tec/core/extensions/localization_extension.dart';
import 'package:tec/features/meeting_room/domain/entities/meeting_room_ui_model.dart';
import 'package:tec/features/meeting_room/presentation/widgets/booking_filter_bar.dart';
import 'package:tec/features/meeting_room/presentation/widgets/filter_bottom_sheet.dart';
import 'package:tec/core/theme/app_colors.dart';
import 'package:tec/features/meeting_room/presentation/widgets/meeting_room_item.dart';
import '../providers/meeting_room_list_provider.dart';
import '../../../../shared/widgets/tab_sheet_child.dart';

class MeetingRoomTabView extends ConsumerStatefulWidget {
  const MeetingRoomTabView({
    super.key,
    required this.onHeaderHeightChanged,
    required this.tabIndex,
    this.autoOpenFilterOnEnter = true,
  });

  final ValueChanged<double> onHeaderHeightChanged;
  final int tabIndex;
  final bool autoOpenFilterOnEnter;

  @override
  ConsumerState<MeetingRoomTabView> createState() => _MeetingRoomTabViewState();
}

class _MeetingRoomTabViewState extends ConsumerState<MeetingRoomTabView> {
  TabController? _tabController;
  bool _didAutoOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final tc = DefaultTabController.of(context);
    if (_tabController == tc) return;

    _tabController?.removeListener(_onTabChanged);
    _tabController = tc;
    _tabController?.addListener(_onTabChanged);

    // 第一次進來就檢查一次
    _tryAutoOpen();
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meetingRoomListAsync = ref.watch(meetingRoomListProvider);
    return TabSheetChild(
      header: const BookingFilterBar(),
      onHeaderHeightChanged: widget.onHeaderHeightChanged,
      body: meetingRoomListAsync.when(
        data: (rooms) {
          //當篩選結果為空時，顯示提示訊息而非空白頁面
          if (rooms.isEmpty) {
            return emptyRoom(context);
          }
          // 正常顯示會議室列表
          return mainView(rooms);
        },
        loading: () => SizedBox.shrink(), // 避免縮到最小看到圓形 spinner
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Load failed: $e'),
          ),
        ),
      ),
    );
  }

  void _onTabChanged() => _tryAutoOpen();

  void _tryAutoOpen() {
    if (!widget.autoOpenFilterOnEnter) return;
    if (_didAutoOpen) return;

    final tc = _tabController;
    if (tc == null) return;

    // 只在「此 tab 成為目前選取」時彈出
    if (tc.index != widget.tabIndex) return;

    // 下一個frame再開，避免在build/動畫過程中呼叫
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didAutoOpen) return;
      if (_tabController?.index != widget.tabIndex) return;

      _didAutoOpen = true;
      _showFilterSheet();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }

  RefreshIndicator mainView(List<MeetingRoomUiModel> rooms) {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      onRefresh: () async {
        ref.invalidate(meetingRoomListProvider);
      },
      child: ListView.separated(
        key: const PageStorageKey('meetingRoomList'),
        itemCount: rooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => MeetingRoomItem(room: rooms[index]),
      ),
    );
  }

  Center emptyRoom(BuildContext context) {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.inbox_outlined,
          size: 60,
          color: AppColors.brand,
        ),
        const SizedBox(height: 16),
        Text(context.loc.noResultMatches),
      ],
    ));
  }
}
