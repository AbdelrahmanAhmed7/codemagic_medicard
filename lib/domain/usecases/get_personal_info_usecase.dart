
import '../../core/constants/api_result.dart' show ApiResult;
import '../../data/card_personal_info_response_model.dart';
import '../medicard_repository.dart';

class GetPersonalInfoUseCase {
  final MedicardRepository _repository;

  GetPersonalInfoUseCase(this._repository);

  Future<ApiResult<CardPersonalInfoResponseModel>> call(
    String cardNo,
    String lang,
  ) async {
    return await _repository.getPersonalInfo(cardNo, lang);
  }
}
