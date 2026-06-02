// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_activate_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardActivateRequestModel _$CardActivateRequestModelFromJson(
  Map<String, dynamic> json,
) => CardActivateRequestModel(
  cardNo: json['CardNo'] as String,
  phoneNumber: json['PhoneNumber'] as String,
  password: json['Password'] as String,
  confirmPassword: json['ConfirmPassword'] as String,
  firstName: json['FirstName'] as String,
  lastName: json['LastName'] as String,
  nationalId: json['NationalId'] as String?,
  birthdate: json['Birthdate'] as String,
  passportNumber: json['PassportNumber'] as String?,
  email: json['Email'] as String?,
  isMale: json['IsMale'] as bool,
  profileImage: json['ProfileImage'] as String?,
);

Map<String, dynamic> _$CardActivateRequestModelToJson(
  CardActivateRequestModel instance,
) => <String, dynamic>{
  'CardNo': instance.cardNo,
  'PhoneNumber': instance.phoneNumber,
  'Password': instance.password,
  'ConfirmPassword': instance.confirmPassword,
  'FirstName': instance.firstName,
  'LastName': instance.lastName,
  'NationalId': ?instance.nationalId,
  'Birthdate': instance.birthdate,
  'PassportNumber': ?instance.passportNumber,
  'Email': ?instance.email,
  'IsMale': instance.isMale,
  'ProfileImage': ?instance.profileImage,
};
