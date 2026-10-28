// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_login_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardLoginRequestModel _$CardLoginRequestModelFromJson(
  Map<String, dynamic> json,
) => CardLoginRequestModel(
  cardNo: json['cardNo'] as String,
  password: json['password'] as String,
  firebaseToken: json['firebaseToken'] as String,
);

Map<String, dynamic> _$CardLoginRequestModelToJson(
  CardLoginRequestModel instance,
) => <String, dynamic>{
  'cardNo': instance.cardNo,
  'password': instance.password,
  'firebaseToken': instance.firebaseToken,
};
