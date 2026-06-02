import 'package:json_annotation/json_annotation.dart';

part 'top_providers_slider_model.g.dart';

// ─── Root response ─────────────────────────────────────────────────────────
@JsonSerializable()
class TopProvidersSliderResponse {
  final bool success;
  final String message;
  final List<SliderProvider> data;

  const TopProvidersSliderResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TopProvidersSliderResponse.fromJson(Map<String, dynamic> json) =>
      _$TopProvidersSliderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TopProvidersSliderResponseToJson(this);
}

// ─── Single provider item ──────────────────────────────────────────────────
@JsonSerializable()
class SliderProvider {
  final int providerId;
  final String name;
  final String logo;

  const SliderProvider({
    required this.providerId,
    required this.name,
    required this.logo,
  });

  bool get hasLogo => logo.isNotEmpty;

  factory SliderProvider.fromJson(Map<String, dynamic> json) =>
      _$SliderProviderFromJson(json);

  Map<String, dynamic> toJson() => _$SliderProviderToJson(this);
}
