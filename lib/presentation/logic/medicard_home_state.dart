import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/card_home_info_response_model.dart';
import '../../data/card_personal_info_response_model.dart';
import '../../network/data/top_providers_slider_model.dart';

part 'medicard_home_state.freezed.dart';

@freezed
class MedicardHomeState with _$MedicardHomeState {
  const factory MedicardHomeState.initial() = Initial;
  const factory MedicardHomeState.loading() = Loading;
  const factory MedicardHomeState.success({
    required CardHomeInfoResponseModel homeInfo,
    CardPersonalInfoResponseModel? personalInfo,
    TopProvidersSliderResponse? sliderInfo,
  }) = Success;
  const factory MedicardHomeState.failed({required String error}) = Failed;
}
