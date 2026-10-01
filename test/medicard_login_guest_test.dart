import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medicard/core/constants/api_result.dart'
    hide Success, Failure;
import 'package:medicard/core/services/session_service.dart';
import 'package:medicard/data/card_login_request_model.dart';
import 'package:medicard/data/card_login_response_model.dart';
import 'package:medicard/domain/medicard_repository.dart';
import 'package:medicard/domain/usecases/login_card_usecase.dart';
import 'package:medicard/presentation/logic/medicard_login_cubit.dart';
import 'package:medicard/presentation/logic/medicard_login_state.dart';

class _NoopMedicardRepo implements MedicardRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeLoginUseCase extends LoginCardUseCase {
  FakeLoginUseCase(this.result) : super(_NoopMedicardRepo());
  final ApiResult<CardLoginResponseModel> result;

  @override
  Future<ApiResult<CardLoginResponseModel>> call(
    CardLoginRequestModel request,
    String lang,
  ) async {
    return result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setUp(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  test('login success clears the guest flag and persists cardNo', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('medicardIsGuest', true);
    expect(await SessionService.isGuest(), isTrue);

    const response = CardLoginResponseModel(
      success: true,
      timestamp: 't',
      message: 'ok',
      data: CardLoginDataModel(
        cardId: '123456789012',
        firstName: 'John',
        lasName: 'Doe',
      ),
    );

    final cubit = MedicardLoginCubit(
      FakeLoginUseCase(const ApiResult.success(response)),
    );

    await cubit.login(cardNo: '123456789012', password: 'pw', lang: 'en');
    // MedicardLoginCubit emits success from an async `when` callback that
    // `login()` does not await, so allow the microtask/event queue to flush.
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(cubit.state, isA<Success>());
    expect(await SessionService.isGuest(), isFalse,
        reason: 'exitGuest() must run on login success');

    final prefsAfter = await SharedPreferences.getInstance();
    expect(prefsAfter.getString('medicardCardNo'), '123456789012');

    await cubit.close();
  });
}
