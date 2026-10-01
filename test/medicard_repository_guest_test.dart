import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/repository/medicard_repository_impl.dart';
import 'package:medicard/service/medicard_api_service.dart';

class _ThrowingApiService implements MedicardApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('network must not be called for guests: $invocation');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setUp(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  test('guest getHomeInfo returns sentinel without network', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('medicardIsGuest', true);
    final repo = MedicardRepositoryImpl(_ThrowingApiService());

    final result = await repo.getHomeInfo('', 'en');

    result.when(
      success: (response) {
        expect(response.success, isTrue);
        expect(response.data?.cardId, '000000000000');
        expect(response.data?.firstName, 'Guest');
        expect(response.data?.lastName, ' ');
        expect(response.data?.memberPhoto, '');
        // Must be parseable by the card widget (DateTime.parse).
        expect(
          () => DateTime.parse(response.data!.expireDate),
          returnsNormally,
        );
      },
      failure: (message) => fail('expected sentinel success, got: $message'),
    );
  });

  test('empty cardNo returns sentinel without network', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final repo = MedicardRepositoryImpl(_ThrowingApiService());

    final result = await repo.getHomeInfo('', 'en');

    result.when(
      success: (response) {
        expect(response.data?.cardId, '000000000000');
      },
      failure: (message) => fail('expected sentinel success, got: $message'),
    );
  });

  test('logged-in getHomeInfo still hits network (no silent sentinel)',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Real service with a bogus base URL would attempt network; instead assert
    // that the throwing stub is reached for logged-in + non-empty cardNo.
    final repo = MedicardRepositoryImpl(_ThrowingApiService());

    final result = await repo.getHomeInfo('123456789012', 'en');

    result.when(
      success: (_) => fail('network stub should have thrown'),
      failure: (_) {
        // Expected: ErrorHandler wraps the StateError into a failure.
      },
    );
  });
}
