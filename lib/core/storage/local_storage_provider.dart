import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 要 async 初始化，但 Provider 不能直接 await。
/// 所以在 main() 先 getInstance()，再用 ProviderScope.overrides 注入：
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences has not been initialized');
});
