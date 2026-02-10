import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../meeting_room/presentation/providers/selected_city_provider.dart';
import '../../../meeting_room/presentation/widgets/city_selection_dialog.dart';
import '../../../meeting_room/presentation/widgets/map_resizable_tab_sheet.dart';
import '../../domain/entities/tab_view_item.dart';

class Homepage extends ConsumerStatefulWidget {
  const Homepage({super.key});

  @override
  ConsumerState<Homepage> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<Homepage> {
  // AppBar action 可以控制sheet
  final _sheetKey = GlobalKey<MapResizableTabSheetState>();
  bool _isFull = false;

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CitySelectionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = TabViewItem.values;
    final selectedCity = ref.watch(selectedCityProvider);
    final tabChildren = List.generate(items.length, (i) {
      return items[i].buildSheetView(
        tabIndex: i,
        reportHeaderHeight: (h) => _sheetKey.currentState?.setHeaderHeight(i, h),
      );
    });

    return DefaultTabController(
      length: items.length,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            tabs: items.map((e) => Tab(text: e.label(context))).toList(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                highlightColor: Colors.transparent,
                icon: Icon(
                  _isFull ? Icons.map_outlined : Icons.list_outlined,
                  key: ValueKey(_isFull),
                ),
                onPressed: () {
                  final st = _sheetKey.currentState;
                  if (st == null) return;

                  if (st.isFullNow) {
                    st.collapseToPeek();
                  } else {
                    st.expandToFull();
                  }
                },
              ),
            ),
          ],
          title: TextButton.icon(
            icon: const Icon(Icons.near_me_outlined),
            label: Text(
              selectedCity?.name ?? "Select City",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            iconAlignment: IconAlignment.end,
            onPressed: () => _showPopup(context),
          ),
        ),
        body: MapResizableTabSheet(
          key: _sheetKey,
          map: Image.asset(
            "assets/images/mock_google_map.png",
            fit: BoxFit.cover,
          ),
          tabChildren: tabChildren,
          onFullChanged: (isFull) {
            if (!mounted) return;
            setState(() => _isFull = isFull);
          },
        ),
      ),
    );
  }
}
