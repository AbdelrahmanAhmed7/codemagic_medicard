import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../data/invoice_models.dart';

class InvoiceApiService {
  static const String _baseUrl = 'https://api.medicardeg.com/api';
  final Dio _dio;

  InvoiceApiService(this._dio);

  Future<InvoicePage<InvoiceProvider>> getProviders({
    required String lang,
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/$lang/Invoices/GetProviders',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'pageSize': pageSize,
      },
    );
    final body = _requireSuccess(response.data);
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return InvoicePage<InvoiceProvider>.fromJson(
      data,
      (items) => items
          .map((item) => InvoiceProvider.fromJson(item as Map<String, dynamic>))
          .toList(),
      'providers',
    );
  }

  Future<InvoicePage<InvoiceBranch>> getProviderBranches({
    required String lang,
    required int providerId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/$lang/Invoices/GetProviderBranches',
      queryParameters: {
        'providerId': providerId,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final body = _requireSuccess(response.data);
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return InvoicePage<InvoiceBranch>.fromJson(
      data,
      (items) => items
          .map((item) => InvoiceBranch.fromJson(item as Map<String, dynamic>))
          .toList(),
      'branches',
    );
  }

  Future<CreatedInvoice> createInvoice({
    required String lang,
    required String cardNo,
    required int providerId,
    required int providerLocationId,
    required String notes,
    XFile? attachment,
  }) async {
    final formData = FormData()
      ..fields.addAll([
        MapEntry('CardNo', cardNo),
        MapEntry('ProviderId', providerId.toString()),
        MapEntry('ProviderLocationId', providerLocationId.toString()),
        MapEntry('Notes', notes),
      ]);
    if (attachment != null) {
      formData.files.add(
        MapEntry(
          'Attachments',
          await MultipartFile.fromFile(
            attachment.path,
            filename: attachment.name,
          ),
        ),
      );
    }
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/$lang/Invoices/Create',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final body = _requireSuccess(response.data);
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return CreatedInvoice.fromJson(data);
  }

  Future<InvoicePage<InvoiceRecord>> getInvoices({
    required String lang,
    required String cardNo,
    String status = 'All',
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/$lang/Invoices/GetInvoices',
      queryParameters: {
        'cardNo': cardNo,
        'page': page,
        'pageSize': pageSize,
        'status': status,
      },
    );
    final body = _requireSuccess(response.data);
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return InvoicePage<InvoiceRecord>.fromJson(
      data,
      (items) => items
          .map((item) => InvoiceRecord.fromJson(item as Map<String, dynamic>))
          .toList(),
      'invoices',
    );
  }

  Map<String, dynamic> _requireSuccess(Map<String, dynamic>? response) {
    if (response == null) {
      throw const FormatException(
        'The invoices API returned an empty response',
      );
    }
    if (response['success'] != true) {
      final message = response['message'] as String?;
      throw StateError(
        message?.isNotEmpty == true
            ? message!
            : 'The invoices API request failed',
      );
    }
    return response;
  }
}
