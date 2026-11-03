import 'package:dio/dio.dart';

import '../core/network/backend_message_exception.dart';

class PasswordRecoveryApiService {
  static const String _baseUrl = 'https://api.medicardeg.com/api';
  final Dio _dio;

  PasswordRecoveryApiService(this._dio);

  Future<String> forgotPassword({
    required String lang,
    required String mobileNumber,
  }) => _post('$_baseUrl/$lang/Auth/ForgotPassword', {
    'mobileNumber': mobileNumber,
  });

  Future<String> resetPassword({
    required String lang,
    required String mobileNumber,
    required String otp,
    required String password,
    required String confirmPassword,
  }) => _post('$_baseUrl/$lang/Auth/ResetPassword', {
    'mobileNumber': mobileNumber,
    'otp': otp,
    'password': password,
    'confirmPassword': confirmPassword,
  });

  Future<String> _post(String url, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(url, data: data);
      final body = response.data;
      if (body == null) {
        throw const FormatException('Empty API response');
      }

      final message = body['message']?.toString().trim() ?? '';
      if (body['success'] != true) {
        if (message.isNotEmpty) throw BackendMessageException(message);
        throw const FormatException('Invalid API response');
      }
      return message;
    } catch (error) {
      final message = backendMessageFromError(error);
      if (message != null) throw BackendMessageException(message);
      rethrow;
    }
  }
}
