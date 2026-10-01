import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medicard/core/services/session_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setUp(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  group('SessionService guest flag', () {
    test('defaults to not guest', () async {
      expect(await SessionService.isGuest(), isFalse);
    });

    test('enterGuest sets flag, exitGuest clears it', () async {
      await SessionService.enterGuest();
      expect(await SessionService.isGuest(), isTrue);
      await SessionService.exitGuest();
      expect(await SessionService.isGuest(), isFalse);
    });
  });

  group('resolveSplashRoute 3-way (+both)', () {
    test('cardNo present -> logged-in home', () {
      expect(
        SessionService.resolveSplashRoute(cardNo: '123', isGuest: false),
        '/medicard-home?cardNo=123',
      );
    });

    test('guest only -> guest home without cardNo', () {
      expect(
        SessionService.resolveSplashRoute(cardNo: '', isGuest: true),
        '/medicard-home',
      );
    });

    test('neither -> selection', () {
      expect(
        SessionService.resolveSplashRoute(cardNo: '', isGuest: false),
        '/medicard',
      );
    });

    test('both -> logged-in wins', () {
      expect(
        SessionService.resolveSplashRoute(cardNo: '123', isGuest: true),
        '/medicard-home?cardNo=123',
      );
    });
  });
}
