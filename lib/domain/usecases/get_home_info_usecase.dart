
import '../../core/constants/api_result.dart';
import '../../data/card_home_info_response_model.dart';
import '../medicard_repository.dart';

class GetHomeInfoUseCase {
  final MedicardRepository _repository;

  GetHomeInfoUseCase(this._repository);

  Future<ApiResult<CardHomeInfoResponseModel>> call(
    String cardNo,
    String lang,
  ) async {
    return await _repository.getHomeInfo(cardNo, lang);
  }
}
