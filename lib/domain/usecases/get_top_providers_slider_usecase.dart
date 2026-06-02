import '../../core/constants/api_result.dart';
import '../../medicard_network/repository/medicard_network_repository.dart';
import '../../network/data/top_providers_slider_model.dart';

class GetTopProvidersForSliderUseCase {
  final MedicardNetworkRepository _repository;

  GetTopProvidersForSliderUseCase(this._repository);

  Future<ApiResult<TopProvidersSliderResponse>> call(String lang) async {
    return await _repository.getTopProvidersForSlider(lang);
  }
}
