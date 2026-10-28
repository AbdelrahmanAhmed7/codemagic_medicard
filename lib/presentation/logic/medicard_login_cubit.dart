import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/api_result.dart';
import '../../core/constants/constants.dart';
import '../../core/helpers/shared_pref_helper.dart';
import '../../core/services/session_service.dart';
import '../../data/card_login_request_model.dart';
import '../../domain/usecases/login_card_usecase.dart';
import '../../notifications/service/firebase_messaging_token_service.dart';
import 'medicard_login_state.dart';

class MedicardLoginCubit extends Cubit<MedicardLoginState> {
  final LoginCardUseCase _loginCardUseCase;
  final DeviceTokenProvider _deviceTokenProvider;

  MedicardLoginCubit(this._loginCardUseCase, this._deviceTokenProvider)
    : super(const MedicardLoginState.initial());

  Future<void> login({
    required String cardNo,
    required String password,
    required String lang,
  }) async {
    emit(const MedicardLoginState.loading());

    try {
      final request = CardLoginRequestModel(
        cardNo: cardNo,
        password: password,
        firebaseToken: await _deviceTokenProvider.getToken(),
      );

      final result = await _loginCardUseCase.call(request, lang);

      await result.when<Future<void>>(
        success: (response) async {
          await SharedPrefHelper.setData(SharedPrefKeys.medicardCardNo, cardNo);
          await SessionService.exitGuest();
          if (!isClosed) emit(MedicardLoginState.success(response));
          final tokenProvider = _deviceTokenProvider;
          if (tokenProvider is FirebaseMessagingTokenService) {
            await tokenProvider.syncCurrentToken(languageCode: () => lang);
          }
        },
        failure: (message) async {
          if (!isClosed) emit(MedicardLoginState.failed(error: message));
        },
      );
    } catch (e) {
      if (!isClosed) emit(MedicardLoginState.failed(error: e.toString()));
    }
  }
}
