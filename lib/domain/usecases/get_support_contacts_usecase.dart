
import '../../core/constants/api_result.dart';
import '../../data/card_support_contact_response_model.dart';
import '../medicard_repository.dart';

class GetSupportContactsUseCase {
  final MedicardRepository _repository;

  GetSupportContactsUseCase(this._repository);

  Future<ApiResult<CardSupportContactResponseModel>> call(String lang) async {
    return await _repository.getSupportContacts(lang);
  }
}
