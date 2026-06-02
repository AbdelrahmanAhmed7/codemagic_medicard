// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_update_profile_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardUpdateProfileResponseModel _$CardUpdateProfileResponseModelFromJson(
  Map<String, dynamic> json,
) => CardUpdateProfileResponseModel(
  success: json['success'] as bool,
  timestamp: json['timestamp'] as String,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : CardUpdateProfileDataModel.fromJson(
          json['data'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$CardUpdateProfileResponseModelToJson(
  CardUpdateProfileResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'timestamp': instance.timestamp,
  'message': instance.message,
  'data': instance.data,
};

CardUpdateProfileDataModel _$CardUpdateProfileDataModelFromJson(
  Map<String, dynamic> json,
) => CardUpdateProfileDataModel(
  cardId: json['cardId'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  mobile: json['mobile'] as String,
  email: json['email'] as String?,
  nationalId: json['nationalId'] as String?,
  passportNumber: json['passportNumber'] as String?,
  birthdate: json['birthdate'] as String,
  isMale: json['isMale'] as bool,
  profileImage: json['profileImage'] as String?,
);

Map<String, dynamic> _$CardUpdateProfileDataModelToJson(
  CardUpdateProfileDataModel instance,
) => <String, dynamic>{
  'cardId': instance.cardId,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'mobile': instance.mobile,
  'email': instance.email,
  'nationalId': instance.nationalId,
  'passportNumber': instance.passportNumber,
  'birthdate': instance.birthdate,
  'isMale': instance.isMale,
  'profileImage': instance.profileImage,
};
