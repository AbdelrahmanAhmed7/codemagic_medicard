import '../../core/constants/api_result.dart';
import '../../network/data/city_response_model.dart';
import '../../network/data/government_response_model.dart';
import '../../network/data/network_category_response_model.dart';
import '../../network/data/network_provider_response_model.dart';
import '../../network/data/top_providers_slider_model.dart';
import '../service/medicard_network_api_service.dart';

class MedicardNetworkRepository {
  final MedicardNetworkApiService _apiService;

  MedicardNetworkRepository(this._apiService);

  Future<ApiResult<NetworkCategoryResponse>> getCategories(String lang) async {
    try {
      final response = await _apiService.getCategories(lang);
      if (response.success) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message);
      }
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<NetworkProviderResponse>> searchProviders({
    required String lang,
    String? cardNo,
    String? searchKey,
    int? categoryId,
    int? governmentId,
    int? cityId,
    double? latitude,
    double? longitude,
    int? type,
    bool? orderByDiscounts,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.searchProviders(
        lang,
        cardNo: cardNo,
        searchKey: searchKey,
        categoryId: categoryId,
        governmentId: governmentId,
        cityId: cityId,
        latitude: latitude,
        longitude: longitude,
        type: type,
        orderByDiscounts: orderByDiscounts,
        page: page,
        pageSize: pageSize,
      );
      if (response.success) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message);
      }
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<GovernmentResponse>> getGovernments(
    String lang, {
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _apiService.getGovernments(
        lang,
        page: page,
        pageSize: pageSize,
      );
      if (response.success) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message);
      }
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<CityResponse>> getCitiesByGovernment(
    String lang,
    int governmentId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _apiService.getCitiesByGovernment(
        lang,
        governmentId: governmentId,
        page: page,
        pageSize: pageSize,
      );
      if (response.success) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message);
      }
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<TopProvidersSliderResponse>> getTopProvidersForSlider(
    String lang,
  ) async {
    try {
      final response = await _apiService.getTopProvidersForSlider(lang);
      if (response.success) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message);
      }
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
