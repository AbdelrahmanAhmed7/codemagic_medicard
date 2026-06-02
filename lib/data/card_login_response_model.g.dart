// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_login_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardLoginResponseModel _$CardLoginResponseModelFromJson(
  Map<String, dynamic> json,
) => CardLoginResponseModel(
  success: json['success'] as bool,
  timestamp: json['timestamp'] as String,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : CardLoginDataModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CardLoginResponseModelToJson(
  CardLoginResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'timestamp': instance.timestamp,
  'message': instance.message,
  'data': instance.data,
};

CardLoginDataModel _$CardLoginDataModelFromJson(Map<String, dynamic> json) =>
    CardLoginDataModel(
      cardId: json['cardId'] as String,
      firstName: json['firstName'] as String,
      lasName: json['lasName'] as String,
    );

Map<String, dynamic> _$CardLoginDataModelToJson(CardLoginDataModel instance) =>
    <String, dynamic>{
      'cardId': instance.cardId,
      'firstName': instance.firstName,
      'lasName': instance.lasName,
    };
