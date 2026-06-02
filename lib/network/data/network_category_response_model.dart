import 'package:json_annotation/json_annotation.dart';

part 'network_category_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class NetworkCategoryResponse {
  final bool success;
  final String timestamp;
  final String message;
  final NetworkCategoryData data;

  NetworkCategoryResponse({
    required this.success,
    required this.timestamp,
    required this.message,
    required this.data,
  });

  factory NetworkCategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$NetworkCategoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkCategoryResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class NetworkCategoryData {
  final List<NetworkCategory> categories;
  final int totalCount;

  NetworkCategoryData({
    required this.categories,
    required this.totalCount,
  });

  factory NetworkCategoryData.fromJson(Map<String, dynamic> json) =>
      _$NetworkCategoryDataFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkCategoryDataToJson(this);
}

@JsonSerializable()
class NetworkCategory {
  final int id;
  final String name;
  final String image;

  NetworkCategory({
    required this.id,
    required this.name,
    required this.image,
  });

  factory NetworkCategory.fromJson(Map<String, dynamic> json) =>
      _$NetworkCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkCategoryToJson(this);

  // Helper method to check if image exists
  bool get hasImage => image.isNotEmpty;
}