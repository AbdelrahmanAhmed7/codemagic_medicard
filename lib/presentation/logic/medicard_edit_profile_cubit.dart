import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/api_result.dart';
import '../../data/card_update_profile_request_model.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'medicard_edit_profile_state.dart';

class MedicardEditProfileCubit extends Cubit<MedicardEditProfileState> {
  final UpdateProfileUseCase _updateProfileUseCase;

  MedicardEditProfileCubit(this._updateProfileUseCase)
    : super(const MedicardEditProfileState.initial());

  Future<void> updateProfile({
    required String cardNo,
    required String lang,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? nationalId,
    String? passportNumber,
    String? birthdate,
    bool? isMale,
    String? profileImage,
  }) async {
    emit(const MedicardEditProfileState.loading());

    try {
      final request = CardUpdateProfileRequestModel(
        cardNo: cardNo,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        email: email,
        nationalId: nationalId,
        passportNumber: passportNumber,
        birthdate: birthdate,
        isMale: isMale,
        profileImage: profileImage,
      );

      final result = await _updateProfileUseCase.call(request, lang);

      result.when(
        success: (response) {
          emit(MedicardEditProfileState.success(response));
        },
        failure: (message) {
          emit(MedicardEditProfileState.failed(error: message));
        },
      );
    } catch (e) {
      emit(MedicardEditProfileState.failed(error: e.toString()));
    }
  }
}
