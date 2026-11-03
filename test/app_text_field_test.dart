import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/utils/app_text_field.dart';

void main() {
  testWidgets('validation sees a controller value restored with the field', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: '01012345678');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, child) => MaterialApp(home: child),
        child: Scaffold(
          body: Form(
            key: formKey,
            child: AppTextField(
              controller: controller,
              validator: (value) => (value ?? '').isEmpty ? 'required' : null,
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('required'), findsNothing);
  });
}
