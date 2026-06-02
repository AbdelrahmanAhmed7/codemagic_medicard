// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_home_info_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardHomeInfoResponseModel _$CardHomeInfoResponseModelFromJson(
  Map<String, dynamic> json,
) => CardHomeInfoResponseModel(
  success: json['success'] as bool,
  timestamp: json['timestamp'] as String,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : CardHomeInfoDataModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CardHomeInfoResponseModelToJson(
  CardHomeInfoResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'timestamp': instance.timestamp,
  'message': instance.message,
  'data': instance.data,
};

CardHomeInfoDataModel _$CardHomeInfoDataModelFromJson(
  Map<String, dynamic> json,
) => CardHomeInfoDataModel(
  cardId: json['cardId'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  expireDate: json['expireDate'] as String,
  memberPhoto: json['memberPhoto'] as String?,
);

Map<String, dynamic> _$CardHomeInfoDataModelToJson(
  CardHomeInfoDataModel instance,
) => <String, dynamic>{
  'cardId': instance.cardId,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'expireDate': instance.expireDate,
  'memberPhoto': instance.memberPhoto,
};
