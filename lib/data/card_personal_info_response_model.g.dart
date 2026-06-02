// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_personal_info_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardPersonalInfoResponseModel _$CardPersonalInfoResponseModelFromJson(
  Map<String, dynamic> json,
) => CardPersonalInfoResponseModel(
  success: json['success'] as bool,
  timestamp: json['timestamp'] as String,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : CardPersonalInfoDataModel.fromJson(
          json['data'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$CardPersonalInfoResponseModelToJson(
  CardPersonalInfoResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'timestamp': instance.timestamp,
  'message': instance.message,
  'data': instance.data,
};

CardPersonalInfoDataModel _$CardPersonalInfoDataModelFromJson(
  Map<String, dynamic> json,
) => CardPersonalInfoDataModel(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  image: json['image'] as String?,
  cardId: json['cardId'] as String,
  mobile: json['mobile'] as String,
  birthdate: json['birthdate'] as String,
  isMale: json['isMale'] as bool,
  passport: json['passport'] as String?,
  email: json['email'] as String?,
  nationalId: json['nationalId'] as String?,
  activatedDate: json['activatedDate'] as String,
  expireDate: json['expireDate'] as String,
);

Map<String, dynamic> _$CardPersonalInfoDataModelToJson(
  CardPersonalInfoDataModel instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'image': instance.image,
  'cardId': instance.cardId,
  'mobile': instance.mobile,
  'birthdate': instance.birthdate,
  'isMale': instance.isMale,
  'passport': instance.passport,
  'email': instance.email,
  'nationalId': instance.nationalId,
  'activatedDate': instance.activatedDate,
  'expireDate': instance.expireDate,
};
