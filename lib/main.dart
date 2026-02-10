import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tec/l10n/gen/app_localizations.dart';
import 'package:tec/l10n/l10n.dart';
import 'package:tec/core/theme/app_theme.dart';
import 'package:toastification/toastification.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_storage_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: ToastificationWrapper(
        child: MaterialApp.router(
          title: 'TEC',
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          supportedLocales: L10n.all,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          theme: AppTheme.light,
          themeMode: ThemeMode.light,
        ),
      ),
    ),
  );
}
