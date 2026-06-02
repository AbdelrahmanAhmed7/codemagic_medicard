import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/api_result.dart';
import '../../core/constants/constants.dart';
import '../../core/helpers/shared_pref_helper.dart';
import '../../data/card_activate_request_model.dart';
import '../../domain/usecases/activate_card_usecase.dart';
import 'medicard_activation_state.dart';

class MedicardActivationCubit extends Cubit<MedicardActivationState> {
  final ActivateCardUseCase _activateCardUseCase;

  MedicardActivationCubit(this._activateCardUseCase) 
      : super(const MedicardActivationState.initial());

  Future<void> activateCard({
    required String cardNo,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    String? nationalId,
    required String birthdate,
    String? passportNumber,
    String? email,
    required bool isMale,
    String? profileImage,
    required String lang,
  }) async {
    emit(const MedicardActivationState.loading());

    try {
      final request = CardActivateRequestModel(
        cardNo: cardNo,
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
        nationalId: nationalId,
        birthdate: birthdate,
        passportNumber: passportNumber,
        email: email,
        isMale: isMale,
        profileImage: profileImage,
      );

      final result = await _activateCardUseCase.call(request, lang);

      result.when(
        success: (response) async {
          // ✅ حفظ cardNo في SharedPreferences للـ session
          await SharedPrefHelper.setData(SharedPrefKeys.medicardCardNo, cardNo);
          emit(MedicardActivationState.success(response));
        },
        failure: (message) {
          emit(MedicardActivationState.failed(error: message));
        },
      );
    } catch (e) {
      emit(MedicardActivationState.failed(error: e.toString()));
    }
  }
}

