import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../firebase_options.dart';
import 'local_notification_service.dart';
import 'notification_destination.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FCM displays notification payloads itself in the background.
  if (message.notification != null) return;
  final notifications = LocalNotificationService();
  await notifications.initialize();
  await notifications.show(message);
}

class FirebaseNotificationService {
  final FirebaseMessaging _messaging;
  final NotificationDisplay _display;
  final Stream<RemoteMessage> _messages;
  final Stream<RemoteMessage> _openedMessages;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  GoRouter? _router;
  String? _pendingDestination;
  bool _started = false;
  bool _disposed = false;

  FirebaseNotificationService({
    FirebaseMessaging? messaging,
    NotificationDisplay? display,
    Stream<RemoteMessage>? messages,
    Stream<RemoteMessage>? openedMessages,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _display = display ?? LocalNotificationService(),
       _messages = messages ?? FirebaseMessaging.onMessage,
       _openedMessages = openedMessages ?? FirebaseMessaging.onMessageOpenedApp;

  Future<void> start({required GoRouter router}) async {
    if (_started || _disposed) return;
    _started = true;
    _router = router;
    router.routerDelegate.addListener(_flushPendingDestination);
    _openedSubscription = _openedMessages.listen(
      (message) => _openDestination(notificationDestination(message.data)),
      onError: _reportError,
    );
    try {
      await _display.initialize(onOpen: _openDestination);
      if (_disposed) return;
      _foregroundSubscription = _messages.listen(
        (message) => unawaited(_show(message)),
        onError: _reportError,
      );
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
      final localDestination = await _display.initialDestination();
      if (localDestination != null) _openDestination(localDestination);
    } catch (error, stack) {
      _reportError(error, stack);
    }
    try {
      final message = await _messaging.getInitialMessage();
      if (message != null) {
        _openDestination(notificationDestination(message.data));
      }
      if (!_disposed) await _messaging.requestPermission();
    } catch (error, stack) {
      _reportError(error, stack);
    }
  }

  Future<void> _show(RemoteMessage message) async {
    try {
      if (!_disposed) await _display.show(message);
    } catch (error, stack) {
      _reportError(error, stack);
    }
  }

  void _openDestination(String destination) {
    if (_disposed) return;
    _pendingDestination = notificationDestination({'route': destination});
    _flushPendingDestination();
  }

  void _flushPendingDestination() {
    final router = _router;
    if (_disposed || router == null || _pendingDestination == null) return;
    final path = router.routeInformationProvider.value.uri.path;
    // Keep the intent through splash and authentication.
    if (const {
      '/splash',
      '/medicard',
      '/medicard-login',
      '/medicard-activation',
    }.contains(path)) {
      return;
    }
    final destination = _pendingDestination!;
    _pendingDestination = null;
    scheduleMicrotask(() {
      if (!_disposed) router.go(destination);
    });
  }

  Future<void> dispose() async {
    _disposed = true;
    _router?.routerDelegate.removeListener(_flushPendingDestination);
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    _router = null;
  }

  void _reportError(Object error, StackTrace stack) {
    debugPrint('Notification service unavailable: ${error.runtimeType}');
  }
}
