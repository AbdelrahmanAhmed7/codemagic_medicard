import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback? onEnablePressed;
  final VoidCallback? onMaybeLaterPressed;

  const LocationPermissionDialog({
    super.key,
    this.onEnablePressed,
    this.onMaybeLaterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop();
          onMaybeLaterPressed?.call();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _LocationIcon(),
              SizedBox(height: 24.h),
              const _Title(),
              SizedBox(height: 12.h),
              const _Message(),
              SizedBox(height: 32.h),
              _EnableLocationButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onEnablePressed?.call();
                  });
                },
              ),
              SizedBox(height: 12.h),
              _MaybeLaterButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onMaybeLaterPressed?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show dialog helper
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onEnablePressed,
    VoidCallback? onMaybeLaterPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LocationPermissionDialog(
        onEnablePressed: onEnablePressed,
        onMaybeLaterPressed: onMaybeLaterPressed,
      ),
    );
  }
}

class _LocationIcon extends StatelessWidget {
  const _LocationIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryClr.withValues(alpha: 0.1),
            AppColors.primaryClr.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: AppColors.primaryClr.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.location_on,
            size: 40.sp,
            color: AppColors.primaryClr,
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Text(
      'location_permission.title'.tr(),
      style: AppTextStyles.font20BlackSemiBold(context),
      textAlign: TextAlign.center,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message();

  @override
  Widget build(BuildContext context) {
    return Text(
      'location_permission.message'.tr(),
      style: AppTextStyles.font14GreyRegular(context),
      textAlign: TextAlign.center,
    );
  }
}

class _EnableLocationButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _EnableLocationButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryClr,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'location_permission.enable_button'.tr(),
          style: AppTextStyles.font16WhiteMedium(context),
        ),
      ),
    );
  }
}

class _MaybeLaterButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _MaybeLaterButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'location_permission.maybe_later'.tr(),
          style: AppTextStyles.font14GreyRegular(
            context,
          ).copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
