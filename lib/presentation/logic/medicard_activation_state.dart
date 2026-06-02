import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/card_activate_response_model.dart';

part 'medicard_activation_state.freezed.dart';

@freezed
class MedicardActivationState with _$MedicardActivationState {
  const factory MedicardActivationState.initial() = _Initial;
  const factory MedicardActivationState.loading() = _Loading;
  const factory MedicardActivationState.success(CardActivateResponseModel response) = _Success;
  const factory MedicardActivationState.failed({required String error}) = _Failed;
}
