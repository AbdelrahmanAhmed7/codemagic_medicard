import 'package:medicard/data/card_activate_request_model.dart';
import 'package:medicard/data/card_activate_response_model.dart';
import 'package:medicard/data/card_login_response_model.dart';

import '../core/constants/api_result.dart';
import '../data/card_home_info_response_model.dart';
import '../data/card_login_request_model.dart';
import '../data/card_personal_info_response_model.dart';
import '../data/card_support_contact_response_model.dart';
import '../data/card_update_profile_request_model.dart';
import '../data/card_update_profile_response_model.dart';

abstract class MedicardRepository {
  Future<ApiResult<CardActivateResponseModel>> activateCard(
    CardActivateRequestModel request,
    String lang,
  );

  Future<ApiResult<CardLoginResponseModel>> login(
    CardLoginRequestModel request,
    String lang,
  );

  Future<ApiResult<CardHomeInfoResponseModel>> getHomeInfo(
    String cardNo,
    String lang,
  );

  Future<ApiResult<CardPersonalInfoResponseModel>> getPersonalInfo(
    String cardNo,
    String lang,
  );

  Future<ApiResult<CardSupportContactResponseModel>> getSupportContacts(
    String lang,
  );

  Future<ApiResult<CardUpdateProfileResponseModel>> updateProfile(
    CardUpdateProfileRequestModel request,
    String lang,
  );
}
