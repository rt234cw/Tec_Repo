import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:tec/core/theme/app_colors.dart';
import '../../../meeting_room/presentation/providers/centre_list_provider.dart';
import '../../../meeting_room/presentation/providers/city_list_provider.dart';
import '../../../meeting_room/presentation/providers/selected_city_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 已經在 main 注入了 prefs，這裡的 build() 是同步瞬間完成的
      final savedCity = ref.read(selectedCityProvider);

      // 等待 API 資料
      // 使用 .future 強制等待 API 完成
      final allCities = await ref.read(cityListProvider.future);
      // 處理「預設值邏輯」
      if (savedCity == null) {
        // 如果本地沒存資料，從 allCities 裡找到 HKG
        final defaultCity = allCities.firstWhere(
          (city) => city.code == 'HKG',
          orElse: () => allCities.first, // 萬一找不到 HKG，就拿第一個當備案
        );
        // 將預設城市寫入 SelectedCityProvider (這會觸發 CentreListProvider 自動刷新)
        await ref.read(selectedCityProvider.notifier).setAndSaveCity(defaultCity);
      }
      // 等待 API: 取得 Centre 資料
      // 如果有setCity，這裡會自動抓到最新的cityCode去fetch
      await ref.read(centreListProvider.future);

      // 移除Splash並跳轉
      FlutterNativeSplash.remove();
      if (!mounted) return;
      context.go('/booking');
    } catch (e) {
      // 出錯也要記得移除Splash，不然使用者會卡死
      FlutterNativeSplash.remove();
      // 即使 API 失敗也讓使用者進去
      if (mounted) context.go('/booking');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.brand, body: SizedBox.shrink());
  }
}
