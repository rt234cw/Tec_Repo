import 'package:flutter/material.dart';
import 'measure_size.dart';

class TabSheetChild extends StatelessWidget {
  const TabSheetChild({
    super.key,
    required this.header,
    required this.body,
    required this.onHeaderHeightChanged,
    this.horizontalPadding = 12,
  });

  final Widget header;
  final Widget body;
  final ValueChanged<double> onHeaderHeightChanged;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MeasureSize(
            onChange: (size) => onHeaderHeightChanged(size.height),
            child: header,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
