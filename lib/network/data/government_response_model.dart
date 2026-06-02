import 'package:json_annotation/json_annotation.dart';

part 'government_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GovernmentResponse {
  final bool success;
  final String timestamp;
  final String message;
  final GovernmentData data;

  GovernmentResponse({
    required this.success,
    required this.timestamp,
    required this.message,
    required this.data,
  });

  factory GovernmentResponse.fromJson(Map<String, dynamic> json) =>
      _$GovernmentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GovernmentResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GovernmentData {
  final List<Government> governments;
  final Pagination pagination;

  GovernmentData({
    required this.governments,
    required this.pagination,
  });

  factory GovernmentData.fromJson(Map<String, dynamic> json) =>
      _$GovernmentDataFromJson(json);

  Map<String, dynamic> toJson() => _$GovernmentDataToJson(this);
}

@JsonSerializable()
class Government {
  final int id;
  final String name;

  Government({
    required this.id,
    required this.name,
  });

  factory Government.fromJson(Map<String, dynamic> json) =>
      _$GovernmentFromJson(json);

  Map<String, dynamic> toJson() => _$GovernmentToJson(this);
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

  // Helper method to get first error message
  String getFirstErrorMessage() {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.first.first;
    }
    return title;
  }

  // Helper method to get all error messages
  List<String> getAllErrorMessages() {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.expand((list) => list).toList();
    }
    return [title];
  }
}