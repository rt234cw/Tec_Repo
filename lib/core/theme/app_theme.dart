import 'package:flutter/material.dart';
import 'package:tec/core/theme/app_colors.dart';

class AppTheme {
  const AppTheme._();
  static const double _cornerRadius = 16;

  static ThemeData get light {
    final base = ThemeData(
      fontFamily: 'LineSeed',
      useMaterial3: true,
      splashColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.light,
      surface: AppColors.brand,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
    );

    final textTheme = base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      colorScheme: scheme,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.brand,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: base.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        labelColor: AppColors.brand,
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        unselectedLabelColor: AppColors.tabUnselectedLabel,
        indicatorColor: AppColors.brand,
        dividerColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cornerRadius),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          height: 1.35,
          color: AppColors.textSecondary,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        weekdayStyle: base.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        backgroundColor: Colors.white,
        dayBackgroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.brand;
          }
          return Colors.transparent;
        }),
        dayForegroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.gray; // 過往的日子不能選：灰色
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.textPrimary;
        }),
        todayBackgroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.gray; // 過往的日子不能選：灰色
          }

          if (states.contains(WidgetState.selected)) {
            return AppColors.brand; // 今天被選取：brand 底色
          }
          return Colors.transparent; // 今天沒被選：透明底
        }),
        todayForegroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white; // 今天被選取：白字
          }
          return AppColors.brand; // 今天沒被選：brand 字 + brand 外框色
        }),
        todayBorder: const BorderSide(width: 1.5),
      ),
      checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateColor.resolveWith((state) {
            if (state.contains(WidgetState.selected)) {
              return AppColors.brand;
            }
            return Colors.transparent;
          }),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: AppColors.brand,
            ),
          )),
      chipTheme: ChipThemeData(
        iconTheme: const IconThemeData(
          size: 13,
          color: AppColors.tabUnselectedLabel,
        ),
        labelPadding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        side: const BorderSide(color: AppColors.borderLight),
        shape: const StadiumBorder(),
        labelStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        padding: EdgeInsets.zero,
        color: const WidgetStatePropertyAll(Colors.white),
      ),
      iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
        highlightColor: Colors.transparent,
      )),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          iconColor: AppColors.brand,
          foregroundColor: AppColors.textPrimary,
          overlayColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cornerRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.brand),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cornerRadius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          textStyle: base.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cornerRadius),
          ),
        ),
      ),
    );
  }
}
