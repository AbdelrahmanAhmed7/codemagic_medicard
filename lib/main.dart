import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'core/di/service_locator.dart';
import 'core/network/connectivity_service.dart';
import 'core/routing/app_router.dart';
import 'core/theming/font_manager.dart';
import 'core/utils/responsive_screen_util.dart';
import 'firebase_options.dart';
import 'notifications/service/firebase_messaging_token_service.dart';
import 'notifications/service/firebase_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // تهيئة EasyLocalization
  await EasyLocalization.ensureInitialized();

  await ConnectivityService.instance.initialize();
  await setupServiceLocator();

  // تحديد اللغة الابتدائية من لغة الجهاز
  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
  final startLocale = deviceLocale.languageCode == 'ar'
      ? const Locale('ar')
      : const Locale('en');

  // ✅ تحديد الـ initial route بناءً على وجود session محفوظة
  final initialLocation = await AppRouter.getInitialLocation();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: startLocale,
      useOnlyLangCode: true,
      child: MyApp(initialLocation: initialLocation),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String initialLocation;

  const MyApp({super.key, required this.initialLocation});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final GoRouter _router;
  late final FirebaseNotificationService _notifications;
  bool _isTokenRefreshListenerStarted = false;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter(widget.initialLocation);
    _notifications = FirebaseNotificationService();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_startNotifications());
    });
  }

  Future<void> _startNotifications() async {
    await _notifications.start(router: _router);
    if (mounted) {
      await sl<FirebaseMessagingTokenService>().syncCurrentToken(
        languageCode: () => context.locale.languageCode,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        sl<FirebaseMessagingTokenService>().syncCurrentToken(
          languageCode: () => context.locale.languageCode,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_notifications.dispose());
    unawaited(sl<FirebaseMessagingTokenService>().dispose());
    _router.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isTokenRefreshListenerStarted) return;
    _isTokenRefreshListenerStarted = true;
    sl<FirebaseMessagingTokenService>().listenForTokenRefresh(
      languageCode: () => context.locale.languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: ResponsiveScreenUtil.phoneDesignSize,
      minTextAdapt: false,
      splitScreenMode: false,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        ScreenUtil.configure(
          data: mediaQuery,
          designSize: ResponsiveScreenUtil.adaptiveDesignSize(mediaQuery.size),
          minTextAdapt: false,
          splitScreenMode: false,
        );
        return child!;
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        title: 'MediCard',
        theme: ThemeData(
          fontFamily: FontManager.getFontFamily(context),
          useMaterial3: true,
        ),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}
