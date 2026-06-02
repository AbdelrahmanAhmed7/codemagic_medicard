import 'dart:io';
import 'package:dio/dio.dart';
import '../core/constants/api_result.dart';
import '../core/network/api_error_handler.dart';
import '../core/cache/cache_service.dart';
import '../data/card_activate_request_model.dart';
import '../data/card_activate_response_model.dart';
import '../data/card_home_info_response_model.dart';
import '../data/card_login_request_model.dart';
import '../data/card_login_response_model.dart';
import '../data/card_personal_info_response_model.dart';
import '../data/card_support_contact_response_model.dart';
import '../data/card_update_profile_request_model.dart';
import '../data/card_update_profile_response_model.dart';
import '../domain/medicard_repository.dart';
import '../service/medicard_api_service.dart';

class MedicardRepositoryImpl implements MedicardRepository {
  final MedicardApiService _apiService;

  MedicardRepositoryImpl(this._apiService);

  @override
  Future<ApiResult<CardActivateResponseModel>> activateCard(
    CardActivateRequestModel request,
    String lang,
  ) async {
    try {
      final response = await _apiService.activateCard(
        lang,
        request.cardNo,
        request.phoneNumber,
        request.password,
        request.confirmPassword,
        request.firstName,
        request.lastName,
        request.nationalId,
        request.birthdate,
        request.passportNumber,
        request.email,
        request.isMale,
        request.profileImage,
      );

      return response.success
          ? ApiResult.success(response)
          : ApiResult.failure(
              response.message.isNotEmpty
                  ? response.message
                  : 'Card activation failed.',
            );
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<CardLoginResponseModel>> login(
    CardLoginRequestModel request,
    String lang,
  ) async {
    try {
      final response = await _apiService.login(lang, request);

      return (response.success && response.data != null)
          ? ApiResult.success(response)
          : ApiResult.failure(
              response.message.isNotEmpty ? response.message : 'Login failed.',
            );
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<CardHomeInfoResponseModel>> getHomeInfo(
    String cardNo,
    String lang,
  ) async {
    try {
      final response = await _apiService.getHomeInfo(lang, cardNo);

      return (response.success && response.data != null)
          ? ApiResult.success(response)
          : ApiResult.failure(
              response.message.isNotEmpty
                  ? response.message
                  : 'Failed to get home info.',
            );
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<CardPersonalInfoResponseModel>> getPersonalInfo(
    String cardNo,
    String lang,
  ) async {
    try {
      final response = await _apiService.getPersonalInfo(lang, cardNo);

      return (response.success && response.data != null)
          ? ApiResult.success(response)
          : ApiResult.failure(
              response.message.isNotEmpty
                  ? response.message
                  : 'Failed to get personal info.',
            );
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<CardSupportContactResponseModel>> getSupportContacts(
    String lang,
  ) async {
    try {
      // Try to get from cache first
      final cachedData = await CacheService.getCachedSupportContactsData();
      if (cachedData != null) {
        return ApiResult.success(
          CardSupportContactResponseModel.fromJson(cachedData),
        );
      }

      // If not in cache, get from API
      final response = await _apiService.getSupportContacts(lang);

      if (response.success && response.data != null) {
        // Cache the response
        await CacheService.cacheSupportContactsData(response.toJson());
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to get support contacts.',
        );
      }
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<CardUpdateProfileResponseModel>> updateProfile(
    CardUpdateProfileRequestModel request,
    String lang,
  ) async {
    try {
      MultipartFile? imagePart;

      if (request.profileImage != null &&
          request.profileImage!.isNotEmpty &&
          !request.profileImage!.startsWith('http')) {
        final file = File(request.profileImage!);

        if (await file.exists()) {
          imagePart = await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          );
        }
      }

      final response = await _apiService.updateProfile(
        lang,
        request.cardNo,
        request.firstName?.trim() ?? "",
        request.lastName?.trim() ?? "",
        request.phoneNumber?.trim() ?? "",
        request.email?.trim() ?? "",
        request.nationalId?.trim() ?? "",
        request.passportNumber?.trim() ?? "",
        request.birthdate,
        request.isMale,
        imagePart,
      );

      if (response.success) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update profile.',
        );
      }
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
