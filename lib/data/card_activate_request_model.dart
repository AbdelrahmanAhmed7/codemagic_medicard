import 'package:json_annotation/json_annotation.dart';

part 'card_activate_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class CardActivateRequestModel {
  @JsonKey(name: "CardNo")
  final String cardNo;

  @JsonKey(name: "PhoneNumber")
  final String phoneNumber;

  @JsonKey(name: "Password")
  final String password;

  @JsonKey(name: "ConfirmPassword")
  final String confirmPassword;

  @JsonKey(name: "FirstName")
  final String firstName;

  @JsonKey(name: "LastName")
  final String lastName;

  @JsonKey(name: "NationalId")
  final String? nationalId;

  @JsonKey(name: "Birthdate")
  final String birthdate;

  @JsonKey(name: "PassportNumber")
  final String? passportNumber;

  @JsonKey(name: "Email")
  final String? email;

  @JsonKey(name: "IsMale")
  final bool isMale;

  @JsonKey(name: "ProfileImage")
  final String? profileImage;

  CardActivateRequestModel({
    required this.cardNo,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    this.nationalId,
    required this.birthdate,
    this.passportNumber,
    this.email,
    required this.isMale,
    this.profileImage,
  });

  Map<String, dynamic> toJson() => _$CardActivateRequestModelToJson(this);
}
