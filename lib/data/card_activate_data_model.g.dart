// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_activate_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardActivateDataModel _$CardActivateDataModelFromJson(
  Map<String, dynamic> json,
) => CardActivateDataModel(
  cardId: json['cardId'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  mobile: json['mobile'] as String,
  birthdate: json['birthdate'] as String,
  expireDate: json['expireDate'] as String,
  isMale: json['isMale'] as bool,
  nationalId: json['nationalId'] as String?,
  passportNumber: json['passportNumber'] as String?,
  email: json['email'] as String?,
  profileImage: json['profileImage'] as String?,
);

Map<String, dynamic> _$CardActivateDataModelToJson(
  CardActivateDataModel instance,
) => <String, dynamic>{
  'cardId': instance.cardId,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'mobile': instance.mobile,
  'birthdate': instance.birthdate,
  'expireDate': instance.expireDate,
  'isMale': instance.isMale,
  'nationalId': instance.nationalId,
  'passportNumber': instance.passportNumber,
  'email': instance.email,
  'profileImage': instance.profileImage,
};
