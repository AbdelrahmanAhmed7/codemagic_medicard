// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_login_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardLoginRequestModel _$CardLoginRequestModelFromJson(
  Map<String, dynamic> json,
) => CardLoginRequestModel(
  cardNo: json['CardNo'] as String,
  password: json['Password'] as String,
);

Map<String, dynamic> _$CardLoginRequestModelToJson(
  CardLoginRequestModel instance,
) => <String, dynamic>{
  'CardNo': instance.cardNo,
  'Password': instance.password,
};
