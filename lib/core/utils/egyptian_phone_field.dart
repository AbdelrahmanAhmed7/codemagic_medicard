import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theming/app_colors.dart';

/// Reusable Egyptian phone number field with flag and +20 prefix
class EgyptianPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? hintText;
  final String phoneRequiredKey;
  final String phoneInvalidKey;
  final ValueChanged<String>? onChanged;
  final int? maxLength;

  const EgyptianPhoneField({
    super.key,
    required this.controller,
    this.validator,
    this.hintText,
    required this.phoneRequiredKey,
    required this.phoneInvalidKey,
    this.onChanged,
    this.maxLength
  });

  /// Default validator for Egyptian phone numbers
  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return phoneRequiredKey.tr();
    }
    // Remove leading 0 if user entered it for validation
    String cleanValue = value.startsWith('0') ? value.substring(1) : value;

    // Reject if empty after removing 0
    if (cleanValue.isEmpty) {
      return phoneRequiredKey.tr();
    }

    // Check if phone starts with 10, 11, 12, or 15 and has exactly 10 digits total
    // Allow only 10 digits (10xx xxxxxx)
    if (!RegExp(r'^(10|11|12|15)[0-9]{8}$').hasMatch(cleanValue)) {
      return phoneInvalidKey.tr();
    }
    return null;
  }

  /// Format phone number to always start with 0 for backend
  static String formatPhoneNumber(String rawPhoneNumber) {
    return rawPhoneNumber.startsWith('0') ? rawPhoneNumber : '0$rawPhoneNumber';
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    final effectiveValidator = validator ?? _defaultValidator;

    return FormField<String>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: effectiveValidator,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Directionality(
              textDirection: isRTL
                  ? ui.TextDirection.rtl
                  : ui.TextDirection.ltr,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: AppColors.whiteClr,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: isRTL
                          ? BorderRadius.only(
                        topRight: Radius.circular(8.r),
                        bottomRight: Radius.circular(8.r),
                      )
                          : BorderRadius.only(
                        topLeft: Radius.circular(8.r),
                        bottomLeft: Radius.circular(8.r),
                      ),
                    ),
                    child: Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🇪🇬', style: TextStyle(fontSize: 20.sp)),
                          SizedBox(width: 4.w),
                          Text(
                            '+20',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.whiteClr,
                        border: Border(
                          top: BorderSide(
                            color: fieldState.hasError
                                ? AppColors.errorClr
                                : Colors.grey.shade300,
                          ),
                          left: isRTL
                              ? BorderSide.none
                              : BorderSide(
                            color: fieldState.hasError
                                ? AppColors.errorClr
                                : Colors.grey.shade300,
                          ),
                          right: isRTL
                              ? BorderSide(
                            color: fieldState.hasError
                                ? AppColors.errorClr
                                : Colors.grey.shade300,
                          )
                              : BorderSide.none,
                          bottom: BorderSide(
                            color: fieldState.hasError
                                ? AppColors.errorClr
                                : Colors.grey.shade300,
                          ),
                        ),
                        borderRadius: isRTL
                            ? BorderRadius.only(
                          topLeft: Radius.circular(8.r),
                          bottomLeft: Radius.circular(8.r),
                        )
                            : BorderRadius.only(
                          topRight: Radius.circular(8.r),
                          bottomRight: Radius.circular(8.r),
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        maxLength: maxLength,
                        keyboardType: TextInputType.phone,
                        textDirection: ui.TextDirection.ltr,
                        style: TextStyle(fontSize: 14.sp),
                        onChanged: (value) {
                          fieldState.didChange(value);
                          fieldState.validate();
                          onChanged?.call(value);
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          hintText: hintText ?? 'auth.signup.validation.phone_hint'.tr(),
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: AppColors.whiteClr,
                          isDense: true,
                          counterText: "",
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (fieldState.hasError)
              Padding(
                padding: EdgeInsets.only(top: 6.h, left: 8.w),
                child: Text(
                  fieldState.errorText ?? '',
                  style: TextStyle(
                    color: AppColors.errorClr,
                    fontSize: 12.sp,
                    height: 1.2,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
