import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../network/app_failure.dart';
import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';
import 'app_error_handler.dart';

/// Reusable error state widget for displaying errors with retry option
class ErrorStateWidget extends StatelessWidget {
  final Object error;
  final String? title;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool showDetails;

  const ErrorStateWidget({
    super.key,
    required this.error,
    this.title,
    this.onRetry,
    this.icon,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get user-friendly message
    final message = _getErrorMessage(context);
    final displayTitle = title ?? 'common.error'.tr();

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Icon(
              icon ?? Icons.error_outline,
              size: 64.w,
              color: AppColors.errorClr,
            ),
            SizedBox(height: 16.h),

            // Error Title
            Text(
              displayTitle,
              style: AppTextStyles.font16BlackMedium(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),

            // Error Message
            Text(
              message,
              style: AppTextStyles.font14GreyRegular(context),
              textAlign: TextAlign.center,
            ),

            // Show details if enabled and error has details
            if (showDetails && error is AppFailure && (error as AppFailure).message != null) ...[
              SizedBox(height: 8.h),
              Text(
                (error as AppFailure).message!,
                style: AppTextStyles.font12GreyRegular(context),
                textAlign: TextAlign.center,
              ),
            ],

            // Retry Button
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text('common.retry'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryClr,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getErrorMessage(BuildContext context) {
    final currentError = error;
    if (currentError is AppFailure) {
      return AppErrorHandler.messageFromFailure(currentError);
    } else if (currentError is String) {
      return AppErrorHandler.getUserFriendlyMessage(currentError);
    } else {
      return AppErrorHandler.getUserFriendlyMessage(currentError.toString());
    }
  }
}

/// Compact error widget for inline errors
class CompactErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const CompactErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final message = _getErrorMessage(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20.w,
            color: AppColors.errorClr,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.font14GreyRegular(context),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text('common.retry'.tr()),
            ),
        ],
      ),
    );
  }

  String _getErrorMessage(BuildContext context) {
    final currentError = error;
    if (currentError is AppFailure) {
      return AppErrorHandler.messageFromFailure(currentError);
    } else if (currentError is String) {
      return AppErrorHandler.getUserFriendlyMessage(currentError);
    } else {
      return AppErrorHandler.getUserFriendlyMessage(currentError.toString());
    }
  }
}

