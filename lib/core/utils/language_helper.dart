import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Helper class to get current language code throughout the app
///
/// Usage in widgets with context:
/// ```dart
/// LanguageHelper.getLanguageCode(context)
/// ```
///
/// Usage in cubits/repositories (pass from widget):
/// ```dart
/// // In widget:
/// context.read<MyCubit>().getData(LanguageHelper.getLanguageCode(context));
/// ```
class LanguageHelper {
  /// Get current language code from context
  /// This is the recommended way to get language code
  static String getLanguageCode(BuildContext context) {
    return context.locale.languageCode;
  }

  /// Converts Arabic and Persian numerals to English numerals
  static String convertArabicToEnglishNumerals(String input) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const persianNumerals = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const englishNumerals = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(arabicNumerals[i], englishNumerals[i]);
      result = result.replaceAll(persianNumerals[i], englishNumerals[i]);
    }
    return result;
  }
}
