import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theming/app_colors.dart';
import '../services/haptic_feedback_service.dart';

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final bool isEnabled;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final bool useGradient;
  final Gradient? gradient;
  final IconData? icon;
  final double? iconSize;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 343,
    this.height = 48,
    this.isEnabled = true,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.useGradient = false,
    this.gradient,
    this.icon,
    this.iconSize,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
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

  void _handleTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.isEnabled && !widget.isLoading;
    final Color bgColor = widget.backgroundColor ??
        (widget.isEnabled
            ? AppColors.primaryClr
            : AppColors.primaryClr.withValues(alpha: 0.5));

    final effectiveGradient = widget.gradient ?? AppColors.primaryGradient;

    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null && !widget.isLoading) ...[
          Icon(
            widget.icon,
            size: widget.iconSize ?? 20.sp,
            color: widget.textColor ?? Colors.white,
          ),
          SizedBox(width: 8.w),
        ],
        if (widget.isLoading)
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        else
          Flexible(
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 16.sp,
                color: widget.textColor ?? Colors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );

    Widget button;
    if (widget.useGradient && widget.isEnabled) {
      button = Container(
        width: widget.width.w,
        height: widget.height.h,
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: AppColors.primaryShadowClr,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isActive
                ? () {
              HapticFeedbackService.instance.lightImpact();
              widget.onPressed?.call();
            }
                : null,
            borderRadius: BorderRadius.circular(12.r),
            splashColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            child: Center(child: buttonContent),
          ),
        ),
      );
    } else {
      button = SizedBox(
        width: widget.width.w,
        height: widget.height.h,
        child: ElevatedButton(
          onPressed: isActive
              ? () {
            HapticFeedbackService.instance.lightImpact();
            widget.onPressed?.call();
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: widget.textColor ?? Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: isActive ? 2 : 0,
            shadowColor: AppColors.primaryShadowClr,
          ),
          child: buttonContent,
        ),
      );
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: button,
      ),
    );
  }
}

/// Secondary/Outline button variant
class AppOutlineButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final bool isEnabled;
  final bool isLoading;
  final Color? borderColor;
  final Color? textColor;
  final IconData? icon;

  const AppOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 343,
    this.height = 48,
    this.isEnabled = true,
    this.isLoading = false,
    this.borderColor,
    this.textColor,
    this.icon,
  });

  @override
  State<AppOutlineButton> createState() => _AppOutlineButtonState();
}

class _AppOutlineButtonState extends State<AppOutlineButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
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

  void _handleTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.isEnabled && !widget.isLoading;
    final effectiveBorderColor = widget.borderColor ?? AppColors.primaryClr;
    final effectiveTextColor = widget.textColor ?? AppColors.primaryClr;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: SizedBox(
          width: widget.width.w,
          height: widget.height.h,
          child: OutlinedButton(
            onPressed: isActive
                ? () {
              HapticFeedbackService.instance.lightImpact();
              widget.onPressed?.call();
            }
                : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: effectiveTextColor,
              side: BorderSide(
                color: isActive
                    ? effectiveBorderColor
                    : effectiveBorderColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: widget.isLoading
                ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                color: effectiveTextColor,
                strokeWidth: 2,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 20.sp),
                  SizedBox(width: 8.w),
                ],
                Flexible(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}