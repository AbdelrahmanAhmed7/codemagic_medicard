import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../network/data/network_provider_response_model.dart';
import '../../core/network_colors.dart';

class ServicesDialog extends StatelessWidget {
  final String providerName;
  final String providerLogo;
  final String categoryName;
  final List<NetworkService> services;

  const ServicesDialog({
    super.key,
    required this.providerName,
    required this.providerLogo,
    required this.categoryName,
    required this.services,
  });

  // ─── Static helper so the call site stays one line ────────────────────────
  static void show(
    BuildContext context, {
    required String providerName,
    required String providerLogo,
    required String categoryName,
    required List<NetworkService> services,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => ServicesDialog(
        providerName: providerName,
        providerLogo: providerLogo,
        categoryName: categoryName,
        services: services,
      ),
    );
  }

  Color get _catColor => networkCatColor(categoryName);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Container(
        decoration: BoxDecoration(
          color: NC.surface,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ────────────────────────────────────────────────────
            _DialogHeader(
              providerName: providerName,
              providerLogo: providerLogo,
              categoryName: categoryName,
              catColor: _catColor,
              onClose: () => Navigator.of(context).pop(),
            ),

            // ── Divider ───────────────────────────────────────────────────
            Divider(color: NC.border, height: 1),

            // ── Services list ─────────────────────────────────────────────
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: services.length,
                separatorBuilder: (_, _) => Divider(
                  color: NC.border,
                  height: 1,
                  indent: 20.w,
                  endIndent: 20.w,
                ),
                itemBuilder: (_, i) => _ServiceRow(service: services[i]),
              ),
            ),

            // ── Footer ────────────────────────────────────────────────────
            _DialogFooter(
              totalServices: services.length,
              onClose: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _DialogHeader extends StatelessWidget {
  final String providerName;
  final String providerLogo;
  final String categoryName;
  final Color catColor;
  final VoidCallback onClose;

  const _DialogHeader({
    required this.providerName,
    required this.providerLogo,
    required this.categoryName,
    required this.catColor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        // Subtle tinted background matching category color
        color: catColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          _ProviderLogoSmall(logoUrl: providerLogo, catColor: catColor),
          SizedBox(width: 12.w),

          // Name + category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                Text(
                  providerName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: catColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: catColor,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.local_offer_rounded,
                        size: 11.sp, color: NC.success),
                    SizedBox(width: 4.w),
                    Text(
                      'network.available_services_discounts'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: NC.textMid,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Close button
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: NC.surface,
                shape: BoxShape.circle,
                border: Border.all(color: NC.border),
              ),
              child: Icon(Icons.close_rounded, size: 15.sp, color: NC.textMid),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Small logo ───────────────────────────────────────────────────────────────
class _ProviderLogoSmall extends StatelessWidget {
  final String logoUrl;
  final Color catColor;

  const _ProviderLogoSmall({required this.logoUrl, required this.catColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        color: NC.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: catColor.withValues(alpha: 0.2), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.r),
        child: logoUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: logoUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Center(
                  child: SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: CircularProgressIndicator(
                      color: NC.primaryMid,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => _LogoFallback(color: catColor),
              )
            : _LogoFallback(color: catColor),
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  final Color color;
  const _LogoFallback({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.local_hospital_rounded,
        size: 26.sp,
        color: color.withValues(alpha: 0.35),
      ),
    );
  }
}

// ─── Service row ──────────────────────────────────────────────────────────────
class _ServiceRow extends StatelessWidget {
  final NetworkService service;

  const _ServiceRow({required this.service});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          // Dot indicator
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: NC.success,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.w),

          // Service name
          Expanded(
            child: Text(
              service.serviceName,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),

          // Discount badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: NC.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: NC.success.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.percent_rounded,
                    size: 10.sp, color: const Color(0xFF059669)),
                SizedBox(width: 2.w),
                Text(
                  service.discount,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────
class _DialogFooter extends StatelessWidget {
  final int totalServices;
  final VoidCallback onClose;

  const _DialogFooter({required this.totalServices, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: NC.surface2,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
        border: Border(top: BorderSide(color: NC.border)),
      ),
      child: Row(
        children: [
          // Total count badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: NC.primaryLt.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: NC.primaryLt.withValues(alpha: 0.2)),
            ),
            child: Text(
              'network.available_service_count'
                  .tr(args: [totalServices.toString()]),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: NC.primaryMid,
              ),
            ),
          ),
          const Spacer(),
          // Close button
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [NC.primary, NC.primaryMid],
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: NC.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                'common.cancel'.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}