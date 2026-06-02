import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_assets.dart';
import '../../network/data/top_providers_slider_model.dart';
import 'package:easy_localization/easy_localization.dart';

class TopProvidersSlider extends StatefulWidget {
  final List<SliderProvider> providers;
  final ValueChanged<String>? onProviderTap;

  const TopProvidersSlider({
    super.key,
    required this.providers,
    this.onProviderTap,
  });

  @override
  State<TopProvidersSlider> createState() => _TopProvidersSliderState();
}

class _TopProvidersSliderState extends State<TopProvidersSlider> {
  late ScrollController _scrollController;
  Timer? _timer;
  static const _itemWidth = 88.0;
  static const _scrollStep = _itemWidth + 16.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (widget.providers.length <= 3) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final next = _scrollController.offset + _scrollStep;
      if (next >= max) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.animateTo(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.providers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0A2463),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0A2463).withValues(alpha: 0.35),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'home.partners'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),

        // ── Scrollable logos row ────────────────────────────────────────────
        SizedBox(
          height: 160.h, // 64 logo + 8 gap + (10.sp * 1.3 * 3 lines) + padding
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: widget.providers.length,
            itemBuilder: (context, index) =>
                _ProviderBubble(
                  provider: widget.providers[index],
                  onTap: widget.onProviderTap != null
                      ? () => widget.onProviderTap!(widget.providers[index].name)
                      : null,
                ),
          ),
        ),
      ],
    );
  }
}

// ─── Single provider bubble ───────────────────────────────────────────────────
class _ProviderBubble extends StatefulWidget {
  final SliderProvider provider;
  final VoidCallback? onTap;

  const _ProviderBubble({required this.provider, this.onTap});

  @override
  State<_ProviderBubble> createState() => _ProviderBubbleState();
}

class _ProviderBubbleState extends State<_ProviderBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          width: 88.w,
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CircleLogo(provider: widget.provider),
              SizedBox(height: 8.h),
              Text(
                widget.provider.name,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Circle logo container ────────────────────────────────────────────────────
class _CircleLogo extends StatelessWidget {
  final SliderProvider provider;
  const _CircleLogo({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2463).withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(color: Colors.white, blurRadius: 0, spreadRadius: 2),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: provider.hasLogo
              ? CachedNetworkImage(
                  imageUrl: provider.logo,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => _shimmerCircle(),
                  errorWidget: (_, _, _) => _fallbackIcon(),
                )
              : _fallbackIcon(),
        ),
      ),
    );
  }

  Widget _fallbackIcon() => Image.asset(
    AppAssets.mediLogo,
    fit: BoxFit.contain,
  );

  Widget _shimmerCircle() => const _ShimmerBox(
    width: double.infinity,
    height: double.infinity,
    radius: 100,
  );
}

// ─── Shimmer placeholder ──────────────────────────────────────────────────────
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value, 0),
            colors: const [
              Color(0xFFEEF2F7),
              Color(0xFFF8FAFF),
              Color(0xFFEEF2F7),
            ],
          ),
        ),
      ),
    );
  }
}
