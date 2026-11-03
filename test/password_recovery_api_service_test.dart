import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/service/password_recovery_api_service.dart';

void main() {
  test(
    'forgotPassword posts the mobile number and returns backend message',
    () async {
      late RequestOptions capturedRequest;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              capturedRequest = options;
              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'success': true,
                    'message': 'OTP sent successfully',
                    'data': null,
                  },
                ),
              );
            },
          ),
        );

      final message = await PasswordRecoveryApiService(
        dio,
      ).forgotPassword(lang: 'en', mobileNumber: '01012345678');

      expect(capturedRequest.path, endsWith('/en/Auth/ForgotPassword'));
      expect(capturedRequest.data, {'mobileNumber': '01012345678'});
      expect(message, 'OTP sent successfully');
    },
  );

  test('resetPassword posts all fields', () async {
    Map<String, dynamic>? requestData;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestData = Map<String, dynamic>.from(options.data as Map);
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'message': 'Password reset successfully',
                  'data': null,
                },
              ),
            );
          },
        ),
      );

    await PasswordRecoveryApiService(dio).resetPassword(
      lang: 'en',
      mobileNumber: '01012345678',
      otp: '1234',
      password: '12345678',
      confirmPassword: '12345678',
    );

    expect(requestData, {
      'mobileNumber': '01012345678',
      'otp': '1234',
      'password': '12345678',
      'confirmPassword': '12345678',
    });
  });

  test(
    'password recovery preserves backend failure messages exactly',
    () async {
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'success': false,
                    'message': 'Invalid OTP',
                    'data': null,
                  },
                ),
              );
            },
          ),
        );

      expect(
        () => PasswordRecoveryApiService(dio).resetPassword(
          lang: 'en',
          mobileNumber: '01012345678',
          otp: '0000',
          password: 'newpassword123',
          confirmPassword: 'newpassword123',
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            'Invalid OTP',
          ),
        ),
      );
    },
  );

  test('HTTP failures also preserve the backend message exactly', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException.badResponse(
                statusCode: 400,
                requestOptions: options,
                response: Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 400,
                  data: {
                    'success': false,
                    'message': 'Mobile number is not registered',
                    'data': null,
                  },
                ),
              ),
            );
          },
        ),
      );

    expect(
      () => PasswordRecoveryApiService(
        dio,
      ).forgotPassword(lang: 'en', mobileNumber: '01012345678'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          'Mobile number is not registered',
        ),
      ),
    );
  });
}
