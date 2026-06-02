
import '../../core/constants/api_result.dart';
import '../../data/card_update_profile_request_model.dart';
import '../../data/card_update_profile_response_model.dart';
import '../medicard_repository.dart';

class UpdateProfileUseCase {
  final MedicardRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<ApiResult<CardUpdateProfileResponseModel>> call(
    CardUpdateProfileRequestModel request,
    String lang,
  ) async {
    return await _repository.updateProfile(request, lang);
  }
}
