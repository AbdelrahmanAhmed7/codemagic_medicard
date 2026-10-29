import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/invoices/service/invoice_api_service.dart';

void main() {
  test('createInvoice sends an empty Notes field instead of null', () async {
    FormData? requestData;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestData = options.data as FormData;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true, 'data': <String, dynamic>{}},
              ),
            );
          },
        ),
      );

    await InvoiceApiService(dio).createInvoice(
      lang: 'en',
      cardNo: '123',
      providerId: 1,
      providerLocationId: 2,
      notes: '',
    );

    final notesFields = requestData!.fields
        .where((field) => field.key == 'Notes')
        .toList();
    expect(notesFields, hasLength(1));
    expect(notesFields.single.value, '');
  });
}
