// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_provider_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkProviderResponse _$NetworkProviderResponseFromJson(
  Map<String, dynamic> json,
) => NetworkProviderResponse(
  success: json['success'] as bool,
  timestamp: json['timestamp'] as String,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : NetworkProviderData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NetworkProviderResponseToJson(
  NetworkProviderResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'timestamp': instance.timestamp,
  'message': instance.message,
  'data': instance.data?.toJson(),
};

NetworkProviderData _$NetworkProviderDataFromJson(Map<String, dynamic> json) =>
    NetworkProviderData(
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => NetworkCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      providers: (json['providers'] as List<dynamic>)
          .map((e) => NetworkProvider.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
      userLocation: json['userLocation'] == null
          ? null
          : UserLocation.fromJson(json['userLocation'] as Map<String, dynamic>),
      searchTerm: json['searchTerm'] as String?,
      categoryId: (json['categoryId'] as num?)?.toInt(),
      governmentId: (json['governmentId'] as num?)?.toInt(),
      cityId: (json['cityId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NetworkProviderDataToJson(
  NetworkProviderData instance,
) => <String, dynamic>{
  'categories': instance.categories?.map((e) => e.toJson()).toList(),
  'providers': instance.providers.map((e) => e.toJson()).toList(),
  'pagination': instance.pagination?.toJson(),
  'userLocation': instance.userLocation?.toJson(),
  'searchTerm': instance.searchTerm,
  'categoryId': instance.categoryId,
  'governmentId': instance.governmentId,
  'cityId': instance.cityId,
};

NetworkProvider _$NetworkProviderFromJson(Map<String, dynamic> json) =>
    NetworkProvider(
      providerId: (json['providerId'] as num).toInt(),
      locationId: (json['locationId'] as num).toInt(),
      providerName: json['providerName'] as String,
      providerLogo: json['providerLogo'] as String,
      categoryName: json['categoryName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      government: json['government'] as String,
      city: json['city'] as String,
      area: json['area'] as String,
      address: json['address'] as String,
      fullAddress: json['fullAddress'] as String,
      mapsUrl: json['mapsUrl'] as String,
      mobile: json['mobile'] as String,
      hotline: json['hotline'] as String,
      distance: (json['distance'] as num?)?.toDouble(),
      discount: json['discount'] as String?,
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => NetworkService.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NetworkProviderToJson(NetworkProvider instance) =>
    <String, dynamic>{
      'providerId': instance.providerId,
      'locationId': instance.locationId,
      'providerName': instance.providerName,
      'providerLogo': instance.providerLogo,
      'categoryName': instance.categoryName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'government': instance.government,
      'city': instance.city,
      'area': instance.area,
      'address': instance.address,
      'fullAddress': instance.fullAddress,
      'mapsUrl': instance.mapsUrl,
      'mobile': instance.mobile,
      'hotline': instance.hotline,
      'distance': instance.distance,
      'discount': instance.discount,
      'services': instance.services,
    };

NetworkService _$NetworkServiceFromJson(Map<String, dynamic> json) =>
    NetworkService(
      serviceId: (json['serviceId'] as num).toInt(),
      serviceName: json['serviceName'] as String,
      discount: json['discount'] as String,
    );

Map<String, dynamic> _$NetworkServiceToJson(NetworkService instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'discount': instance.discount,
    };

UserLocation _$UserLocationFromJson(Map<String, dynamic> json) => UserLocation(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$UserLocationToJson(UserLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

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
