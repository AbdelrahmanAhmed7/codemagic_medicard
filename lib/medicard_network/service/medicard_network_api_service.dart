import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../network/data/city_response_model.dart';
import '../../network/data/government_response_model.dart';
import '../../network/data/network_category_response_model.dart';
import '../../network/data/network_provider_response_model.dart';
import '../../network/data/top_providers_slider_model.dart';

part 'medicard_network_api_service.g.dart';

@RestApi(baseUrl: 'https://api.medicardeg.com/api/')
abstract class MedicardNetworkApiService {
  factory MedicardNetworkApiService(Dio dio, {String baseUrl}) =
      _MedicardNetworkApiService;

  @GET("/{lang}/Network/GetCategories")
  Future<NetworkCategoryResponse> getCategories(@Path("lang") String lang);

  @GET("/{lang}/Network/GetNetwork")
  Future<NetworkProviderResponse> searchProviders(
    @Path("lang") String lang, {
    @Query("CardNo") String? cardNo,
    @Query("search") String? searchKey,
    @Query("categoryId") int? categoryId,
    @Query("governmentId") int? governmentId,
    @Query("cityId") int? cityId,
    @Query("latitude") double? latitude,
    @Query("longitude") double? longitude,
    @Query("type") int? type,
    @Query("OrderByDiscounts") bool? orderByDiscounts,
    @Query("page") int? page,
    @Query("pageSize") int? pageSize,
  });

  @GET("/{lang}/Network/GetGovernments")
  Future<GovernmentResponse> getGovernments(
    @Path("lang") String lang, {
    @Query("page") int? page,
    @Query("pageSize") int? pageSize,
  });

  @GET("/{lang}/Network/GetCities")
  Future<CityResponse> getCitiesByGovernment(
    @Path("lang") String lang, {
    @Query("governmentId") int? governmentId,
    @Query("page") int? page,
    @Query("pageSize") int? pageSize,
  });

  @GET("/{lang}/Network/GetTopProvidersForSlider")
  Future<TopProvidersSliderResponse> getTopProvidersForSlider(
    @Path("lang") String lang,
  );
}
