import 'package:dio/dio.dart';

import 'connectivity_service.dart';
import 'dio_factory.dart';

/// Interceptor to retry failed requests with exponential backoff
class RetryInterceptor extends Interceptor {
  final ConnectivityService _connectivityService;
  final int maxRetries;
  final Duration baseDelay;

  RetryInterceptor({
    required ConnectivityService connectivityService,
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 2),
  }) : _connectivityService = connectivityService;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry on network errors or timeouts
    if (!_shouldRetry(err)) {
      return super.onError(err, handler);
    }

    // Check if device is offline
    final isOnline = await _connectivityService.checkConnectivity();
    if (!isOnline) {
      // Don't retry if offline
      return super.onError(err, handler);
    }

    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (retryCount >= maxRetries) {
      // Max retries reached
      return super.onError(err, handler);
    }

    // Calculate delay with exponential backoff
    final delay = Duration(
      milliseconds: (baseDelay.inMilliseconds * (1 << retryCount)),
    );

    await Future.delayed(delay);

    // Update retry count
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      // Retry the request using DioFactory's instance
      final dio = await _getDioInstance();
      final response = await dio.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
          extra: {
            ...err.requestOptions.extra,
            'retryCount': retryCount + 1,
          },
          responseType: err.requestOptions.responseType,
          validateStatus: err.requestOptions.validateStatus,
        ),
        cancelToken: err.requestOptions.cancelToken,
        onSendProgress: err.requestOptions.onSendProgress,
        onReceiveProgress: err.requestOptions.onReceiveProgress,
      );
      return handler.resolve(response);
    } catch (e) {
      // If retry fails, continue with error
      return super.onError(err, handler);
    }
  }

  /// Check if error should be retried
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.type == DioExceptionType.unknown &&
            err.error != null &&
            err.error.toString().contains('SocketException'));
  }

  /// Get Dio instance from factory
  Future<Dio> _getDioInstance() async {
    return await DioFactory.getDio();
  }
}