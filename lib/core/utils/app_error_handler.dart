import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/api_result.dart';
import '../network/app_failure.dart';
import '../theming/app_colors.dart';
import '../theming/app_toast.dart';

class AppErrorHandler {
  static String messageFromFailure(AppFailure failure) {
    switch (failure.type) {
      case AppFailureType.network:
        return 'errors.network_error'.tr();
      case AppFailureType.timeout:
        return 'errors.timeout_error'.tr();
      case AppFailureType.unauthorized:
        return 'errors.session_expired'.tr();
      case AppFailureType.forbidden:
        return 'errors.forbidden_error'.tr();
      case AppFailureType.notFound:
        return 'errors.not_found_error'.tr();
      case AppFailureType.server:
        return 'errors.server_error'.tr();
      case AppFailureType.unexpected:
        return failure.message ?? 'errors.generic_error'.tr();
    }
  }

  static String getUserFriendlyMessage(String error) {
    // Check if it's already a translation key
    if (error.startsWith('errors.')) {
      // Try to translate it directly
      try {
        final translated = error.tr();
        // If translation returns the same string, it means the key doesn't exist
        // Otherwise, return the translated string
        if (translated != error) {
          return translated;
        }
      } catch (e) {
        // If translation fails, continue with normal processing
      }
    }

    if (error.toLowerCase().contains('socketexception') ||
        error.toLowerCase().contains('network')) {
      return 'errors.network_error'.tr();
    }

    if (error.toLowerCase().contains('timeout')) {
      return 'errors.timeout_error'.tr();
    }

    if (error.contains('401')) {
      return 'errors.session_expired'.tr();
    }

    if (error.contains('403')) {
      return 'errors.forbidden_error'.tr();
    }

    if (error.contains('404')) {
      return 'errors.not_found_error'.tr();
    }

    if (error.contains('500') || error.contains('502') || error.contains('503')) {
      return 'errors.server_error'.tr();
    }

    return 'errors.generic_error'.tr();
  }

  static String _resolveMessage(Object error) {
    if (error is AppFailure) {
      return messageFromFailure(error);
    }
    return getUserFriendlyMessage(error.toString());
  }

  static void showErrorSnackBar(
      BuildContext context,
      Object error, {
        VoidCallback? onRetry,
        Duration duration = const Duration(seconds: 4),
      }) {
    final message = _resolveMessage(error);
    showErrorToast(message);
  }

  static void showErrorDialog(
      BuildContext context,
      Object error, {
        VoidCallback? onRetry,
      }) {
    final message = _resolveMessage(error);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.errorClr),
            const SizedBox(width: 8),
            Text('common.error'.tr()),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryClr,
              ),
              child: Text('common.retry'.tr()),
            ),
        ],
      ),
    );
  }

  static void logError(Object error, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Handle ApiResult and show appropriate error UI
  static void handleApiResult<T>(
      BuildContext context,
      ApiResult<T> result, {
        VoidCallback? onRetry,
        bool showDialog = false,
      }) {
    result.when(
      success: (_) {
        // Success - no action needed
      },
      failure: (message) {
        if (showDialog) {
          showErrorDialog(context, message, onRetry: onRetry);
        } else {
          showErrorSnackBar(context, message, onRetry: onRetry);
        }
      },
    );
  }

  /// Extract error message from ApiResult
  static String? getErrorMessageFromResult<T>(ApiResult<T> result) {
    return result.maybeWhen(
      failure: (message) => message,
      orElse: () => null,
    );
  }

  /// Check if ApiResult is a failure
  static bool isFailure<T>(ApiResult<T> result) {
    return result.maybeWhen(
      failure: (_) => true,
      orElse: () => false,
    );
  }
}