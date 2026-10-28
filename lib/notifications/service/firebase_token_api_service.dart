import 'package:dio/dio.dart';

class FirebaseTokenApiService {
  static const String _baseUrl = 'https://api.medicardeg.com/api';
  final Dio _dio;

  FirebaseTokenApiService(this._dio);

  Future<void> updateToken({
    required String lang,
    required String cardNo,
    required String token,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/$lang/Auth/UpdateFirebaseToken',
      data: {'cardNo': cardNo, 'token': token},
    );
    final body = response.data;
    if (body != null && body['success'] == false) {
      final message = body['message'] as String?;
      throw StateError(
        message?.isNotEmpty == true
            ? message!
            : 'Failed to update the Firebase device token',
      );
    }
  }
}
