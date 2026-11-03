import 'package:dio/dio.dart';

/// Keeps an API-provided message intact all the way to the presentation layer.
class BackendMessageException implements Exception {
  final String message;

  const BackendMessageException(this.message);

  @override
  String toString() => message;
}

String? backendMessageFromError(Object error) {
  if (error is BackendMessageException) return error.message;
  if (error is! DioException) return null;

  final data = error.response?.data;
  if (data is Map) {
    final message = data['message']?.toString().trim() ?? '';
    if (message.isNotEmpty) return message;
  }
  return null;
}
