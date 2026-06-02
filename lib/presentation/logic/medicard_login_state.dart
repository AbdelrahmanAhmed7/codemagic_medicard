import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/card_login_response_model.dart';

part 'medicard_login_state.freezed.dart';

@freezed
class MedicardLoginState with _$MedicardLoginState {
  const factory MedicardLoginState.initial() = Initial;
  const factory MedicardLoginState.loading() = Loading;
  const factory MedicardLoginState.success(CardLoginResponseModel response) = Success;
  const factory MedicardLoginState.failed({required String error}) = Failed;
}
