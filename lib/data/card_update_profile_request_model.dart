import 'package:json_annotation/json_annotation.dart';

part 'card_update_profile_request_model.g.dart';

@JsonSerializable()
class CardUpdateProfileRequestModel {
  final String cardNo;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? email;
  final String? nationalId;
  final String? passportNumber;
  final String? birthdate;
  final bool? isMale;
  final String? profileImage;

  const CardUpdateProfileRequestModel({
    required this.cardNo,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.email,
    this.nationalId,
    this.passportNumber,
    this.birthdate,
    this.isMale,
    this.profileImage,
  });

  factory CardUpdateProfileRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CardUpdateProfileRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardUpdateProfileRequestModelToJson(this);
}
