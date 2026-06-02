// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicard_api_service.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main

class _MedicardApiService implements MedicardApiService {
  _MedicardApiService(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= 'https://api.medicardeg.com/api/';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<CardActivateResponseModel> activateCard(
    String lang,
    String cardNo,
    String phoneNumber,
    String password,
    String confirmPassword,
    String firstName,
    String lastName,
    String? nationalId,
    String birthdate,
    String? passportNumber,
    String? email,
    bool isMale,
    String? profileImage,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry('CardNo', cardNo));
    _data.fields.add(MapEntry('PhoneNumber', phoneNumber));
    _data.fields.add(MapEntry('Password', password));
    _data.fields.add(MapEntry('ConfirmPassword', confirmPassword));
    _data.fields.add(MapEntry('FirstName', firstName));
    _data.fields.add(MapEntry('LastName', lastName));
    if (nationalId != null) {
      _data.fields.add(MapEntry('NationalId', nationalId));
    }
    _data.fields.add(MapEntry('Birthdate', birthdate));
    if (passportNumber != null) {
      _data.fields.add(MapEntry('PassportNumber', passportNumber));
    }
    if (email != null) {
      _data.fields.add(MapEntry('Email', email));
    }
    _data.fields.add(MapEntry('IsMale', isMale.toString()));
    if (profileImage != null) {
      _data.fields.add(MapEntry('ProfileImage', profileImage));
    }
    final _options = _setStreamType<CardActivateResponseModel>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data',
          )
          .compose(
            _dio.options,
            '${lang}/Auth/CardActivate',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CardActivateResponseModel _value;
    try {
      _value = CardActivateResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<CardLoginResponseModel> login(
    String lang,
    CardLoginRequestModel request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<CardLoginResponseModel>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '${lang}/Auth/Login',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CardLoginResponseModel _value;
    try {
      _value = CardLoginResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<CardHomeInfoResponseModel> getHomeInfo(
    String lang,
    String cardNo,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'CardNo': cardNo};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<CardHomeInfoResponseModel>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '${lang}/Home/GetHomeInfo',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CardHomeInfoResponseModel _value;
    try {
      _value = CardHomeInfoResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<CardPersonalInfoResponseModel> getPersonalInfo(
    String lang,
    String cardNo,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'CardNo': cardNo};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<CardPersonalInfoResponseModel>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '${lang}/Profile/GetPersonalInfo',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CardPersonalInfoResponseModel _value;
    try {
      _value = CardPersonalInfoResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<CardSupportContactResponseModel> getSupportContacts(
    String lang,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<CardSupportContactResponseModel>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '${lang}/ContactUs/Get',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CardSupportContactResponseModel _value;
    try {
      _value = CardSupportContactResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<CardUpdateProfileResponseModel> updateProfile(
    String lang,
    String cardNo,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? nationalId,
    String? passportNumber,
    String? birthdate,
    bool? isMale,
    MultipartFile? profileImage,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry('CardNo', cardNo));
    if (firstName != null) {
      _data.fields.add(MapEntry('FirstName', firstName));
    }
    if (lastName != null) {
      _data.fields.add(MapEntry('LastName', lastName));
    }
    if (phoneNumber != null) {
      _data.fields.add(MapEntry('PhoneNumber', phoneNumber));
    }
    if (email != null) {
      _data.fields.add(MapEntry('Email', email));
    }
    if (nationalId != null) {
      _data.fields.add(MapEntry('NationalId', nationalId));
    }
    if (passportNumber != null) {
      _data.fields.add(MapEntry('PassportNumber', passportNumber));
    }
    if (birthdate != null) {
      _data.fields.add(MapEntry('Birthdate', birthdate));
    }
    if (isMale != null) {
      _data.fields.add(MapEntry('IsMale', isMale.toString()));
    }
    if (profileImage != null) {
      _data.files.add(MapEntry('ProfileImage', profileImage));
    }
    final _options = _setStreamType<CardUpdateProfileResponseModel>(
      Options(
            method: 'PUT',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data',
          )
          .compose(
            _dio.options,
            '${lang}/Profile/UpdateProfile',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CardUpdateProfileResponseModel _value;
    try {
      _value = CardUpdateProfileResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
