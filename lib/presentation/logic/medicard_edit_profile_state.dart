import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/card_update_profile_response_model.dart';

part 'medicard_edit_profile_state.freezed.dart';

@freezed
class MedicardEditProfileState with _$MedicardEditProfileState {
  const factory MedicardEditProfileState.initial() = Initial;
  const factory MedicardEditProfileState.loading() = Loading;
  const factory MedicardEditProfileState.success(CardUpdateProfileResponseModel response) = Success;
  const factory MedicardEditProfileState.failed({required String error}) = Failed;
}
