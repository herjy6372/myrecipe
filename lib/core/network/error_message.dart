import 'package:dio/dio.dart';

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
        return '네트워크 연결을 확인해주세요.';
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '서버 응답이 지연되고 있어요. 잠시 후 다시 시도해주세요.';
      case DioExceptionType.badResponse:
        return '서버에서 오류가 발생했어요. (${error.response?.statusCode ?? '알 수 없음'})';
      default:
        return '요청 중 오류가 발생했어요.';
    }
  }
  return '알 수 없는 오류가 발생했어요.';
}
