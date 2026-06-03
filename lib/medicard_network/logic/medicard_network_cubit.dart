import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/api_result.dart';
import '../../core/services/location_service.dart';
import '../../network/data/city_response_model.dart';
import '../../network/data/government_response_model.dart';
import '../../network/data/network_category_response_model.dart';
import '../../network/data/network_provider_response_model.dart';
import '../../core/constants/constants.dart';
import '../../core/helpers/shared_pref_helper.dart';
import '../repository/medicard_network_repository.dart';

abstract class MedicardNetworkState {}

class MedicardNetworkInitial extends MedicardNetworkState {}

class MedicardNetworkLoading extends MedicardNetworkState {}

class MedicardNetworkLoaded extends MedicardNetworkState {
  final List<NetworkCategory> categories;
  final List<NetworkProvider> providers;
  final List<Government> governments;
  final List<City> cities;
  final int? selectedCategoryId;
  final int? selectedGovernmentId;
  final int? selectedCityId;
  final String? searchKey;
  final bool orderByDiscounts;
  final bool hasMore;
  final double? latitude;
  final double? longitude;
  final LocationAccessStatus? locationStatus;
  final bool isLocationLoading;
  final bool isLoading;

  MedicardNetworkLoaded({
    required this.categories,
    required this.providers,
    required this.governments,
    required this.cities,
    this.selectedCategoryId,
    this.selectedGovernmentId,
    this.selectedCityId,
    this.searchKey,
    this.orderByDiscounts = false,
    this.hasMore = false,
    this.latitude,
    this.longitude,
    this.locationStatus,
    this.isLocationLoading = false,
    this.isLoading = false,
  });

  MedicardNetworkLoaded copyWith({
    List<NetworkCategory>? categories,
    List<NetworkProvider>? providers,
    List<Government>? governments,
    List<City>? cities,
    int? selectedCategoryId,
    bool resetCategory = false,
    int? selectedGovernmentId,
    bool resetGovernment = false,
    int? selectedCityId,
    bool resetCity = false,
    String? searchKey,
    bool resetSearch = false,
    bool? orderByDiscounts,
    bool? hasMore,
    double? latitude,
    bool resetLocation = false,
    double? longitude,
    LocationAccessStatus? locationStatus,
    bool resetLocationStatus = false,
    bool? isLocationLoading,
    bool? isLoading,
  }) {
    return MedicardNetworkLoaded(
      categories: categories ?? this.categories,
      providers: providers ?? this.providers,
      governments: governments ?? this.governments,
      cities: cities ?? this.cities,
      selectedCategoryId: resetCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      selectedGovernmentId: resetGovernment
          ? null
          : (selectedGovernmentId ?? this.selectedGovernmentId),
      selectedCityId: resetCity
          ? null
          : (selectedCityId ?? this.selectedCityId),
      searchKey: resetSearch ? null : (searchKey ?? this.searchKey),
      orderByDiscounts: orderByDiscounts ?? this.orderByDiscounts,
      hasMore: hasMore ?? this.hasMore,
      latitude: resetLocation ? null : (latitude ?? this.latitude),
      longitude: resetLocation ? null : (longitude ?? this.longitude),
      locationStatus: resetLocationStatus
          ? null
          : (locationStatus ?? this.locationStatus),
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MedicardNetworkError extends MedicardNetworkState {
  final String message;

  MedicardNetworkError(this.message);
}

class MedicardNetworkCubit extends Cubit<MedicardNetworkState> {
  final MedicardNetworkRepository _repository;
  int _currentPage = 1;
  static const int _pageSize = 20;

  MedicardNetworkCubit(this._repository) : super(MedicardNetworkInitial());

  Future<void> loadInitialData(
    String lang, {
    double? latitude,
    double? longitude,
    LocationAccessStatus? locationStatus,
    String? initialSearchQuery,
  }) async {
    emit(MedicardNetworkLoading());

    List<NetworkCategory> categories = [];
    List<Government> governments = [];

    final categoriesResult = await _repository.getCategories(lang);
    final governmentsResult = await _repository.getGovernments(lang);

    categoriesResult.when(
      success: (response) => categories = response.data.categories,
      failure: (_) {},
    );

    governmentsResult.when(
      success: (response) => governments = response.data.governments,
      failure: (_) {},
    );

    emit(
      MedicardNetworkLoaded(
        categories: categories,
        providers: [],
        governments: governments,
        cities: [],
        latitude: latitude,
        longitude: longitude,
        locationStatus: locationStatus,
        searchKey: initialSearchQuery,
      ),
    );

    _searchProviders(lang);
  }

  Future<void> _searchProviders(String lang) async {
    final currentState = state;
    int? categoryId;
    int? governmentId;
    int? cityId;
    String? searchKey;
    double? latitude;
    double? longitude;
    bool orderByDiscounts = false;

    if (currentState is MedicardNetworkLoaded) {
      categoryId = currentState.selectedCategoryId;
      governmentId = currentState.selectedGovernmentId;
      cityId = currentState.selectedCityId;
      searchKey = currentState.searchKey;
      latitude = currentState.latitude;
      longitude = currentState.longitude;
      orderByDiscounts = currentState.orderByDiscounts;
    }

    // ── debug only ─────────────────────────────────────────────────────────
    if (kDebugMode) {
      debugPrint(
        '🔍 _searchProviders → lat=$latitude, lng=$longitude, search=$searchKey',
      );
    }

    final cardNo = await SharedPrefHelper.getString(
      SharedPrefKeys.medicardCardNo,
    );

    if (currentState is MedicardNetworkLoaded) {
      emit(currentState.copyWith(isLoading: true));
    }

    final result = await _repository.searchProviders(
      lang: lang,
      cardNo: cardNo.isEmpty ? null : cardNo,
      searchKey: searchKey,
      categoryId: categoryId,
      governmentId: governmentId,
      cityId: cityId,
      latitude: latitude,
      longitude: longitude,
      orderByDiscounts: orderByDiscounts,
      page: _currentPage,
      pageSize: _pageSize,
    );

    result.when(
      success: (response) {
        final latestState = state;
        List<NetworkProvider> allProviders = [];
        bool hasMore = false;

        if (response.data != null) {
          if (latestState is MedicardNetworkLoaded && _currentPage > 1) {
            allProviders = [
              ...latestState.providers,
              ...response.data!.providers,
            ];
          } else {
            allProviders = response.data!.providers;
          }
          hasMore = response.data!.pagination?.hasNextPage ?? false;
        }

        if (latestState is MedicardNetworkLoaded) {
          emit(
            latestState.copyWith(
              providers: allProviders,
              hasMore: hasMore,
              isLocationLoading: false,
              isLoading: false, // Done loading
              // Pass actual values and explicitly reset if they are null
              selectedCategoryId: categoryId,
              resetCategory: categoryId == null,
              selectedGovernmentId: governmentId,
              resetGovernment: governmentId == null,
              selectedCityId: cityId,
              resetCity: cityId == null,
              searchKey: searchKey,
              resetSearch: searchKey == null || searchKey.isEmpty,
              orderByDiscounts: orderByDiscounts,
              latitude: latitude,
              longitude: longitude,
            ),
          );
        }
      },
      failure: (message) {
        final latestState = state;
        if (latestState is MedicardNetworkLoaded) {
          emit(latestState.copyWith(isLoading: false));
        } else {
          emit(MedicardNetworkError(message));
        }
      },
    );
  }

  void selectCategory(int? categoryId, String lang) {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded) {
      _currentPage = 1;
      emit(
        currentState.copyWith(
          selectedCategoryId: categoryId,
          resetCategory: categoryId == null,
          providers: [],
          isLoading: true, // Start loading
        ),
      );
      _searchProviders(lang);
    }
  }

  Future<void> selectGovernment(int? governmentId, String lang) async {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded) {
      _currentPage = 1;

      // Update state immediately: reset gov/city and clear results
      emit(
        currentState.copyWith(
          selectedGovernmentId: governmentId,
          resetGovernment: governmentId == null,
          resetCity: true,
          cities: [],
          providers: [],
          isLoading: true, // Start loading
        ),
      );

      // Trigger search immediately with the new government
      _searchProviders(lang);

      // Async fetch cities for the dropdown
      if (governmentId != null) {
        final citiesResult = await _repository.getCitiesByGovernment(
          lang,
          governmentId,
        );
        citiesResult.when(
          success: (response) {
            // Check if we haven't changed government again during the call
            final latestState = state;
            if (latestState is MedicardNetworkLoaded &&
                latestState.selectedGovernmentId == governmentId) {
              emit(latestState.copyWith(cities: response.data?.cities ?? []));
            }
          },
          failure: (_) {},
        );
      }
    }
  }

  void selectCity(int? cityId, String lang) {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded) {
      _currentPage = 1;
      emit(
        currentState.copyWith(
          selectedCityId: cityId,
          resetCity: cityId == null,
          providers: [],
          isLoading: true, // Start loading
        ),
      );
      _searchProviders(lang);
    }
  }

  void search(String? searchKey, String lang) {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded) {
      _currentPage = 1;
      emit(
        currentState.copyWith(
          searchKey: searchKey,
          resetSearch: searchKey == null || searchKey.isEmpty,
          providers: [],
          isLoading: true, // Start loading
        ),
      );
      _searchProviders(lang);
    }
  }

  void loadMore(String lang) {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded && currentState.hasMore) {
      _currentPage++;
      _searchProviders(lang);
    }
  }

  void clearFilters(String lang) {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded) {
      _currentPage = 1;
      emit(
        currentState.copyWith(
          resetCategory: true,
          resetGovernment: true,
          resetCity: true,
          resetSearch: true,
          cities: [],
          providers: [],
          isLoading: true, // Start loading
        ),
      );
      _searchProviders(lang);
    }
  }

  void toggleOrderByDiscounts(String lang) {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded) {
      _currentPage = 1;
      emit(
        currentState.copyWith(
          orderByDiscounts: !currentState.orderByDiscounts,
          providers: [],
          isLoading: true,
        ),
      );
      _searchProviders(lang);
    }
  }

  /// Updates coordinates and re-fetches providers sorted by distance.
  void updateLocationAndRefresh(
    String lang, {
    required double latitude,
    required double longitude,
    LocationAccessStatus locationStatus = LocationAccessStatus.granted,
  }) {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded) {
      if (currentState.latitude == latitude &&
          currentState.longitude == longitude &&
          currentState.locationStatus == locationStatus) {
        return;
      }

      _currentPage = 1;
      emit(
        currentState.copyWith(
          latitude: latitude,
          longitude: longitude,
          locationStatus: locationStatus,
          providers: [],
          isLoading: true,
          isLocationLoading: false,
        ),
      );
      _searchProviders(lang);
    } else {
      loadInitialData(
        lang,
        latitude: latitude,
        longitude: longitude,
        locationStatus: locationStatus,
      );
    }
  }

  void applyLocationResult(String lang, LocationResult result) {
    final currentState = state;
    if (currentState is! MedicardNetworkLoaded) return;

    if (result.hasCoordinates) {
      updateLocationAndRefresh(
        lang,
        latitude: result.latitude!,
        longitude: result.longitude!,
        locationStatus: result.status,
      );
      return;
    }

    emit(
      currentState.copyWith(resetLocation: true, locationStatus: result.status),
    );
  }
}
