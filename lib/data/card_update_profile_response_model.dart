import 'package:json_annotation/json_annotation.dart';

part 'card_update_profile_response_model.g.dart';

@JsonSerializable()
class CardUpdateProfileResponseModel {
  final bool success;
  final String timestamp;
  final String message;
  final CardUpdateProfileDataModel? data;

  const CardUpdateProfileResponseModel({
    required this.success,
    required this.timestamp,
    required this.message,
    this.data,
  });

  factory CardUpdateProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CardUpdateProfileResponseModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CardUpdateProfileResponseModelToJson(this);
}

@JsonSerializable()
class CardUpdateProfileDataModel {
  final String cardId;
  final String firstName;
  final String lastName;
  final String mobile;
  final String? email;
  final String? nationalId;
  final String? passportNumber;
  final String birthdate;
  final bool isMale;
  final String? profileImage;

  const CardUpdateProfileDataModel({
    required this.cardId,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    this.email,
    this.nationalId,
    this.passportNumber,
    required this.birthdate,
    required this.isMale,
    this.profileImage,
  });

  factory CardUpdateProfileDataModel.fromJson(Map<String, dynamic> json) =>
      _$CardUpdateProfileDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardUpdateProfileDataModelToJson(this);
}