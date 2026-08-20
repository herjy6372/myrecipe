import 'package:dio/dio.dart';

Dio createDioClient() {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
}
