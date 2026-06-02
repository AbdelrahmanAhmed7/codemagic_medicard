import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medicard/core/theming/app_colors.dart';

import '../services/haptic_feedback_service.dart';

enum SnackBarType { success, error, warning, info }

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
  SnackBarType? type,
  VoidCallback? onAction,
  String? actionLabel,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  // Trigger haptic feedback based on type
  final effectiveType =
      type ?? (isError ? SnackBarType.error : SnackBarType.success);
  if (effectiveType == SnackBarType.error) {
    HapticFeedbackService.instance.heavyImpact();
  } else if (effectiveType == SnackBarType.success) {
    HapticFeedbackService.instance.lightImpact();
  }

  // Hide any existing snackbar
  messenger.hideCurrentSnackBar();

  final snackBarConfig = _getSnackBarConfig(effectiveType);

  messenger.showSnackBar(
    SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: duration,
      dismissDirection: DismissDirection.horizontal,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      content: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            gradient: snackBarConfig.gradient,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: snackBarConfig.shadowColor,
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: AppColors.primaryClr.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon container with subtle background
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  snackBarConfig.icon,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              // Message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snackBarConfig.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Action button or close
              if (onAction != null && actionLabel != null) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    messenger.hideCurrentSnackBar();
                    onAction();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      actionLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => messenger.hideCurrentSnackBar(),
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );

  // Force hide after duration
  Future.delayed(duration, () {
    if (context.mounted) {
      messenger.hideCurrentSnackBar();
    }
  });
}

class _SnackBarConfig {
  final Gradient gradient;
  final IconData icon;
  final String title;
  final Color shadowColor;

  const _SnackBarConfig({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.shadowColor,
  });
}

_SnackBarConfig _getSnackBarConfig(SnackBarType type) {
  switch (type) {
    case SnackBarType.success:
      return _SnackBarConfig(
        gradient: AppColors.primaryGradient,
        icon: Icons.check_circle_rounded,
        title: 'Success',
        shadowColor: AppColors.primaryShadowClr,
      );
    case SnackBarType.error:
      return _SnackBarConfig(
        gradient: AppColors.primaryGradient,
        icon: Icons.error_rounded,
        title: 'Error',
        shadowColor: AppColors.primaryShadowClr,
      );
    case SnackBarType.warning:
      return _SnackBarConfig(
        gradient: AppColors.primaryGradient,
        icon: Icons.warning_rounded,
        title: 'Warning',
        shadowColor: AppColors.primaryShadowClr,
      );
    case SnackBarType.info:
      return _SnackBarConfig(
        gradient: AppColors.primaryGradient,
        icon: Icons.info_rounded,
        title: 'Info',
        shadowColor: AppColors.primaryShadowClr,
      );
  }
}

/// Show a simple toast-style message at the bottom
void showSimpleToast(BuildContext context, String message) {
  showAppSnackBar(
    context,
    message,
    type: SnackBarType.info,
    duration: const Duration(seconds: 2),
  );
}
