import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/api_result.dart';
import '../../data/card_home_info_response_model.dart';
import '../../data/card_personal_info_response_model.dart';
import '../../domain/usecases/get_home_info_usecase.dart';
import '../../domain/usecases/get_personal_info_usecase.dart';
import '../../domain/usecases/get_top_providers_slider_usecase.dart';
import '../../network/data/top_providers_slider_model.dart';
import 'medicard_home_state.dart';

class MedicardHomeCubit extends Cubit<MedicardHomeState> {
  final GetHomeInfoUseCase _getHomeInfoUseCase;
  final GetPersonalInfoUseCase _getPersonalInfoUseCase;
  final GetTopProvidersForSliderUseCase _getTopProvidersForSliderUseCase;

  MedicardHomeCubit(
    this._getHomeInfoUseCase,
    this._getPersonalInfoUseCase,
    this._getTopProvidersForSliderUseCase,
  ) : super(const MedicardHomeState.initial());

  Future<void> getHomeInfo({
    required String cardNo,
    required String lang,
  }) async {
    emit(const MedicardHomeState.loading());

    try {
      final results = await Future.wait([
        _getHomeInfoUseCase.call(cardNo, lang),
        _getPersonalInfoUseCase.call(cardNo, lang),
        _getTopProvidersForSliderUseCase.call(lang),
      ]);

      final homeInfoResult = results[0] as ApiResult<CardHomeInfoResponseModel>;
      final personalInfoResult =
          results[1] as ApiResult<CardPersonalInfoResponseModel>;
      final sliderResult = results[2] as ApiResult<TopProvidersSliderResponse>;

      homeInfoResult.when(
        success: (homeInfoResponse) {
          final personalInfo = personalInfoResult.when(
            success: (data) => data,
            failure: (_) => null,
          );
          final sliderInfo = sliderResult.when(
            success: (data) => data,
            failure: (_) => null,
          );

          emit(
            MedicardHomeState.success(
              homeInfo: homeInfoResponse,
              personalInfo: personalInfo,
              sliderInfo: sliderInfo,
            ),
          );
        },
        failure: (message) {
          emit(MedicardHomeState.failed(error: message));
        },
      );
    } catch (e) {
      emit(MedicardHomeState.failed(error: e.toString()));
    }
  }
}
