import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'network_colors.dart';

class MapsLauncher {
  MapsLauncher._();

  static Future<void> showPicker(
    BuildContext context, {
    required double lat,
    required double lng,
    String? fallbackUrl,
  }) async {
    if (lat == 0 && lng == 0) {
      if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
        await launchUrl(
          Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication,
        );
      }
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: NC.surface,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (sheetContext) => _MapsPickerSheet(lat: lat, lng: lng),
    );
  }

  static Future<void> openAppleMaps(double lat, double lng) async {
    final uri = Uri.parse('maps://maps.apple.com/?q=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    final web = Uri.parse('https://maps.apple.com/?q=$lat,$lng');
    await launchUrl(web, mode: LaunchMode.externalApplication);
  }

  static Future<void> openGoogleMaps(double lat, double lng) async {
    final nav = Uri.parse('google.navigation:q=$lat,$lng');
    if (await canLaunchUrl(nav)) {
      await launchUrl(nav, mode: LaunchMode.externalApplication);
      return;
    }

    final web = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    await launchUrl(web, mode: LaunchMode.externalApplication);
  }
}

class _MapsPickerSheet extends StatelessWidget {
  const _MapsPickerSheet({required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: NC.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Text(
            'network.choose_maps_app'.tr(),
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 20.h),
          _MapsOptionTile(
            icon: Icons.map_rounded,
            label: 'network.apple_maps'.tr(),
            onTap: () async {
              Navigator.pop(context);
              await MapsLauncher.openAppleMaps(lat, lng);
            },
          ),
          SizedBox(height: 10.h),
          _MapsOptionTile(
            icon: Icons.navigation_rounded,
            label: 'network.google_maps'.tr(),
            onTap: () async {
              Navigator.pop(context);
              await MapsLauncher.openGoogleMaps(lat, lng);
            },
          ),
        ],
      ),
    );
  }
}

class _MapsOptionTile extends StatelessWidget {
  const _MapsOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NC.surface2,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(icon, color: NC.primary, size: 22.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: NC.textLight, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}
