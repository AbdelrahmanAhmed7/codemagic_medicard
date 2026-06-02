// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'government_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GovernmentResponse _$GovernmentResponseFromJson(Map<String, dynamic> json) =>
    GovernmentResponse(
      success: json['success'] as bool,
      timestamp: json['timestamp'] as String,
      message: json['message'] as String,
      data: GovernmentData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GovernmentResponseToJson(GovernmentResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'timestamp': instance.timestamp,
      'message': instance.message,
      'data': instance.data.toJson(),
    };

GovernmentData _$GovernmentDataFromJson(Map<String, dynamic> json) =>
    GovernmentData(
      governments: (json['governments'] as List<dynamic>)
          .map((e) => Government.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$GovernmentDataToJson(GovernmentData instance) =>
    <String, dynamic>{
      'governments': instance.governments.map((e) => e.toJson()).toList(),
      'pagination': instance.pagination.toJson(),
    };

Government _$GovernmentFromJson(Map<String, dynamic> json) =>
    Government(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$GovernmentToJson(Government instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

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
