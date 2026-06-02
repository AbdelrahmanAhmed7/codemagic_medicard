// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_activate_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardActivateResponseModel _$CardActivateResponseModelFromJson(
  Map<String, dynamic> json,
) => CardActivateResponseModel(
  success: json['success'] as bool,
  timestamp: json['timestamp'] as String,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : CardActivateDataModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CardActivateResponseModelToJson(
  CardActivateResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'timestamp': instance.timestamp,
  'message': instance.message,
  'data': instance.data,
};
