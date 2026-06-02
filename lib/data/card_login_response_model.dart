import 'package:json_annotation/json_annotation.dart';

part 'card_login_response_model.g.dart';

@JsonSerializable()
class CardLoginResponseModel {
  final bool success;
  final String timestamp;
  final String message;
  final CardLoginDataModel? data;

  const CardLoginResponseModel({
    required this.success,
    required this.timestamp,
    required this.message,
    this.data,
  });

  factory CardLoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CardLoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardLoginResponseModelToJson(this);
}

@JsonSerializable()
class CardLoginDataModel {
  final String cardId;
  final String firstName;
  final String lasName; // Note: API has typo "lasName" instead of "lastName"

  const CardLoginDataModel({
    required this.cardId,
    required this.firstName,
    required this.lasName,
  });

  factory CardLoginDataModel.fromJson(Map<String, dynamic> json) =>
      _$CardLoginDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardLoginDataModelToJson(this);
}
