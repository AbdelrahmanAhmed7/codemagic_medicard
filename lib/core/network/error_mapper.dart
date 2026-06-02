import 'dart:io';
import 'package:dio/dio.dart';
import 'app_failure.dart';

AppFailure mapDioException(DioException exception) {
  final statusCode = exception.response?.statusCode;

  // Network-level errors
  if (exception.type == DioExceptionType.connectionTimeout ||
      exception.type == DioExceptionType.sendTimeout ||
      exception.type == DioExceptionType.receiveTimeout) {
    return const AppFailure.timeout();
  }

  if (exception.type == DioExceptionType.connectionError ||
      (exception.type == DioExceptionType.unknown &&
          exception.error is SocketException)) {
    return const AppFailure.network();
  }

  // HTTP status based errors
  if (statusCode != null) {
    if (statusCode == 401) return const AppFailure.unauthorized();
    if (statusCode == 403) return const AppFailure.forbidden();
    if (statusCode == 404) return const AppFailure.notFound();
    if (statusCode >= 500) return AppFailure.server(statusCode: statusCode);

    // For 400 errors, check if response has success: true (some APIs return data even on 400)
    if (statusCode == 400) {
      final data = exception.response?.data;
      if (data != null && data is Map) {
        if (data['success'] == true && data['data'] != null) {
          // This is actually a success - return a special failure that the repository can handle
          return const AppFailure.server(statusCode: 200);
        }
        // Get error message from response
        final message = data['message'] ?? 'Bad request';
        return AppFailure.unexpected(message.toString());
      }
    }
  }

  // Fallback
  return AppFailure.unexpected(exception.message);
}

