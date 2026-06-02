import 'package:json_annotation/json_annotation.dart';

part 'card_personal_info_response_model.g.dart';

@JsonSerializable()
class CardPersonalInfoResponseModel {
  final bool success;
  final String timestamp;
  final String message;
  final CardPersonalInfoDataModel? data;

  const CardPersonalInfoResponseModel({
    required this.success,
    required this.timestamp,
    required this.message,
    this.data,
  });

  factory CardPersonalInfoResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CardPersonalInfoResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardPersonalInfoResponseModelToJson(this);
}

@JsonSerializable()
class CardPersonalInfoDataModel {
  final String firstName;
  final String lastName;
  final String? image;
  final String cardId;
  final String mobile;
  final String birthdate;
  final bool isMale;
  final String? passport;
  final String? email;
  final String? nationalId;
  final String activatedDate;
  final String expireDate;

  const CardPersonalInfoDataModel({
    required this.firstName,
    required this.lastName,
    this.image,
    required this.cardId,
    required this.mobile,
    required this.birthdate,
    required this.isMale,
    this.passport,
    this.email,
    this.nationalId,
    required this.activatedDate,
    required this.expireDate,
  });

  factory CardPersonalInfoDataModel.fromJson(Map<String, dynamic> json) =>
      _$CardPersonalInfoDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardPersonalInfoDataModelToJson(this);
}
