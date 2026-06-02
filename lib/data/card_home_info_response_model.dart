import 'package:json_annotation/json_annotation.dart';

part 'card_home_info_response_model.g.dart';

@JsonSerializable()
class CardHomeInfoResponseModel {
  final bool success;
  final String timestamp;
  final String message;
  final CardHomeInfoDataModel? data;

  const CardHomeInfoResponseModel({
    required this.success,
    required this.timestamp,
    required this.message,
    this.data,
  });

  factory CardHomeInfoResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CardHomeInfoResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardHomeInfoResponseModelToJson(this);
}

@JsonSerializable()
class CardHomeInfoDataModel {
  final String cardId;
  final String firstName;
  final String lastName;
  final String expireDate;
  final String? memberPhoto;

  const CardHomeInfoDataModel({
    required this.cardId,
    required this.firstName,
    required this.lastName,
    required this.expireDate,
    this.memberPhoto,
  });

  factory CardHomeInfoDataModel.fromJson(Map<String, dynamic> json) =>
      _$CardHomeInfoDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardHomeInfoDataModelToJson(this);
}
