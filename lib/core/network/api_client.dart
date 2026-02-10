import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 用在Api request的常數
const String kBaseUrl = 'https://octo.pr-product-core.executivecentre.net';
const String kAccessKey = 'qui_aute_fugiat_irure';

final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: kBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'x-access-key': kAccessKey,
    },
  );

  final dio = Dio(options);

  // 關鍵修改：忽略 SSL 憑證錯誤 (模擬 Postman 的行為)
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      // 這一行就是讓它"閉著眼睛"通過驗證
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    },
  );

  // 加入 Log在console看到詳細的 Request/Response
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
  ));

  return dio;
});
