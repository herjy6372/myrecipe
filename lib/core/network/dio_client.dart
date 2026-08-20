import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  // 요청 URL(검색어 포함)이 release 빌드의 시스템 로그에 남지 않도록 디버그 빌드에서만 기록한다.
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
  }
  return dio;
}
