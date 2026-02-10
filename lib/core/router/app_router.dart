import 'package:go_router/go_router.dart';
import 'package:tec/features/home/presentation/views/home_page.dart';

import '../../features/splash/presentation/views/splash_screen.dart';

final router = GoRouter(
  initialLocation: '/', // 一開始進入 Splash
  routes: [
    // Splash Screen (入口)
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    // Main Home Screen (你的 TabView 頁面)
    GoRoute(
      path: '/booking',
      builder: (context, state) => const Homepage(),
    ),
  ],
);
