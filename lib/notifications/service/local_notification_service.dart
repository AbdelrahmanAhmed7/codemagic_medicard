import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_destination.dart';

abstract interface class NotificationDisplay {
  Future<void> initialize({void Function(String)? onOpen});
  Future<void> show(RemoteMessage message);
  Future<String?> initialDestination();
}

class LocalNotificationService implements NotificationDisplay {
  static const channel = AndroidNotificationChannel(
    'medicard_updates',
    'MediCard',
    description: 'Service requests and invoice updates',
    importance: Importance.high,
  );
  final FlutterLocalNotificationsPlugin _plugin;

  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize({void Function(String)? onOpen}) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        onOpen?.call(notificationDestination({'route': response.payload}));
      },
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  @override
  Future<String?> initialDestination() async {
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp != true) return null;
    return notificationDestination({
      'route': launch?.notificationResponse?.payload,
    });
  }

  @override
  Future<void> show(RemoteMessage message) async {
    String text(String key) =>
        message.data[key] is String ? (message.data[key] as String).trim() : '';
    final title = message.notification?.title ?? text('title');
    final body = message.notification?.body ?? text('body');
    if (title.isEmpty && body.isEmpty) return;

    // If the message carries a PDF URL, store it as the payload so tapping
    // the notification opens the browser directly.
    final pdfUrl = text('invoice_pdf_url');
    final payload = pdfUrl.isNotEmpty
        ? pdfUrl
        : notificationDestination(message.data);

    await _plugin.show(
      id:
          (message.messageId ?? '${DateTime.now().microsecondsSinceEpoch}')
              .hashCode &
          0x7fffffff,
      title: title.isEmpty ? 'MediCard' : title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
          styleInformation: BigTextStyleInformation(body),
          visibility: NotificationVisibility.private,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
}
