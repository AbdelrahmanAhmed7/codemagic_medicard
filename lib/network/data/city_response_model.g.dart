// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityResponse _$CityResponseFromJson(Map<String, dynamic> json) => CityResponse(
  success: json['success'] as bool,
  timestamp: json['timestamp'] as String,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : CityData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CityResponseToJson(CityResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'timestamp': instance.timestamp,
      'message': instance.message,
      'data': instance.data?.toJson(),
    };

CityData _$CityDataFromJson(Map<String, dynamic> json) => CityData(
  cities: (json['cities'] as List<dynamic>)
      .map((e) => City.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
  filter: CityFilter.fromJson(json['filter'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CityDataToJson(CityData instance) => <String, dynamic>{
  'cities': instance.cities.map((e) => e.toJson()).toList(),
  'pagination': instance.pagination.toJson(),
  'filter': instance.filter.toJson(),
};

City _$CityFromJson(Map<String, dynamic> json) => City(
  cityId: (json['cityId'] as num).toInt(),
  governmentId: (json['governmentId'] as num).toInt(),
  cityName: json['cityName'] as String,
  governmentName: json['governmentName'] as String,
);

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
  'cityId': instance.cityId,
  'governmentId': instance.governmentId,
  'cityName': instance.cityName,
  'governmentName': instance.governmentName,
};

CityFilter _$CityFilterFromJson(Map<String, dynamic> json) =>
    CityFilter(governmentId: (json['governmentId'] as num?)?.toInt());

Map<String, dynamic> _$CityFilterToJson(CityFilter instance) =>
    <String, dynamic>{'governmentId': instance.governmentId};

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
  currentPage: (json['currentPage'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalCount: (json['totalCount'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  hasNextPage: json['hasNextPage'] as bool,
  hasPreviousPage: json['hasPreviousPage'] as bool,
);

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'pageSize': instance.pageSize,
      'totalCount': instance.totalCount,
      'totalPages': instance.totalPages,
      'hasNextPage': instance.hasNextPage,
      'hasPreviousPage': instance.hasPreviousPage,
    };

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      type: json['type'] as String,
      title: json['title'] as String,
      status: (json['status'] as num).toInt(),
      errors: (json['errors'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      traceId: json['traceId'] as String?,
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'status': instance.status,
      'errors': instance.errors,
      'traceId': instance.traceId,
    };
