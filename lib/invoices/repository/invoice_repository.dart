import 'package:image_picker/image_picker.dart';

import '../data/invoice_models.dart';
import '../service/invoice_api_service.dart';

class InvoiceRepository {
  final InvoiceApiService _apiService;

  InvoiceRepository(this._apiService);

  Future<InvoicePage<InvoiceProvider>> getProviders({
    required String lang,
    String? search,
    int page = 1,
  }) => _apiService.getProviders(lang: lang, search: search, page: page);

  Future<InvoicePage<InvoiceBranch>> getProviderBranches({
    required String lang,
    required int providerId,
    int page = 1,
  }) => _apiService.getProviderBranches(
    lang: lang,
    providerId: providerId,
    page: page,
  );

  Future<CreatedInvoice> createInvoice({
    required String lang,
    required String cardNo,
    required int providerId,
    required int providerLocationId,
    required String notes,
    required XFile attachment,
  }) => _apiService.createInvoice(
    lang: lang,
    cardNo: cardNo,
    providerId: providerId,
    providerLocationId: providerLocationId,
    notes: notes,
    attachment: attachment,
  );

  Future<InvoicePage<InvoiceRecord>> getInvoices({
    required String lang,
    required String cardNo,
    String status = 'All',
    int page = 1,
  }) => _apiService.getInvoices(
    lang: lang,
    cardNo: cardNo,
    status: status,
    page: page,
  );
}
