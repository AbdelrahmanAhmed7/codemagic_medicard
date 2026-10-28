import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medicard/core/constants/api_result.dart' hide Success, Failure;
import 'package:medicard/core/services/session_service.dart';
import 'package:medicard/data/card_login_request_model.dart';
import 'package:medicard/data/card_login_response_model.dart';
import 'package:medicard/domain/medicard_repository.dart';
import 'package:medicard/domain/usecases/login_card_usecase.dart';
import 'package:medicard/notifications/service/firebase_messaging_token_service.dart';
import 'package:medicard/presentation/logic/medicard_login_cubit.dart';
import 'package:medicard/presentation/logic/medicard_login_state.dart';

class _NoopMedicardRepo implements MedicardRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDeviceTokenProvider implements DeviceTokenProvider {
  @override
  Future<String> getToken() async => 'test-firebase-token';
}

class FakeLoginUseCase extends LoginCardUseCase {
  FakeLoginUseCase(this.result) : super(_NoopMedicardRepo());
  final ApiResult<CardLoginResponseModel> result;
  CardLoginRequestModel? lastRequest;

  @override
  Future<ApiResult<CardLoginResponseModel>> call(
    CardLoginRequestModel request,
    String lang,
  ) async {
    lastRequest = request;
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

    final loginUseCase = FakeLoginUseCase(const ApiResult.success(response));
    final cubit = MedicardLoginCubit(loginUseCase, FakeDeviceTokenProvider());

    await cubit.login(cardNo: '123456789012', password: 'pw', lang: 'en');

    expect(cubit.state, isA<Success>());
    expect(
      await SessionService.isGuest(),
      isFalse,
      reason: 'exitGuest() must run on login success',
    );

    final prefsAfter = await SharedPreferences.getInstance();
    expect(prefsAfter.getString('medicardCardNo'), '123456789012');
    expect(loginUseCase.lastRequest?.toJson(), {
      'cardNo': '123456789012',
      'password': 'pw',
      'firebaseToken': 'test-firebase-token',
    });

    await cubit.close();
  });
}
