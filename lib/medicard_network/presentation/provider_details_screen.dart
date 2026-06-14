import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../network/data/network_provider_response_model.dart';
import '../../../core/constants/app_assets.dart';
import '../../core/services/url_launcher_service.dart';
import '../core/maps_launcher.dart';
import '../core/network_colors.dart';

class ProviderDetailsScreen extends StatelessWidget {
  final NetworkProvider provider;

  const ProviderDetailsScreen({super.key, required this.provider});

  Color get _catColor => networkCatColor(provider.categoryName);

  // ─── Launchers ─────────────────────────────────────────────────────────────
  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openMaps(BuildContext context) async {
    await MapsLauncher.showPicker(
      context,
      lat: provider.latitude,
      lng: provider.longitude,
      fallbackUrl: provider.mapsUrl.isNotEmpty ? provider.mapsUrl : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NC.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _DetailsAppBar(provider: provider, catColor: _catColor),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header card ─────────────────────────────────────────
                  _HeaderCard(provider: provider, catColor: _catColor),
                  SizedBox(height: 16.h),

                  // ── Contact card ────────────────────────────────────────
                  if (provider.mobile.isNotEmpty || provider.hotline.isNotEmpty)
                    _ContactCard(provider: provider, onCall: _call),

                  // ── Location card ───────────────────────────────────────
                  if (provider.fullAddress.isNotEmpty)
                    _LocationCard(
                      provider: provider,
                      catColor: _catColor,
                      onOpenMaps: () => _openMaps(context),
                    ),

                  // ── Services card ───────────────────────────────────────
                  if (provider.services != null &&
                      provider.services!.isNotEmpty)
                    _ServicesCard(
                      services: provider.services!,
                      catColor: _catColor,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom CTA ────────────────────────────────────────────────────────
      bottomNavigationBar: _BottomCTA(
        provider: provider,
        onCall: _call,
        onMaps: () => _openMaps(context),
      ),
    );
  }
}

// ─── SliverAppBar ─────────────────────────────────────────────────────────────
class _DetailsAppBar extends StatelessWidget {
  final NetworkProvider provider;
  final Color catColor;

  const _DetailsAppBar({required this.provider, required this.catColor});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160.h,
      pinned: true,
      stretch: true,
      backgroundColor: NC.primary,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20.sp),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.only(bottom: 14.h, left: 48.w, right: 48.w),
        title: Text(
          provider.providerName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient using category color
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [NC.primary, catColor.withValues(alpha: 0.85)],
                ),
              ),
            ),
            // Logo centered in header
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20.h),
                  _HeroLogo(
                    logoUrl: provider.providerLogo,
                    catColor: catColor,
                    discount: provider.hasDiscount ? provider.discount : null,
                  ),
                ],
              ),
            ),
            // Decorative circles
            Positioned(
              right: -40.w,
              top: -40.h,
              child: Container(
                width: 180.w,
                height: 180.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero logo in header ──────────────────────────────────────────────────────
class _HeroLogo extends StatelessWidget {
  final String logoUrl;
  final Color catColor;
  final String? discount;

  const _HeroLogo({
    required this.logoUrl,
    required this.catColor,
    this.discount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17.r),
            child: logoUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: logoUrl,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => const _FallbackIcon(),
            )
                : const _FallbackIcon(),
          ),
        ),
        if (discount != null)
          Positioned(
            top: -8.h,
            left: -8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: NC.danger,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                '$discount%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: Image.asset(AppAssets.mediLogo, fit: BoxFit.contain),
  );
}

// ─── Header card (name + category + distance) ─────────────────────────────────
class _HeaderCard extends StatelessWidget {
  final NetworkProvider provider;
  final Color catColor;

  const _HeaderCard({required this.provider, required this.catColor});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.providerName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h),
                // Category chip
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: catColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    provider.categoryName,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: catColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Distance badge
          if (provider.distance != null) ...[
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: NC.primaryLt.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: NC.primaryLt.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Icon(Icons.near_me_rounded,
                      size: 18.sp, color: NC.primaryMid),
                  SizedBox(height: 3.h),
                  Text(
                    provider.distance!.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: NC.primaryMid,
                    ),
                  ),
                  Text(
                    'network.km'.tr(),
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: NC.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Contact card ─────────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final NetworkProvider provider;
  final ValueChanged<String> onCall;

  const _ContactCard({required this.provider, required this.onCall});

  @override
  Widget build(BuildContext context) {
    final List<String> hotlines = provider.hotline.split(RegExp(r'[,\s/]+')).where((e) => e.trim().isNotEmpty).toList();
    final List<String> mobiles = provider.mobile.split(RegExp(r'[,\s/]+')).where((e) => e.trim().isNotEmpty).toList();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.call_rounded, label: 'medicard_edit_profile.phone'.tr()),
          SizedBox(height: 12.h),
          ...hotlines.map((number) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _ContactRow(
                  icon: Icons.headset_mic_rounded,
                  color: NC.warning,
                  label: 'common.hotline'.tr(),
                  value: number.trim(),
                  onTap: () => onCall(number.trim()),
                ),
              )),
          ...mobiles.map((number) {
            final isMobile = number.trim().startsWith('01');
            return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _ContactRow(
                  icon: Icons.phone_rounded,
                  color: NC.success,
                  label: 'common.mobile_landline'.tr(),
                  value: number.trim(),
                  onTap: () => onCall(number.trim()),
                  onWhatsapp: isMobile ? () => UrlLauncherService().launchWhatsApp(number.trim()) : null,
                ),
              );
          }),
        ],
      ),
    );
  }
}
class _ContactRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback onTap;        // اتصال
  final VoidCallback? onWhatsapp;  // واتساب

  const _ContactRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onTap,
    this.onWhatsapp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          // ── Label + number ──────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: NC.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          // ── Call icon button ────────────────────────────────────────────
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 38.w,
              height: 38.w,
              margin: EdgeInsets.only(left: 8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18.sp, color: color),
            ),
          ),

          // ── WhatsApp icon button ────────────────────────────────────────
          if (onWhatsapp != null) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onWhatsapp,
              child: Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/whatsapp.png',
                    width: 20.sp,
                    height: 20.sp,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Location card ────────────────────────────────────────────────────────────
class _LocationCard extends StatelessWidget {
  final NetworkProvider provider;
  final Color catColor;
  final VoidCallback onOpenMaps;

  const _LocationCard({
    required this.provider,
    required this.catColor,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.location_on_rounded,
            label: 'network.location_and_address'.tr(),
          ),
          SizedBox(height: 12.h),
          // Address block
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: NC.surface2,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: NC.border),
            ),
            child: _AddressLine(
              icon: Icons.home_rounded,
              text: provider.fullAddress,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AddressLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13.sp, color: NC.textLight),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style:
            TextStyle(fontSize: 12.sp, color: NC.textMid, height: 1.5),
          ),
        ),
      ],
    );
  }
}

// ─── Services card ────────────────────────────────────────────────────────────
class _ServicesCard extends StatelessWidget {
  final List<NetworkService> services;
  final Color catColor;

  const _ServicesCard({required this.services, required this.catColor});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.local_offer_rounded,
            label: 'network.services_and_discounts'.tr(),
          ),
          SizedBox(height: 4.h),
          Text(
            'network.available_service_count'
                .tr(args: [services.length.toString()]),
            style: TextStyle(
              fontSize: 11.sp,
              color: NC.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 14.h),
          ...services.asMap().entries.map((e) {
            final isLast = e.key == services.length - 1;
            final s = e.value;
            return Column(
              children: [
                _ServiceTile(service: s),
                if (!isLast) Divider(color: NC.border, height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final NetworkService service;

  const _ServiceTile({required this.service});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration:
            BoxDecoration(color: NC.success, shape: BoxShape.circle),
          ),
          SizedBox(width: 10.w),
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

// ─── Bottom CTA bar ───────────────────────────────────────────────────────────
class _BottomCTA extends StatelessWidget {
  final NetworkProvider provider;
  final ValueChanged<String> onCall;
  final VoidCallback onMaps;

  const _BottomCTA({
    required this.provider,
    required this.onCall,
    required this.onMaps,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = provider.mobile.isNotEmpty || provider.hotline.isNotEmpty;
    final hasMaps  = provider.mapsUrl.isNotEmpty ||
        (provider.latitude != 0 && provider.longitude != 0);

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w,
          12.h + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: NC.surface,
        border: Border(top: BorderSide(color: NC.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Call button
          if (hasPhone)
            Expanded(
              child: GestureDetector(
                onTap: () => onCall(
                  provider.mobile.isNotEmpty
                      ? provider.mobile
                      : provider.hotline,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: NC.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: NC.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_rounded,
                          color: NC.success, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'network.call'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: NC.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (hasPhone && hasMaps) SizedBox(width: 10.w),
          // Maps button
          if (hasMaps)
            Expanded(
              flex: hasMaps && hasPhone ? 2 : 1,
              child: GestureDetector(
                onTap: onMaps,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [NC.primary, NC.primaryMid],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: NC.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.navigation_rounded,
                          color: Colors.white, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'network.directions'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: NC.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: NC.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: NC.primaryLt.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 14.sp, color: NC.primaryMid),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}