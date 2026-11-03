import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/network/api_error_handler.dart';
import 'package:medicard/core/network/app_failure.dart';
import 'package:medicard/core/network/backend_message_exception.dart';

void main() {
  group('ErrorHandler', () {
    test('returns a friendly message for a Dio connection error', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/forgot-password'),
        type: DioExceptionType.connectionError,
        error: const AppFailure.network(),
      );

      expect(
        ErrorHandler.handle(error),
        'No internet connection. Please check your network.',
      );
      expect(ErrorHandler.handle(error), isNot(contains('DioException')));
    });

    test('returns a friendly message for a mapped timeout', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/forgot-password'),
        type: DioExceptionType.unknown,
        error: const AppFailure.timeout(),
      );

      expect(
        ErrorHandler.handle(error),
        'Connection timeout, please try again later.',
      );
    });

    test('preserves a backend message', () {
      expect(
        ErrorHandler.handle(
          const BackendMessageException('Mobile number is not registered'),
        ),
        'Mobile number is not registered',
      );
    });
  });
}
