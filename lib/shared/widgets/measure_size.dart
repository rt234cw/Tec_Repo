import 'package:flutter/material.dart';

class MeasureSize extends StatefulWidget {
  const MeasureSize({
    super.key,
    required this.onChange,
    required this.child,
  });

  final ValueChanged<Size> onChange;
  final Widget child;

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  Size? _old;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = context.size;
      if (size == null) return;
      final changed =
          _old == null || (size.width - _old!.width).abs() > 0.5 || (size.height - _old!.height).abs() > 0.5;

      if (changed) {
        _old = size;
        widget.onChange(size);
      }
    });
    return widget.child;
  }
}
