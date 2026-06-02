// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_category_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkCategoryResponse _$NetworkCategoryResponseFromJson(
  Map<String, dynamic> json,
) => NetworkCategoryResponse(
  success: json['success'] as bool,
  timestamp: json['timestamp'] as String,
  message: json['message'] as String,
  data: NetworkCategoryData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NetworkCategoryResponseToJson(
  NetworkCategoryResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'timestamp': instance.timestamp,
  'message': instance.message,
  'data': instance.data.toJson(),
};

NetworkCategoryData _$NetworkCategoryDataFromJson(Map<String, dynamic> json) =>
    NetworkCategoryData(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => NetworkCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
    );

Map<String, dynamic> _$NetworkCategoryDataToJson(
  NetworkCategoryData instance,
) => <String, dynamic>{
  'categories': instance.categories.map((e) => e.toJson()).toList(),
  'totalCount': instance.totalCount,
};

NetworkCategory _$NetworkCategoryFromJson(Map<String, dynamic> json) =>
    NetworkCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      image: json['image'] as String,
    );

Map<String, dynamic> _$NetworkCategoryToJson(NetworkCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
    };
