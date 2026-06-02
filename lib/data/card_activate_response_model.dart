import 'package:json_annotation/json_annotation.dart';
import 'card_activate_data_model.dart';

part 'card_activate_response_model.g.dart';

@JsonSerializable()
class CardActivateResponseModel {
  @JsonKey(name: "success")
  final bool success;

  @JsonKey(name: "timestamp")
  final String timestamp;

  @JsonKey(name: "message")
  final String message;

  @JsonKey(name: "data")
  final CardActivateDataModel? data;

  CardActivateResponseModel({
    required this.success,
    required this.timestamp,
    required this.message,
    this.data,
  });

  factory CardActivateResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CardActivateResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardActivateResponseModelToJson(this);
}
