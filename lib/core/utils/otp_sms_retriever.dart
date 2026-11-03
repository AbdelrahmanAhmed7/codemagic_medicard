import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

/// Retrieves a four-digit OTP on Android through the SMS User Consent API.
///
/// This does not request permission to read the user's SMS inbox. iOS OTP
/// suggestions are handled by [AutofillHints.oneTimeCode] on the Pinput.
class OtpSmsRetriever implements SmsRetriever {
  OtpSmsRetriever(this._smartAuth);

  final SmartAuth _smartAuth;
  Future<String?>? _codeFuture;
  bool _isDisposed = false;

  /// Starts listening before the request that triggers the SMS is sent, so a
  /// fast message cannot arrive before the Android listener is ready.
  void startListening() {
    if (!_isDisposed) _codeFuture ??= _listenForCode();
  }

  @override
  Future<String?> getSmsCode() {
    startListening();
    return _codeFuture ?? Future<String?>.value();
  }

  Future<String?> _listenForCode() async {
    final result = await _smartAuth.getSmsWithUserConsentApi(
      matcher: r'\b\d{4}\b',
    );
    return result.data?.code;
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _smartAuth.removeUserConsentApiListener();
  }

  @override
  bool get listenForMultipleSms => false;
}
