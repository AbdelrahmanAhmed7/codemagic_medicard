import 'package:json_annotation/json_annotation.dart';

part 'card_activate_data_model.g.dart';

@JsonSerializable()
class CardActivateDataModel {
  @JsonKey(name: "cardId")
  final String cardId;

  @JsonKey(name: "firstName")
  final String firstName;

  @JsonKey(name: "lastName")
  final String lastName;

  @JsonKey(name: "mobile")
  final String mobile;

  @JsonKey(name: "birthdate")
  final String birthdate;

  @JsonKey(name: "expireDate")
  final String expireDate;

  @JsonKey(name: "isMale")
  final bool isMale;

  @JsonKey(name: "nationalId")
  final String? nationalId;

  @JsonKey(name: "passportNumber")
  final String? passportNumber;

  @JsonKey(name: "email")
  final String? email;

  @JsonKey(name: "profileImage")
  final String? profileImage;

  CardActivateDataModel({
    required this.cardId,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.birthdate,
    required this.expireDate,
    required this.isMale,
    this.nationalId,
    this.passportNumber,
    this.email,
    this.profileImage,
  });

  factory CardActivateDataModel.fromJson(Map<String, dynamic> json) =>
      _$CardActivateDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardActivateDataModelToJson(this);
}
