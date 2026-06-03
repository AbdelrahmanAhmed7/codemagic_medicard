import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../data/card_activate_response_model.dart';
import '../data/card_home_info_response_model.dart';
import '../data/card_login_request_model.dart';
import '../data/card_login_response_model.dart';
import '../data/card_personal_info_response_model.dart';
import '../data/card_support_contact_response_model.dart';
import '../data/card_update_profile_response_model.dart';

part 'medicard_api_service.g.dart';

@RestApi(baseUrl: 'https://api.medicardeg.com/api/')
abstract class MedicardApiService {
  factory MedicardApiService(Dio dio, {String baseUrl}) = _MedicardApiService;

  @POST("{lang}/Auth/CardActivate")
  @MultiPart()
  Future<CardActivateResponseModel> activateCard(
    @Path("lang") String lang,
    @Part(name: "CardNo") String cardNo,
    @Part(name: "PhoneNumber") String phoneNumber,
    @Part(name: "Password") String password,
    @Part(name: "ConfirmPassword") String confirmPassword,
    @Part(name: "FirstName") String firstName,
    @Part(name: "LastName") String lastName,
    @Part(name: "NationalId") String? nationalId,
    @Part(name: "Birthdate") String birthdate,
    @Part(name: "PassportNumber") String? passportNumber,
    @Part(name: "Email") String? email,
    @Part(name: "IsMale") bool isMale,
    @Part(name: "ProfileImage") MultipartFile? profileImage,
  );

  @POST("{lang}/Auth/Login")
  Future<CardLoginResponseModel> login(
    @Path("lang") String lang,
    @Body() CardLoginRequestModel request,
  );

  @GET("{lang}/Home/GetHomeInfo")
  Future<CardHomeInfoResponseModel> getHomeInfo(
    @Path("lang") String lang,
    @Query("CardNo") String cardNo,
  );

  @GET("{lang}/Profile/GetPersonalInfo")
  Future<CardPersonalInfoResponseModel> getPersonalInfo(
    @Path("lang") String lang,
    @Query("CardNo") String cardNo,
  );

  @GET("{lang}/ContactUs/Get")
  Future<CardSupportContactResponseModel> getSupportContacts(
    @Path("lang") String lang,
  );

  @PUT("{lang}/Profile/UpdateProfile")
  @MultiPart()
  Future<CardUpdateProfileResponseModel> updateProfile(
    @Path("lang") String lang,
    @Part(name: "CardNo") String cardNo,
    @Part(name: "FirstName") String? firstName,
    @Part(name: "LastName") String? lastName,
    @Part(name: "PhoneNumber") String? phoneNumber,
    @Part(name: "Email") String? email,
    @Part(name: "NationalId") String? nationalId,
    @Part(name: "PassportNumber") String? passportNumber,
    @Part(name: "Birthdate") String? birthdate,
    @Part(name: "IsMale") bool? isMale,
    @Part(name: "ProfileImage") MultipartFile? profileImage,
  );
}
