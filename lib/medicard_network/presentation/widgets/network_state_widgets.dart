import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/network_colors.dart';

// ─── Shimmer Loading ──────────────────────────────────────────────────────────
class NetworkShimmerList extends StatelessWidget {
  const NetworkShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats ribbon placeholder
            Container(
              margin: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),

            // Categories Title placeholder
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
              child: Container(
                width: 70.w,
                height: 14.h,
                color: Colors.white,
              ),
            ),

            // Categories row placeholder
            SizedBox(
              height: 40.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                itemCount: 5,
                itemBuilder: (_, _) => Container(
                  width: 80.w,
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                ),
              ),
            ),

            // Filters panel placeholder
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(width: 4.w, height: 18.h, color: Colors.white),
                      SizedBox(width: 8.w),
                      Container(width: 100.w, height: 14.h, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Container(
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Provider cards placeholders
            ...List.generate(
              3,
              (_) => Container(
                margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                height: 160.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────
class NetworkErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const NetworkErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: NC.danger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 38.sp, color: NC.danger),
            ),
            SizedBox(height: 20.h),
            Text(
              'common.error'.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: NC.danger,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: NC.textMid, height: 1.6),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [NC.primary, NC.primaryMid]),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: NC.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'common.retry'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class NetworkEmptyState extends StatelessWidget {
  /// Pass the current search term so we can show smarter messaging + suggestions
  final String? searchTerm;
  final ValueChanged<String>? onSuggestionTap;

  const NetworkEmptyState({
    super.key,
    this.searchTerm,
    this.onSuggestionTap,
  });

  static List<(String, IconData)> get _suggestions => [
        ('network.hospital_suggestion'.tr(), Icons.local_hospital_rounded),
        ('network.clinic_suggestion'.tr(), Icons.medical_services_rounded),
        ('network.pharmacy_suggestion'.tr(), Icons.medication_rounded),
        ('network.dental_suggestion'.tr(), Icons.health_and_safety_rounded),
        ('network.lab_suggestion'.tr(), Icons.biotech_rounded),
        ('network.scan_suggestion'.tr(), Icons.settings_input_antenna_rounded),
      ];

  bool get _hasSearch => searchTerm != null && searchTerm!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: NC.primaryLt.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _hasSearch ? Icons.search_off_rounded : Icons.inbox_rounded,
                size: 44.sp,
                color: NC.primaryLt.withValues(alpha: 0.4),
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              _hasSearch
                  ? 'network.no_results_for'.tr(args: [searchTerm!])
                  : 'network.no_results'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              _hasSearch
                  ? 'network.try_different_search'.tr()
                  : 'network.try_changing_filters'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: NC.textMid, height: 1.7),
            ),

            // Suggestions (only when there's an active search)
            if (_hasSearch && onSuggestionTap != null) ...[
              SizedBox(height: 24.h),
              Text(
                'network.search_instead_in'.tr(),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: NC.textLight,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                alignment: WrapAlignment.center,
                children: _suggestions.map((s) {
                  final (label, icon) = s;
                  return _SuggestionChip(
                    label: label,
                    icon: icon,
                    onTap: () => onSuggestionTap!(label),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: NC.surface,
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(color: NC.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13.sp, color: NC.primaryMid),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}