import 'package:json_annotation/json_annotation.dart';

part 'card_login_request_model.g.dart';

@JsonSerializable()
class CardLoginRequestModel {
  @JsonKey(name: "CardNo")
  final String cardNo;

  @JsonKey(name: "Password")
  final String password;

  const CardLoginRequestModel({
    required this.cardNo,
    required this.password,
  });

  factory CardLoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CardLoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardLoginRequestModelToJson(this);
}
