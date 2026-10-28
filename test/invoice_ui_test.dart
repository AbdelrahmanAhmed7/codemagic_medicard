import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicard/core/di/service_locator.dart';
import 'package:medicard/core/utils/responsive_screen_util.dart';
import 'package:medicard/invoices/data/invoice_models.dart';
import 'package:medicard/invoices/presentation/invoice_create_form.dart';
import 'package:medicard/invoices/presentation/invoices_screen.dart';
import 'package:medicard/invoices/repository/invoice_repository.dart';

class FakeInvoices extends Fake implements InvoiceRepository {
  final calls = <String>[];
  int creates = 0;
  Completer<InvoicePage<InvoiceRecord>>? delayedPending;
  bool fail = false;

  @override
  Future<InvoicePage<InvoiceProvider>> getProviders({
    required String lang,
    String? search,
    int page = 1,
  }) async => const InvoicePage(
    items: [
      InvoiceProvider(
        providerId: 1,
        providerName: 'MediCard Medical Center',
        providerLogo: '',
        categoryId: 1,
        categoryName: 'Medical services',
      ),
    ],
    currentPage: 1,
    totalPages: 1,
    hasNextPage: false,
  );

  @override
  Future<InvoicePage<InvoiceBranch>> getProviderBranches({
    required String lang,
    required int providerId,
    int page = 1,
  }) async => const InvoicePage(
    items: [
      InvoiceBranch(
        locationId: 2,
        providerId: 1,
        branchName: 'Cairo branch',
        area: 'Nasr City',
        address: 'Main street',
        city: 'Cairo',
        government: 'Cairo',
        mobile: '',
        latitude: 0,
        longitude: 0,
        mapsUrl: '',
      ),
    ],
    currentPage: 1,
    totalPages: 1,
    hasNextPage: false,
  );

  @override
  Future<CreatedInvoice> createInvoice({
    required String lang,
    required String cardNo,
    required int providerId,
    required int providerLocationId,
    required String notes,
    XFile? attachment,
  }) async {
    creates++;
    expect(providerId, 1);
    expect(providerLocationId, 2);
    expect(notes, 'Blood test request');
    return const CreatedInvoice(
      id: 42,
      cardId: '123',
      providerId: 1,
      providerLocationId: 2,
      status: 'Pending',
      notes: '',
      attachmentsFolder: '',
      createdAt: null,
    );
  }

  InvoicePage<InvoiceRecord> page(String status) => InvoicePage(
    items: [
      InvoiceRecord(
        id: status == 'Pending' ? 1 : 42,
        providerLogo: '',
        providerName: 'MediCard Medical Center',
        status: status == 'All' ? 'Approved' : status,
        statusChar: '',
        notes: 'Consultation and laboratory services',
        attachmentsFolder: '',
        createdAt: DateTime(2026, 10, 28),
        lineCount: 3,
        totalAmount: 1250.50,
      ),
    ],
    currentPage: 1,
    totalPages: 1,
    hasNextPage: false,
  );

  @override
  Future<InvoicePage<InvoiceRecord>> getInvoices({
    required String lang,
    required String cardNo,
    String status = 'All',
    int page = 1,
  }) async {
    calls.add('$status:$page');
    if (fail) throw StateError('sensitive server details');
    if (status == 'Pending' && delayedPending != null) {
      return delayedPending!.future;
    }
    return this.page(status);
  }
}

final previewKey = GlobalKey();
final translations = <String, Map<String, dynamic>>{};

class TestAssetLoader extends AssetLoader {
  const TestAssetLoader();
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      translations[locale.languageCode]!;
}

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  String lang = 'en',
  Size size = const Size(375, 812),
  double textScale = 1,
  GoRouter? router,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      assetLoader: const TestAssetLoader(),
      fallbackLocale: const Locale('en'),
      startLocale: Locale(lang),
      saveLocale: false,
      child: Builder(
        builder: (context) => ScreenUtilInit(
          designSize: ResponsiveScreenUtil.adaptiveDesignSize(size),
          builder: (_, _) => router == null
              ? MaterialApp(
                  debugShowCheckedModeBanner: false,
                  locale: context.locale,
                  supportedLocales: context.supportedLocales,
                  localizationsDelegates: context.localizationDelegates,
                  theme: ThemeData(
                    fontFamily: lang == 'ar' ? 'Cairo' : 'Roboto',
                    useMaterial3: true,
                  ),
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(textScale)),
                    child: child!,
                  ),
                  home: RepaintBoundary(key: previewKey, child: screen),
                )
              : MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  locale: context.locale,
                  supportedLocales: context.supportedLocales,
                  localizationsDelegates: context.localizationDelegates,
                  theme: ThemeData(
                    fontFamily: lang == 'ar' ? 'Cairo' : 'Roboto',
                    useMaterial3: true,
                  ),
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(textScale)),
                    child: child!,
                  ),
                  routerConfig: router,
                ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> preview(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('WRITE_UI_PREVIEWS')) return;
  final boundary =
      previewKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/ui-previews')
      ..createSync(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(() async {
    await EasyLocalization.ensureInitialized();
    for (final lang in ['en', 'ar']) {
      translations[lang] =
          jsonDecode(
                await rootBundle.loadString('assets/translations/$lang.json'),
              )
              as Map<String, dynamic>;
    }
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final family in ['Cairo', 'Roboto']) {
      final font = FontLoader(family)
        ..addFont(rootBundle.load('assets/fonts/$family-Regular.ttf'));
      await font.load();
    }
  });
  tearDown(() async => sl.reset());

  testWidgets(
    'request requires provider, branch and details before submission',
    (tester) async {
      final repository = FakeInvoices();
      final form = Scaffold(
        backgroundColor: const Color(0xFFF3F6FA),
        appBar: AppBar(title: const Text('New request')),
        body: InvoiceCreateForm(cardNo: '123', repository: repository),
      );
      final router = GoRouter(
        initialLocation: '/form',
        routes: [
          GoRoute(path: '/form', builder: (_, _) => form),
          GoRoute(
            path: '/medicard-invoices/history',
            builder: (_, state) => Scaffold(
              body: Text('My invoices ${state.uri.queryParameters['cardNo']}'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await pumpScreen(tester, form, router: router);
      await preview(tester, 'request-en');
      await tester.scrollUntilVisible(
        find.byType(FilledButton),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.scrollUntilVisible(
        find.text('Choose provider'),
        -300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Choose provider'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('MediCard Medical Center'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose branch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cairo branch'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(FilledButton),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.scrollUntilVisible(
        find.byType(TextField),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byType(TextField), 'Blood test request');
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(repository.creates, 1);
      expect(find.byType(Dialog), findsOneWidget);
      expect(
        find.textContaining('submitted successfully'),
        findsOneWidget,
      );
      expect(find.text('Request #42'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      expect(find.text('My invoices 123'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('history switches server filters and ignores stale responses', (
    tester,
  ) async {
    final repository = FakeInvoices();
    sl.registerSingleton<InvoiceRepository>(repository);
    await pumpScreen(tester, const InvoiceHistoryScreen(cardNo: '123'));
    await preview(tester, 'invoices-en');
    expect(find.text('Request #42'), findsOneWidget);
    repository.delayedPending = Completer();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Pending'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Approved'));
    await tester.pumpAndSettle();
    repository.delayedPending!.complete(repository.page('Pending'));
    await tester.pumpAndSettle();
    expect(repository.calls, ['All:1', 'Pending:1', 'Approved:1']);
    expect(find.text('Request #1'), findsNothing);
    expect(find.text('Request #42'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Arabic request and history fit a narrow screen with larger text',
    (tester) async {
      final repository = FakeInvoices();
      sl.registerSingleton<InvoiceRepository>(repository);
      await pumpScreen(
        tester,
        const InvoiceHistoryScreen(cardNo: '123'),
        lang: 'ar',
        size: const Size(320, 640),
        textScale: 1.3,
      );
      await preview(tester, 'invoices-ar');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await pumpScreen(
        tester,
        Scaffold(
          backgroundColor: const Color(0xFFF3F6FA),
          appBar: AppBar(title: const Text('طلب جديد')),
          body: InvoiceCreateForm(cardNo: '123', repository: repository),
        ),
        lang: 'ar',
        size: const Size(320, 640),
        textScale: 1.3,
      );
      await preview(tester, 'request-ar');
      await tester.drag(find.byType(ListView).first, const Offset(0, -1000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('history errors are readable and can be retried', (tester) async {
    final repository = FakeInvoices()..fail = true;
    sl.registerSingleton<InvoiceRepository>(repository);
    await pumpScreen(tester, const InvoiceHistoryScreen(cardNo: '123'));
    expect(find.textContaining('sensitive server details'), findsNothing);
    expect(
      find.text("We couldn't load your requests. Please try again."),
      findsOneWidget,
    );
    repository.fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Request #42'), findsOneWidget);
  });
}
