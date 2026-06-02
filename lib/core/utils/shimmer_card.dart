import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../theming/app_colors.dart';

/// Enhanced shimmer widget with smooth animations
class SmoothShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;
  final ShimmerDirection direction;

  const SmoothShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.ltr,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Shimmer.fromColors(
      baseColor: baseColor ?? const Color(0xFFE8E8E8),
      highlightColor: highlightColor ?? const Color(0xFFF5F5F5),
      period: period,
      direction: isRtl ? ShimmerDirection.rtl : direction,
      child: child,
    );
  }
}

/// Shimmer skeleton for cards with enhanced styling
class ShimmerCard extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerCard({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: margin,
        child: SmoothShimmer(
          key: ValueKey('shimmer_${width}_$height'),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: borderRadius ?? BorderRadius.circular(16.r),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for list items with improved structure
class ShimmerListItem extends StatelessWidget {
  final bool showAvatar;
  final int lines;
  final double? avatarSize;
  final EdgeInsetsGeometry? padding;

  const ShimmerListItem({
    super.key,
    this.showAvatar = true,
    this.lines = 2,
    this.avatarSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAvatarSize = avatarSize ?? 50.w;
    return RepaintBoundary(
      child: Container(
        padding: padding ?? EdgeInsets.symmetric(vertical: 8.h),
        child: SmoothShimmer(
          key: ValueKey('shimmer_list_${showAvatar}_$lines'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showAvatar)
                Container(
                  width: effectiveAvatarSize,
                  height: effectiveAvatarSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8E8E8),
                    shape: BoxShape.circle,
                  ),
                ),
              if (showAvatar) SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    lines,
                        (index) => Padding(
                      padding: EdgeInsets.only(
                        bottom: index < lines - 1 ? 10.h : 0,
                      ),
                      child: Container(
                        height: index == 0 ? 16.h : 12.h,
                        width: index == 0 ? double.infinity : 120.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Approval/Refund card shimmer skeleton
class ShimmerApprovalCard extends StatelessWidget {
  const ShimmerApprovalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.whiteClr,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadowClr,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SmoothShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16.h,
                          width: 140.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E8E8),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 12.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E8E8),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 70.w,
                    height: 26.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // Divider
              Container(
                height: 1,
                color: const Color(0xFFF0F0F0),
              ),
              SizedBox(height: 16.h),
              // Footer row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 14.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Container(
                    height: 14.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid item shimmer
class ShimmerGridItem extends StatelessWidget {
  final double? width;
  final double? height;

  const ShimmerGridItem({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SmoothShimmer(
        child: Container(
          width: width,
          height: height ?? 120.h,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                height: 12.h,
                width: 60.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pulse animation shimmer alternative
class PulseShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulseShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<PulseShimmer> createState() => _PulseShimmerState();
}

class _PulseShimmerState extends State<PulseShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: _animation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

