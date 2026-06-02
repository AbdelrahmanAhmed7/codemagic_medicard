import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../network/data/network_provider_response_model.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../core/network_colors.dart';

class ProviderCard extends StatelessWidget {
  final NetworkProvider provider;
  final ValueChanged<String> onCall;
  final Function(double, double, String?) onMaps;
  final VoidCallback onShowServices;
  final VoidCallback? onTap;

  const ProviderCard({
    super.key,
    required this.provider,
    required this.onCall,
    required this.onMaps,
    required this.onShowServices,
    this.onTap,
  });

  Color get _color => networkCatColor(provider.categoryName);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 14.h),
      decoration: BoxDecoration(
        color: NC.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: NC.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored top strip
            Container(
              height: 3.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_color, _color.withValues(alpha: 0.5)],
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    children: [
                      // Header row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ProviderLogo(logoUrl: provider.providerLogo),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.providerName,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 7.h),
                                Row(
                                  children: [
                                    _CategoryTag(
                                      label: provider.categoryName,
                                      color: _color,
                                    ),
                                    const Spacer(),
                                    if (provider.distance != null)
                                      _DistanceBadge(
                                        distance: provider.distance!,
                                      ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                _AddressRow(
                                  fullAddress: provider.fullAddress,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Services
                      if (provider.services != null &&
                          provider.services!.isNotEmpty)
                        _ServicesPreview(
                          services: provider.services!,
                          onShowAll: onShowServices,
                        ),
                      // Divider
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Divider(color: NC.border, height: 1),
                      ),
                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 6.w,
                              runSpacing: 6.h,
                              children: [
                                if (provider.hotline.isNotEmpty)
                                  ...provider.hotline
                                      .split(RegExp(r'[,\s/]+'))
                                      .where((e) => e.isNotEmpty)
                                      .map(
                                        (number) => _PhoneChip(
                                          number: number.trim(),
                                          isHotline: true,
                                          onTap: () => onCall(number.trim()),
                                        ),
                                      ),
                                if (provider.mobile.isNotEmpty)
                                  ...provider.mobile
                                      .split(RegExp(r'[,\s/]+'))
                                      .where((e) => e.isNotEmpty)
                                      .map(
                                        (number) => _PhoneChip(
                                          number: number.trim(),
                                          isHotline: false,
                                          onTap: () => onCall(number.trim()),
                                          onWhatsapp:
                                              number.trim().startsWith('01')
                                              ? () {
                                                  UrlLauncherService()
                                                      .launchWhatsApp(
                                                        number.trim(),
                                                      );
                                                }
                                              : null,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _MapButton(
                            enabled: provider.mapsUrl.isNotEmpty,
                            onTap: () => onMaps(
                              provider.latitude,
                              provider.longitude,
                              provider.mapsUrl,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Logo ─────────────────────────────────────────────────────────────────────
class _ProviderLogo extends StatelessWidget {
  final String logoUrl;

  const _ProviderLogo({required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: BoxDecoration(
        color: NC.surface2,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: NC.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: logoUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: logoUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Center(
                  child: SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      color: NC.primaryMid,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => const _LogoFallback(),
              )
            : const _LogoFallback(),
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Image.asset(
        AppAssets.mediLogo,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ─── Category tag ─────────────────────────────────────────────────────────────
class _CategoryTag extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Distance badge ───────────────────────────────────────────────────────────
class _DistanceBadge extends StatelessWidget {
  final double distance;

  const _DistanceBadge({required this.distance});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.near_me_rounded, size: 11.sp, color: NC.textLight),
        SizedBox(width: 3.w),
        Text(
          '${distance.toStringAsFixed(1)} ${'network.km'.tr()}',
          style: TextStyle(
            fontSize: 11.sp,
            color: NC.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Address row ──────────────────────────────────────────────────────────────
class _AddressRow extends StatelessWidget {
  final String fullAddress;

  const _AddressRow({
    required this.fullAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Icon(
            Icons.location_on_outlined,
            size: 13.sp,
            color: NC.textLight,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            fullAddress,
            style: TextStyle(fontSize: 11.sp, color: NC.textMid, height: 1.5),
          ),
        ),
      ],
    );
  }
}

// ─── Services preview ─────────────────────────────────────────────────────────
class _ServicesPreview extends StatelessWidget {
  final List<NetworkService> services;
  final VoidCallback onShowAll;

  const _ServicesPreview({required this.services, required this.onShowAll});

  @override
  Widget build(BuildContext context) {
    final visible = services.take(2).toList();
    final extra = services.length - 2;

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Wrap(
        spacing: 6.w,
        runSpacing: 6.h,
        children: [
          ...visible.map(
            (s) => Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: NC.success.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: NC.success.withValues(alpha: 0.2)),
              ),
              child: Text(
                '${s.serviceName}: ${s.discount}%',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF059669),
                ),
              ),
            ),
          ),
          if (extra > 0)
            GestureDetector(
              onTap: onShowAll,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: NC.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: NC.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+$extra ${'network.more'.tr()}',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        color: NC.primaryMid,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 13.sp,
                      color: NC.primaryMid,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Phone chip ───────────────────────────────────────────────────────────────
class _PhoneChip extends StatelessWidget {
  final String number;
  final bool isHotline;
  final VoidCallback onTap;
  final VoidCallback? onWhatsapp;

  const _PhoneChip({
    required this.number,
    required this.isHotline,
    required this.onTap,
    this.onWhatsapp,
  });

  @override
  Widget build(BuildContext context) {
    final color = isHotline ? NC.warning : NC.success;
    final icon = isHotline
        ? Icons.headset_mic_rounded
        : Icons.phone_forwarded_rounded;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12.sp, color: color),
                SizedBox(width: 5.w),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onWhatsapp != null) ...[
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onWhatsapp,
            child: Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: const Color(0xFF25D366).withValues(alpha: 0.2),
                ),
              ),
              child: Image.asset(
                'assets/whatsapp.png',
                width: 18.sp,
                height: 18.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Map button ───────────────────────────────────────────────────────────────
class _MapButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _MapButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [NC.primary, NC.primaryMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled ? null : NC.border,
          borderRadius: BorderRadius.circular(13.r),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: NC.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          Icons.navigation_rounded,
          color: enabled ? Colors.white : NC.textLight,
          size: 20.sp,
        ),
      ),
    );
  }
}
