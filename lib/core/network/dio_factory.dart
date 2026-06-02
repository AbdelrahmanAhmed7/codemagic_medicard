import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:medicard/core/network/retry_inceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/constants.dart';
import '../helpers/shared_pref_helper.dart';
import 'connectivity_service.dart';
import 'error_mapping_interceptor.dart';

class DioFactory {
  DioFactory._();
  static Dio? _dio;

  static Future<Dio> getDio() async {
    if (_dio != null) return _dio!;

    const timeout = Duration(seconds: 15);
    _dio = Dio()
      ..options.connectTimeout = timeout
      ..options.receiveTimeout = timeout;

    await _addHeaders();
    _addInterceptors();
    return _dio!;
  }

  /// Get Dio instance for Medicard external API (no MCI auth headers)
  /// Medicard is a completely separate external API (api.medicardeg.com)
  /// and must NOT carry any MCI app Authorization token.
  static Future<Dio> getDioForMedicard() async {
    const timeout = Duration(
      seconds: 30,
    ); // longer timeout for multipart uploads
    final dio = Dio()
      ..options.connectTimeout = timeout
      ..options.receiveTimeout = timeout
      ..options.sendTimeout = timeout;

    // Only Accept header — no Authorization token
    dio.options.headers = {'Accept': 'application/json'};

    // Error mapping
    dio.interceptors.add(ErrorMappingInterceptor());

    // Retry interceptor
    dio.interceptors.add(
      RetryInterceptor(
        connectivityService: ConnectivityService.instance,
        maxRetries: 2,
        baseDelay: const Duration(seconds: 1),
      ),
    );

    // Logger — debug mode only
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          compact: false,
          maxWidth: 90,
        ),
      );
    }

    return dio;
  }

  /// Get Dio instance with custom timeout for login requests
  static Future<Dio> getDioForLogin() async {
    const timeout = Duration(seconds: 10);
    final dio = Dio()
      ..options.connectTimeout = timeout
      ..options.receiveTimeout = timeout;

    // Add headers without token (login doesn't need token)
    dio.options.headers = {'Accept': 'application/json'};

    // Add interceptors
    dio.interceptors.add(ErrorMappingInterceptor());

    dio.interceptors.add(
      RetryInterceptor(
        connectivityService: ConnectivityService.instance,
        maxRetries: 2, // Less retries for login
        baseDelay: const Duration(seconds: 1),
      ),
    );

    // Logger — debug mode only
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          compact: false,
          maxWidth: 90,
        ),
      );
    }

    return dio;
  }

  static Future<void> _addHeaders() async {
    final token = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.userToken,
    );
    _dio?.options.headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static void setTokenIntoHeaderAfterLogin(String token) {
    _dio?.options.headers['Authorization'] = 'Bearer $token';
  }

  static void _addInterceptors() {
    // Map low-level Dio exceptions to domain failures
    _dio?.interceptors.add(ErrorMappingInterceptor());

    // Add retry interceptor
    _dio?.interceptors.add(
      RetryInterceptor(
        connectivityService: ConnectivityService.instance,
        maxRetries: 3,
        baseDelay: const Duration(seconds: 2),
      ),
    );

    // Logger — debug mode only
    if (kDebugMode) {
      _dio?.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          compact: false,
          maxWidth: 90,
        ),
      );
    }
  }
}
