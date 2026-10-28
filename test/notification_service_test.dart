import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicard/notifications/service/firebase_messaging_token_service.dart';
import 'package:medicard/notifications/service/firebase_notification_service.dart';
import 'package:medicard/notifications/service/firebase_token_api_service.dart';
import 'package:medicard/notifications/service/local_notification_service.dart';
import 'package:medicard/notifications/service/notification_destination.dart';

class FakeMessaging extends Fake implements FirebaseMessaging {
  RemoteMessage? initial;
  String? token = 'device-token';
  bool failToken = false;
  final tokens = StreamController<String>.broadcast();

  @override
  Future<RemoteMessage?> getInitialMessage() async => initial;

  @override
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) async {}

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    bool providesAppNotificationSettings = false,
  }) async => const NotificationSettings(
    alert: AppleNotificationSetting.enabled,
    announcement: AppleNotificationSetting.disabled,
    authorizationStatus: AuthorizationStatus.authorized,
    badge: AppleNotificationSetting.enabled,
    carPlay: AppleNotificationSetting.disabled,
    lockScreen: AppleNotificationSetting.enabled,
    notificationCenter: AppleNotificationSetting.enabled,
    showPreviews: AppleShowPreviewSetting.always,
    timeSensitive: AppleNotificationSetting.disabled,
    criticalAlert: AppleNotificationSetting.disabled,
    sound: AppleNotificationSetting.enabled,
    providesAppNotificationSettings: AppleNotificationSetting.disabled,
  );

  @override
  Future<String?> getToken({
    String? vapidKey,
    String? serviceWorkerScriptPath,
  }) async {
    if (failToken) throw StateError('FCM unavailable');
    return token;
  }

  @override
  Stream<String> get onTokenRefresh => tokens.stream;
}

class FakeDisplay implements NotificationDisplay {
  final shown = <RemoteMessage>[];
  void Function(String)? onOpen;
  String? initial;
  int initializations = 0;

  @override
  Future<void> initialize({void Function(String)? onOpen}) async {
    this.onOpen = onOpen;
    initializations++;
  }

  @override
  Future<String?> initialDestination() async => initial;

  @override
  Future<void> show(RemoteMessage message) async => shown.add(message);
}

class FakeTokenApi extends FirebaseTokenApiService {
  FakeTokenApi() : super(Dio());
  final updates = <String>[];
  bool fail = false;

  @override
  Future<void> updateToken({
    required String lang,
    required String cardNo,
    required String token,
  }) async {
    if (fail) throw StateError('offline');
    updates.add('$cardNo:$token');
  }
}

Future<void> settleNavigation(GoRouter router) async {
  // Model the route commit without native rendering in these service tests.
  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
  router.routerDelegate.notifyListeners();
  await Future<void>.delayed(Duration.zero);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('routes allow internal destinations and discard account overrides', () {
    expect(
      notificationDestination({
        'route': '/medicard-invoices/history?cardNo=other',
      }),
      '/medicard-invoices/history',
    );
    for (final route in [
      null,
      7,
      'https://example.com/medicard-invoices',
      '//example.com/medicard-home',
      '/unknown',
      '/medicard-edit-profile',
    ]) {
      expect(notificationDestination({'route': route}), '/medicard-home');
    }
  });

  test(
    'cold-start intent survives splash and login, listeners dispose',
    () async {
      final messaging = FakeMessaging()
        ..initial = const RemoteMessage(
          data: {'route': '/medicard-invoices/history'},
        );
      final display = FakeDisplay();
      final messages = StreamController<RemoteMessage>.broadcast();
      final opened = StreamController<RemoteMessage>.broadcast();
      final router = GoRouter(
        initialLocation: '/splash',
        routes: [
          for (final route in [
            '/splash',
            '/medicard-login',
            '/medicard-home',
            '/medicard-invoices/history',
            '/medicard-support',
          ])
            GoRoute(
              path: route,
              builder: (_, _) => Scaffold(body: Text(route)),
            ),
        ],
      );
      final service = FirebaseNotificationService(
        messaging: messaging,
        display: display,
        messages: messages.stream,
        openedMessages: opened.stream,
      );
      await service.start(router: router);
      await service.start(router: router);
      expect(display.initializations, 1);
      router.go('/medicard-login');
      await settleNavigation(router);
      expect(router.routeInformationProvider.value.uri.path, '/medicard-login');
      router.go('/medicard-home');
      await settleNavigation(router);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/medicard-invoices/history',
      );

      messages.add(const RemoteMessage(data: {'title': 'Invoice updated'}));
      await settleNavigation(router);
      expect(display.shown, hasLength(1));
      opened.add(const RemoteMessage(data: {'route': '/medicard-support'}));
      await settleNavigation(router);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/medicard-support',
      );
      display.onOpen?.call('/medicard-invoices/history?cardNo=other');
      await settleNavigation(router);
      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/medicard-invoices/history',
      );
      await service.dispose();
      expect(messages.hasListener, isFalse);
      expect(opened.hasListener, isFalse);
      addTearDown(router.dispose);
      addTearDown(() {
        unawaited(messages.close());
        unawaited(opened.close());
        unawaited(messaging.tokens.close());
      });
    },
  );

  test('local notification launches use the same safe destination', () async {
    final messaging = FakeMessaging();
    final display = FakeDisplay()..initial = '/medicard-invoices/history';
    final router = GoRouter(
      initialLocation: '/medicard-home',
      routes: [
        for (final path in ['/medicard-home', '/medicard-invoices/history'])
          GoRoute(path: path, builder: (_, _) => const Scaffold()),
      ],
    );
    final service = FirebaseNotificationService(
      messaging: messaging,
      display: display,
      messages: const Stream.empty(),
      openedMessages: const Stream.empty(),
    );
    await service.start(router: router);
    await settleNavigation(router);
    expect(
      router.routeInformationProvider.value.uri.path,
      '/medicard-invoices/history',
    );
    await service.dispose();
    addTearDown(router.dispose);
    addTearDown(() {
      unawaited(messaging.tokens.close());
    });
  });

  test(
    'token registration skips guests, retries failures and cancels refresh',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      final messaging = FakeMessaging();
      final api = FakeTokenApi();
      final service = FirebaseMessagingTokenService(api, messaging: messaging);
      await service.syncCurrentToken(languageCode: () => 'en');
      expect(api.updates, isEmpty);
      await prefs.setString('medicardCardNo', '123');
      api.fail = true;
      await service.syncCurrentToken(languageCode: () => 'en');
      api.fail = false;
      await service.syncCurrentToken(languageCode: () => 'en');
      expect(api.updates, ['123:device-token']);
      service.listenForTokenRefresh(languageCode: () => 'en');
      messaging.tokens.add('refreshed');
      await Future<void>.delayed(Duration.zero);
      expect(api.updates.last, '123:refreshed');
      messaging.failToken = true;
      expect(await service.getToken(), '');
      await service.dispose();
      messaging.tokens.add('ignored');
      await Future<void>.delayed(Duration.zero);
      expect(api.updates, hasLength(2));
      await messaging.tokens.close();
    },
  );
}
