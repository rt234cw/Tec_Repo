import 'package:flutter/material.dart';
import 'package:tec/core/extensions/localization_extension.dart';
import 'package:tec/features/coworking/presentation/views/coworking_view.dart';
import 'package:tec/features/day_office/presentation/views/day_office_view.dart';
import 'package:tec/features/event_space/presentation/views/event_space_view.dart';
import 'package:tec/features/meeting_room/presentation/views/meeting_room_tab_view.dart';

enum TabViewItem {
  meetingRoom,
  coworking,
  dayOffice,
  eventSpace;
}

extension TabViewItemX on TabViewItem {
  String label(BuildContext context) {
    return switch (this) {
      TabViewItem.meetingRoom => context.loc.meetingRoom,
      TabViewItem.coworking => context.loc.coworking,
      TabViewItem.dayOffice => context.loc.dayOffice,
      TabViewItem.eventSpace => context.loc.eventSpace,
    };
  }

  Widget buildSheetView({
    required int tabIndex,
    required ValueChanged<double> reportHeaderHeight,
  }) {
    return switch (this) {
      TabViewItem.meetingRoom => MeetingRoomTabView(tabIndex: tabIndex, onHeaderHeightChanged: reportHeaderHeight),
      TabViewItem.coworking => const CoworkingView(),
      TabViewItem.dayOffice => const DayOfficeView(),
      TabViewItem.eventSpace => const EventSpaceView(),
    };
  }
}
