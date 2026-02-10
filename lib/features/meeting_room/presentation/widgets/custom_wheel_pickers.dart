import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tec/core/extensions/localization_extension.dart';

class TimeWheelPicker extends StatefulWidget {
  final String title;
  final TimeOfDay initialTime;
  // 這是「按下確認」後的回調
  final Function(TimeOfDay) onConfirm;

  const TimeWheelPicker({
    super.key,
    required this.title,
    required this.initialTime,
    required this.onConfirm,
  });

  @override
  State<TimeWheelPicker> createState() => _TimeWheelPickerState();
}

class _TimeWheelPickerState extends State<TimeWheelPicker> {
  late DateTime _currentDateTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // 初始化暫存變數
    _currentDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      widget.initialTime.hour,
      widget.initialTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Picker
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: _currentDateTime, // 使用暫存變數
              minuteInterval: 15,
              use24hFormat: false,
              onDateTimeChanged: (val) {
                // 這裡只更新內部State，不通知外部
                setState(() => _currentDateTime = val);
              },
            ),
          ),

          // Footer (Save Button)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48), // 滿版按鈕
                ),
                onPressed: () {
                  // Save時，才把最後的值傳出去，並關閉視窗
                  widget.onConfirm(TimeOfDay.fromDateTime(_currentDateTime));
                  Navigator.pop(context);
                },
                child: Text(context.loc.save),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CapacityWheelPicker extends StatefulWidget {
  final String title;
  final int initialValue;
  final Function(int) onConfirm;

  const CapacityWheelPicker({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onConfirm,
  });

  @override
  State<CapacityWheelPicker> createState() => _CapacityWheelPickerState();
}

class _CapacityWheelPickerState extends State<CapacityWheelPicker> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Picker
          Expanded(
            child: CupertinoPicker(
              itemExtent: 36,
              scrollController: FixedExtentScrollController(initialItem: widget.initialValue - 1),
              onSelectedItemChanged: (index) {
                // 只更新內部狀態
                setState(() => _currentValue = index + 1);
              },
              children: List.generate(20, (index) => Center(child: Text('${index + 1}'))),
            ),
          ),

          // Footer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity, // 滿版按鈕
                child: ElevatedButton(
                  onPressed: () {
                    // 按下Save才傳出去
                    widget.onConfirm(_currentValue);
                    Navigator.pop(context);
                  },
                  child: Text(context.loc.save),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
