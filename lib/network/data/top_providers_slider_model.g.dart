// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_providers_slider_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopProvidersSliderResponse _$TopProvidersSliderResponseFromJson(
  Map<String, dynamic> json,
) => TopProvidersSliderResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => SliderProvider.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TopProvidersSliderResponseToJson(
  TopProvidersSliderResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

SliderProvider _$SliderProviderFromJson(Map<String, dynamic> json) =>
    SliderProvider(
      providerId: (json['providerId'] as num).toInt(),
      name: json['name'] as String,
      logo: json['logo'] as String,
    );

Map<String, dynamic> _$SliderProviderToJson(SliderProvider instance) =>
    <String, dynamic>{
      'providerId': instance.providerId,
      'name': instance.name,
      'logo': instance.logo,
    };
