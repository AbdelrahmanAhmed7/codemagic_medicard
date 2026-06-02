
import '../../core/constants/api_result.dart';
import '../../data/card_activate_request_model.dart';
import '../../data/card_activate_response_model.dart';
import '../medicard_repository.dart';

class ActivateCardUseCase {
  final MedicardRepository _repository;

  ActivateCardUseCase(this._repository);

  Future<ApiResult<CardActivateResponseModel>> call(
    CardActivateRequestModel request,
    String lang,
  ) async {
    final result = await _repository.activateCard(request, lang);
    return result;
  }
}
