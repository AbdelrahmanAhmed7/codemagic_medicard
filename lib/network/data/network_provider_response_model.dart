import 'package:json_annotation/json_annotation.dart';

import 'network_category_response_model.dart';

part 'network_provider_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class NetworkProviderResponse {
  final bool success;
  final String timestamp;
  final String message;
  final NetworkProviderData? data;

  NetworkProviderResponse({
    required this.success,
    required this.timestamp,
    required this.message,
    this.data,
  });

  factory NetworkProviderResponse.fromJson(Map<String, dynamic> json) =>
      _$NetworkProviderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkProviderResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class NetworkProviderData {
  final List<NetworkCategory>? categories;
  final List<NetworkProvider> providers;
  final Pagination? pagination;
  final UserLocation? userLocation;
  final String? searchTerm;
  final int? categoryId;
  final int? governmentId;
  final int? cityId;

  NetworkProviderData({
    this.categories,
    required this.providers,
    this.pagination,
    this.userLocation,
    this.searchTerm,
    this.categoryId,
    this.governmentId,
    this.cityId,
  });

  factory NetworkProviderData.fromJson(Map<String, dynamic> json) =>
      _$NetworkProviderDataFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkProviderDataToJson(this);

  bool get hasFilters =>
      categoryId != null ||
      governmentId != null ||
      cityId != null ||
      (searchTerm != null && searchTerm!.isNotEmpty);

  bool get hasUserLocation => userLocation != null;
  bool get hasProviders => providers.isNotEmpty;
}

@JsonSerializable()
class NetworkProvider {
  final int providerId;
  final int locationId;
  final String providerName;
  @JsonKey(defaultValue: '')
  final String providerLogo;
  @JsonKey(defaultValue: '')
  final String categoryName;
  final double latitude;
  final double longitude;
  @JsonKey(defaultValue: '')
  final String government;
  @JsonKey(defaultValue: '')
  final String city;
  @JsonKey(defaultValue: '')
  final String area;
  @JsonKey(defaultValue: '')
  final String address;
  @JsonKey(defaultValue: '')
  final String fullAddress;
  @JsonKey(defaultValue: '')
  final String mapsUrl;
  @JsonKey(defaultValue: '')
  final String mobile;
  @JsonKey(defaultValue: '')
  final String hotline;
  final double? distance;
  final String? discount;
  final List<NetworkService>? services;

  NetworkProvider({
    required this.providerId,
    required this.locationId,
    required this.providerName,
    required this.providerLogo,
    required this.categoryName,
    required this.latitude,
    required this.longitude,
    required this.government,
    required this.city,
    required this.area,
    required this.address,
    required this.fullAddress,
    required this.mapsUrl,
    required this.mobile,
    required this.hotline,
    this.distance,
    this.discount,
    this.services,
  });

  factory NetworkProvider.fromJson(Map<String, dynamic> json) =>
      _$NetworkProviderFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkProviderToJson(this);

  bool get hasLogo => providerLogo.isNotEmpty;
  bool get hasHotline => hotline.isNotEmpty;
  bool get hasDistance => distance != null;
  bool get hasAddress => address.isNotEmpty;
  bool get hasArea => area.isNotEmpty;
  bool get hasDiscount => discount != null && discount != '0.00';

  String get displayPhone => hotline.isNotEmpty ? hotline : mobile;

  String get formattedDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toInt()} m';
    }
    return '${distance!.toStringAsFixed(1)} km';
  }
}

@JsonSerializable()
class NetworkService {
  final int serviceId;
  final String serviceName;
  final String discount;

  NetworkService({
    required this.serviceId,
    required this.serviceName,
    required this.discount,
  });

  factory NetworkService.fromJson(Map<String, dynamic> json) =>
      _$NetworkServiceFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkServiceToJson(this);
}

@JsonSerializable()
class UserLocation {
  final double latitude;
  final double longitude;

  UserLocation({required this.latitude, required this.longitude});

  factory UserLocation.fromJson(Map<String, dynamic> json) =>
      _$UserLocationFromJson(json);

  Map<String, dynamic> toJson() => _$UserLocationToJson(this);
}

@JsonSerializable()
class Pagination {
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  Pagination({
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}

@JsonSerializable()
class ErrorResponse {
  final String type;
  final String title;
  final int status;
  final Map<String, List<String>>? errors;
  final String? traceId;

  ErrorResponse({
    required this.type,
    required this.title,
    required this.status,
    this.errors,
    this.traceId,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);

  String getFirstErrorMessage() {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.first.first;
    }
    return title;
  }
}
