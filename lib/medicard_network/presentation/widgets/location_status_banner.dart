import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/location_service.dart';
import '../../core/network_colors.dart';

class LocationStatusBanner extends StatelessWidget {
  final LocationAccessStatus status;
  final VoidCallback? onRetry;
  final VoidCallback? onOpenSettings;

  const LocationStatusBanner({
    super.key,
    required this.status,
    this.onRetry,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    if (status == LocationAccessStatus.granted) {
      return const SizedBox.shrink();
    }

    final (message, actionLabel, onAction) = _resolveAction();

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: NC.primaryLt.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: NC.primaryLt.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_off_outlined, size: 18.sp, color: NC.primaryMid),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                color: NC.textMid,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(width: 8.w),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: NC.primaryMid,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  (String message, String? actionLabel, VoidCallback? onAction) _resolveAction() {
    switch (status) {
      case LocationAccessStatus.denied:
      case LocationAccessStatus.unavailable:
        return (
          'network.location_banner_denied'.tr(),
          'network.location_banner_retry'.tr(),
          onRetry,
        );
      case LocationAccessStatus.permanentlyDenied:
        return (
          'network.location_access_denied_body'.tr(),
          'network.open_app_settings'.tr(),
          onOpenSettings,
        );
      case LocationAccessStatus.serviceDisabled:
        return (
          'network.location_service_body'.tr(),
          'network.open_settings'.tr(),
          onOpenSettings,
        );
      case LocationAccessStatus.granted:
        return ('', null, null);
    }
  }
}
