import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/api_result.dart';
import '../../core/constants/constants.dart';
import '../../core/helpers/shared_pref_helper.dart';
import '../../data/card_login_request_model.dart';
import '../../domain/usecases/login_card_usecase.dart';
import 'medicard_login_state.dart';

class MedicardLoginCubit extends Cubit<MedicardLoginState> {
  final LoginCardUseCase _loginCardUseCase;

  MedicardLoginCubit(this._loginCardUseCase)
    : super(const MedicardLoginState.initial());

  Future<void> login({
    required String cardNo,
    required String password,
    required String lang,
  }) async {
    emit(const MedicardLoginState.loading());

    try {
      final request = CardLoginRequestModel(cardNo: cardNo, password: password);

      final result = await _loginCardUseCase.call(request, lang);

      result.when(
        success: (response) async {
          await SharedPrefHelper.setData(SharedPrefKeys.medicardCardNo, cardNo);
          emit(MedicardLoginState.success(response));
        },
        failure: (message) {
          emit(MedicardLoginState.failed(error: message));
        },
      );
    } catch (e) {
      emit(MedicardLoginState.failed(error: e.toString()));
    }
  }
}
