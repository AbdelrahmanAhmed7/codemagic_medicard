// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_update_profile_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardUpdateProfileRequestModel _$CardUpdateProfileRequestModelFromJson(
  Map<String, dynamic> json,
) => CardUpdateProfileRequestModel(
  cardNo: json['cardNo'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  email: json['email'] as String?,
  nationalId: json['nationalId'] as String?,
  passportNumber: json['passportNumber'] as String?,
  birthdate: json['birthdate'] as String?,
  isMale: json['isMale'] as bool?,
  profileImage: json['profileImage'] as String?,
);

Map<String, dynamic> _$CardUpdateProfileRequestModelToJson(
  CardUpdateProfileRequestModel instance,
) => <String, dynamic>{
  'cardNo': instance.cardNo,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phoneNumber': instance.phoneNumber,
  'email': instance.email,
  'nationalId': instance.nationalId,
  'passportNumber': instance.passportNumber,
  'birthdate': instance.birthdate,
  'isMale': instance.isMale,
  'profileImage': instance.profileImage,
};
