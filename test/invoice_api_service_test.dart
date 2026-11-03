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

  test('cancelInvoice sends the expected JSON body', () async {
    Map<String, dynamic>? requestData;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestData = Map<String, dynamic>.from(options.data as Map);
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'message': 'Invoice canceled successfully',
                  'data': null,
                },
              ),
            );
          },
        ),
      );

    final message = await InvoiceApiService(dio).cancelInvoice(
      lang: 'en',
      cardNo: '102021200305',
      invoiceId: 69,
      reason: 'Member requested cancellation',
    );

    expect(requestData, {
      'cardNo': '102021200305',
      'invoiceId': 69,
      'reason': 'Member requested cancellation',
    });
    expect(message, 'Invoice canceled successfully');
  });

  test('cancelInvoice preserves a backend failure message exactly', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': false,
                  'message': 'Only pending invoices can be canceled',
                  'data': null,
                },
              ),
            );
          },
        ),
      );

    expect(
      () => InvoiceApiService(dio).cancelInvoice(
        lang: 'en',
        cardNo: '123',
        invoiceId: 69,
        reason: 'reason',
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          'Only pending invoices can be canceled',
        ),
      ),
    );
  });
}
