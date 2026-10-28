import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/constants.dart';
import '../../core/helpers/shared_pref_helper.dart';
import 'firebase_token_api_service.dart';

abstract interface class DeviceTokenProvider {
  Future<String> getToken();
}

class FirebaseMessagingTokenService implements DeviceTokenProvider {
  final FirebaseMessaging _messaging;
  final FirebaseTokenApiService _apiService;
  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _syncing = false;

  FirebaseMessagingTokenService(
    this._apiService, {
    FirebaseMessaging? messaging,
  }) : _messaging = messaging ?? FirebaseMessaging.instance;

  @override
  Future<String> getToken() async {
    try {
      await _messaging.requestPermission();
      if (!kIsWeb &&
          defaultTargetPlatform == TargetPlatform.iOS &&
          await _messaging.getAPNSToken() == null) {
        return '';
      }
      // The backend contract uses FCM registration tokens.
      // ignore: deprecated_member_use
      return (await _messaging.getToken().timeout(
            const Duration(seconds: 10),
          ))?.trim() ??
          '';
    } catch (error) {
      // Permission refusal or unavailable Play Services must not block login.
      debugPrint('Device token unavailable: ${error.runtimeType}');
      return '';
    }
  }

  Future<void> syncCurrentToken({
    required String Function() languageCode,
  }) async {
    if (_syncing) return;
    _syncing = true;
    try {
      final cardNo = await SharedPrefHelper.getString(
        SharedPrefKeys.medicardCardNo,
      );
      if (cardNo.trim().isEmpty) return;
      final token = await getToken();
      if (token.isNotEmpty) await _registerRefreshedToken(token, languageCode);
    } catch (error) {
      debugPrint('Device token sync unavailable: ${error.runtimeType}');
    } finally {
      _syncing = false;
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  void listenForTokenRefresh({required String Function() languageCode}) {
    if (_tokenRefreshSubscription != null) return;
    // The backend update contract accepts FCM tokens.
    // ignore: deprecated_member_use
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
      (token) {
        unawaited(_registerRefreshedToken(token, languageCode));
      },
      onError: (Object error, StackTrace stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'Firebase Messaging',
            context: ErrorDescription(
              'while listening for an FCM token refresh',
            ),
          ),
        );
      },
    );
  }

  Future<void> _registerRefreshedToken(
    String token,
    String Function() languageCode,
  ) async {
    try {
      if (token.trim().isEmpty) return;
      final cardNo = (await SharedPrefHelper.getString(
        SharedPrefKeys.medicardCardNo,
      )).trim();
      if (cardNo.isEmpty) return;

      await _apiService.updateToken(
        lang: languageCode(),
        cardNo: cardNo,
        token: token,
      );
    } catch (error) {
      // A failed registration is retried with the current token on app resume.
      debugPrint('Device token sync failed: ${error.runtimeType}');
    }
  }
}
