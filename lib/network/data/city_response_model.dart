import 'package:json_annotation/json_annotation.dart';

part 'city_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CityResponse {
  final bool success;
  final String timestamp;
  final String message;
  final CityData? data;

  CityResponse({
    required this.success,
    required this.timestamp,
    required this.message,
    this.data,
  });

  factory CityResponse.fromJson(Map<String, dynamic> json) =>
      _$CityResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CityResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CityData {
  final List<City> cities;
  final Pagination pagination;
  final CityFilter filter;

  CityData({
    required this.cities,
    required this.pagination,
    required this.filter,
  });

  factory CityData.fromJson(Map<String, dynamic> json) =>
      _$CityDataFromJson(json);

  Map<String, dynamic> toJson() => _$CityDataToJson(this);
}

@JsonSerializable()
class City {
  final int cityId;
  final int governmentId;
  final String cityName;
  final String governmentName;

  City({
    required this.cityId,
    required this.governmentId,
    required this.cityName,
    required this.governmentName,
  });

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);

  Map<String, dynamic> toJson() => _$CityToJson(this);
}

@JsonSerializable()
class CityFilter {
  final int? governmentId;

  CityFilter({
    this.governmentId,
  });

  factory CityFilter.fromJson(Map<String, dynamic> json) =>
      _$CityFilterFromJson(json);

  Map<String, dynamic> toJson() => _$CityFilterToJson(this);
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

// Error Response

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

  List<String> getAllErrorMessages() {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.expand((list) => list).toList();
    }
    return [title];
  }
}
