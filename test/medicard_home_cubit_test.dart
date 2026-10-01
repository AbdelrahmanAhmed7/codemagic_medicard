import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medicard/core/constants/api_result.dart'
    hide Success, Failure;
import 'package:medicard/core/services/session_service.dart';
import 'package:medicard/data/card_home_info_response_model.dart';
import 'package:medicard/data/card_personal_info_response_model.dart';
import 'package:medicard/domain/medicard_repository.dart';
import 'package:medicard/domain/usecases/get_home_info_usecase.dart';
import 'package:medicard/domain/usecases/get_personal_info_usecase.dart';
import 'package:medicard/domain/usecases/get_top_providers_slider_usecase.dart';
import 'package:medicard/medicard_network/repository/medicard_network_repository.dart';
import 'package:medicard/medicard_network/service/medicard_network_api_service.dart';
import 'package:medicard/network/data/top_providers_slider_model.dart';
import 'package:medicard/presentation/logic/medicard_home_cubit.dart';
import 'package:medicard/presentation/logic/medicard_home_state.dart';

class _NoopMedicardRepo implements MedicardRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

CardHomeInfoResponseModel _homeModel() => CardHomeInfoResponseModel(
  success: true,
  timestamp: 't',
  message: 'ok',
  data: CardHomeInfoDataModel(
    cardId: '000000000000',
    firstName: 'Guest',
    lastName: ' ',
    expireDate: DateTime.now().toIso8601String(),
    memberPhoto: '',
  ),
);

CardPersonalInfoResponseModel _personalModel() =>
    CardPersonalInfoResponseModel(
      success: true,
      timestamp: 't',
      message: 'ok',
      data: const CardPersonalInfoDataModel(
        firstName: 'John',
        lastName: 'Doe',
        cardId: '123',
        mobile: '010',
        birthdate: '2000-01-01',
        isMale: true,
        activatedDate: '2024-01-01',
        expireDate: '2026-01-01',
      ),
    );

TopProvidersSliderResponse _sliderModel() =>
    const TopProvidersSliderResponse(success: true, message: 'ok', data: []);

class FakeHomeUseCase extends GetHomeInfoUseCase {
  FakeHomeUseCase(this.result) : super(_NoopMedicardRepo());
  final ApiResult<CardHomeInfoResponseModel> result;
  int calls = 0;

  @override
  Future<ApiResult<CardHomeInfoResponseModel>> call(
    String cardNo,
    String lang,
  ) async {
    calls++;
    return result;
  }
}

class FakePersonalUseCase extends GetPersonalInfoUseCase {
  FakePersonalUseCase(this.result) : super(_NoopMedicardRepo());
  final ApiResult<CardPersonalInfoResponseModel> result;
  int calls = 0;

  @override
  Future<ApiResult<CardPersonalInfoResponseModel>> call(
    String cardNo,
    String lang,
  ) async {
    calls++;
    return result;
  }
}

class FakeSliderUseCase extends GetTopProvidersForSliderUseCase {
  FakeSliderUseCase(this.result)
    : super(MedicardNetworkRepository(MedicardNetworkApiService(Dio())));
  final ApiResult<TopProvidersSliderResponse> result;
  int calls = 0;

  @override
  Future<ApiResult<TopProvidersSliderResponse>> call(String lang) async {
    calls++;
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

  test('guest path never calls GetPersonalInfo and emits sentinel success',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('medicardIsGuest', true);

    final home = FakeHomeUseCase(ApiResult.success(_homeModel()));
    final personal = FakePersonalUseCase(ApiResult.success(_personalModel()));
    final slider = FakeSliderUseCase(ApiResult.success(_sliderModel()));

    final cubit = MedicardHomeCubit(home, personal, slider);
    await cubit.getHomeInfo(cardNo: '', lang: 'en');

    expect(personal.calls, 0,
        reason: 'guest path must skip GetPersonalInfo entirely');
    expect(home.calls, 1);
    expect(slider.calls, 1);

    final state = cubit.state;
    state.maybeWhen(
      success: (homeInfo, personalInfo, sliderInfo) {
        expect(personalInfo, isNull,
            reason: 'personalData stays null for guests');
        expect(homeInfo.success, isTrue);
        expect(homeInfo.data?.cardId, '000000000000');
        expect(homeInfo.data?.firstName, 'Guest');
      },
      orElse: () => fail('expected success, got $state'),
    );
    await cubit.close();
  });

  test('logged-in regression: calls all three and keeps personalData',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final home = FakeHomeUseCase(ApiResult.success(_homeModel()));
    final personal = FakePersonalUseCase(ApiResult.success(_personalModel()));
    final slider = FakeSliderUseCase(ApiResult.success(_sliderModel()));

    // Sanity: not a guest.
    expect(await SessionService.isGuest(), isFalse);

    final cubit = MedicardHomeCubit(home, personal, slider);
    await cubit.getHomeInfo(cardNo: '123456789012', lang: 'en');

    expect(home.calls, 1);
    expect(personal.calls, 1);
    expect(slider.calls, 1);

    final state = cubit.state;
    expect(state, isA<Success>());
    state.maybeWhen(
      success: (homeInfo, personalInfo, sliderInfo) {
        expect(personalInfo, isNotNull);
        expect(personalInfo?.data?.firstName, 'John');
      },
      orElse: () => fail('expected success, got $state'),
    );
    await cubit.close();
  });
}
