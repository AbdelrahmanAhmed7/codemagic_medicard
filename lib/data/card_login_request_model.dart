import 'package:json_annotation/json_annotation.dart';

part 'card_login_request_model.g.dart';

@JsonSerializable()
class CardLoginRequestModel {
  @JsonKey(name: 'cardNo')
  final String cardNo;

  @JsonKey(name: 'password')
  final String password;

  @JsonKey(name: 'firebaseToken')
  final String firebaseToken;

  const CardLoginRequestModel({
    required this.cardNo,
    required this.password,
    required this.firebaseToken,
  });

  factory CardLoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CardLoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardLoginRequestModelToJson(this);
}
