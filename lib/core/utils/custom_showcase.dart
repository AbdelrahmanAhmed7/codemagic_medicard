import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';

/// Custom showcase widget that wraps a target widget
/// The actual highlighting is done by CustomShowcaseOverlay
class CustomShowcase extends StatelessWidget {
  final GlobalKey targetKey;
  final Widget child;

  const CustomShowcase({
    super.key,
    required this.targetKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Custom showcase overlay that shows the highlight and description
class CustomShowcaseOverlay extends StatefulWidget {
  final List<GlobalKey> targetKeys;
  final List<String> descriptions;
  final int currentIndex;
  final VoidCallback? onNext;
  final VoidCallback? onDismiss;
  final Widget child;

  const CustomShowcaseOverlay({
    super.key,
    required this.targetKeys,
    required this.descriptions,
    required this.currentIndex,
    required this.child,
    this.onNext,
    this.onDismiss,
  });

  @override
  State<CustomShowcaseOverlay> createState() => _CustomShowcaseOverlayState();
}

class _CustomShowcaseOverlayState extends State<CustomShowcaseOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(CustomShowcaseOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentIndex < 0 ||
        widget.currentIndex >= widget.targetKeys.length) {
      return widget.child;
    }

    final targetKey = widget.targetKeys[widget.currentIndex];
    final targetContext = targetKey.currentContext;

    if (targetContext == null) {
      // Wait for target to be available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
      return widget.child;
    }

    final RenderBox? targetBox = targetContext.findRenderObject() as RenderBox?;
    if (targetBox == null) {
      return widget.child;
    }

    final Size targetSize = targetBox.size;
    final Offset targetPosition = targetBox.localToGlobal(Offset.zero);

    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        widget.child,
        // Dark overlay with hole for target
        GestureDetector(
          onTap: () {
            // Move to next showcase item when tapping outside
            if (widget.onNext != null) {
              widget.onNext!();
            }
          },
          child: CustomPaint(
            size: screenSize,
            painter: _ShowcasePainter(
              targetPosition: targetPosition,
              targetSize: targetSize,
              screenSize: screenSize,
            ),
          ),
        ),
        // Description card - position it below or above the target based on available space
        Positioned(
          top:
          targetPosition.dy + targetSize.height + 16.h <
              screenSize.height - 200
              ? targetPosition.dy + targetSize.height + 16.h
              : targetPosition.dy - 140.h,
          left: 16.w,
          right: 16.w,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(_fadeAnimation),
              child: Material(
                color: Colors.transparent,
                elevation: 8,
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.whiteClr,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Indicator dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.targetKeys.length,
                              (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            width: index == widget.currentIndex ? 24.w : 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: index == widget.currentIndex
                                  ? AppColors.primaryClr
                                  : AppColors.greyClr.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Description text
                      Text(
                        widget.descriptions[widget.currentIndex],
                        style: AppTextStyles.font16BlackMedium(context),
                      ),
                      SizedBox(height: 20.h),
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.currentIndex > 0)
                            TextButton(
                              onPressed: widget.onDismiss,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 12.h,
                                ),
                              ),
                              child: Text(
                                'common.skip'.tr(),
                                style: TextStyle(
                                  color: AppColors.greyClr,
                                  fontSize: 14.sp,
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          Row(
                            children: [
                              if (widget.currentIndex <
                                  widget.targetKeys.length - 1)
                                ElevatedButton(
                                  onPressed: widget.onNext,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryClr,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24.w,
                                      vertical: 12.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'common.next'.tr(),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else
                                ElevatedButton(
                                  onPressed: widget.onDismiss,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryClr,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24.w,
                                      vertical: 12.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'dialog.got_it'.tr(),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter to create the hole in the overlay
class _ShowcasePainter extends CustomPainter {
  final Offset targetPosition;
  final Size targetSize;
  final Size screenSize;

  _ShowcasePainter({
    required this.targetPosition,
    required this.targetSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw dark overlay covering entire screen
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.7);

    // Draw four rectangles around the target to create the hole effect
    final targetRect = Rect.fromLTWH(
      targetPosition.dx,
      targetPosition.dy,
      targetSize.width,
      targetSize.height,
    );

    // Top rectangle
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, targetRect.top),
      overlayPaint,
    );

    // Bottom rectangle
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        targetRect.bottom,
        size.width,
        size.height - targetRect.bottom,
      ),
      overlayPaint,
    );

    // Left rectangle
    canvas.drawRect(
      Rect.fromLTWH(0, targetRect.top, targetRect.left, targetRect.height),
      overlayPaint,
    );

    // Right rectangle
    canvas.drawRect(
      Rect.fromLTWH(
        targetRect.right,
        targetRect.top,
        size.width - targetRect.right,
        targetRect.height,
      ),
      overlayPaint,
    );

    // Draw border around target with shadow effect
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Draw shadow first (slightly larger)
    final borderRect = RRect.fromRectAndRadius(
      targetRect.inflate(2),
      const Radius.circular(12),
    );
    canvas.drawRRect(borderRect, shadowPaint);

    // Draw white border
    final borderRRect = RRect.fromRectAndRadius(
      targetRect,
      const Radius.circular(12),
    );
    canvas.drawRRect(borderRRect, borderPaint);
  }

  @override
  bool shouldRepaint(_ShowcasePainter oldDelegate) {
    return oldDelegate.targetPosition != targetPosition ||
        oldDelegate.targetSize != targetSize;
  }
}
