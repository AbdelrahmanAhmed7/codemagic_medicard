import '../../core/constants/api_result.dart';
import '../../data/card_login_request_model.dart';
import '../../data/card_login_response_model.dart';
import '../medicard_repository.dart';

class LoginCardUseCase {
  final MedicardRepository _repository;

  LoginCardUseCase(this._repository);

  Future<ApiResult<CardLoginResponseModel>> call(
    CardLoginRequestModel request,
    String lang,
  ) async {
    return await _repository.login(request, lang);
  }
}
