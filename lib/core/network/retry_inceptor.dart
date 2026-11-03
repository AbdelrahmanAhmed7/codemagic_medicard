import 'package:dio/dio.dart';

import 'connectivity_service.dart';

/// Interceptor that retries failed requests with exponential backoff.
/// The [dio] parameter must be the same Dio instance that owns this interceptor
/// so retries are replayed through the correct base URL and headers.
class RetryInterceptor extends Interceptor {
  final ConnectivityService _connectivityService;
  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;

  RetryInterceptor({
    required ConnectivityService connectivityService,
    required Dio dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 2),
  })  : _connectivityService = connectivityService,
        _dio = dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldRetry(err)) return super.onError(err, handler);

    final isOnline = await _connectivityService.checkConnectivity();
    if (!isOnline) return super.onError(err, handler);

    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;
    if (retryCount >= maxRetries) return super.onError(err, handler);

    final delay = Duration(
      milliseconds: baseDelay.inMilliseconds * (1 << retryCount),
    );
    await Future.delayed(delay);

    err.requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      final response = await _dio.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
          extra: {...err.requestOptions.extra, 'retryCount': retryCount + 1},
          responseType: err.requestOptions.responseType,
          validateStatus: err.requestOptions.validateStatus,
        ),
        cancelToken: err.requestOptions.cancelToken,
        onSendProgress: err.requestOptions.onSendProgress,
        onReceiveProgress: err.requestOptions.onReceiveProgress,
      );
      return handler.resolve(response);
    } catch (_) {
      return super.onError(err, handler);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.type == DioExceptionType.unknown &&
            err.error != null &&
            err.error.toString().contains('SocketException'));
  }
}
