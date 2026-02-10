import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookingSheetControllerProvider = Provider.autoDispose<DraggableScrollableController>((ref) {
  return DraggableScrollableController();
});
