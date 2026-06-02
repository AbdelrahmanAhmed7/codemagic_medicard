import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool isPassword;
  final String? prefixImagePath;
  final IconData? prefixIcon;
  final String? errorText;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;
  final bool enabled;
  final String? Function(String?)? validator;
  final String? label;
  final bool showSuccessState;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.isPassword = false,
    this.prefixImagePath,
    this.prefixIcon,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.enabled = true,
    this.validator,
    this.label,
    this.showSuccessState = false,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField>
    with SingleTickerProviderStateMixin {
  bool _obscure = true;
  bool _isFocused = false;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;

  static const double _width = 343;
  static const double _height = 52;
  static const double _borderRadius = 12;

  @override
  void initState() {
    super.initState();
    if (!widget.isPassword) _obscure = false;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  OutlineInputBorder _buildBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Color _getBorderColor(bool hasError) {
    if (hasError) return AppColors.errorClr;
    if (widget.showSuccessState &&
        widget.controller != null &&
        widget.controller!.text.isNotEmpty) {
      return AppColors.successClr;
    }
    if (_isFocused) return AppColors.primaryClr;
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      builder: (fieldState) {
        final String? localError = fieldState.errorText;
        final String? externalError = widget.errorText;
        final String? effectiveError = externalError ?? localError;
        final bool hasError = effectiveError != null;
        final borderColor = _getBorderColor(hasError);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
                child: Text(
                  widget.label!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: hasError ? AppColors.errorClr : AppColors.blackClr,
                  ),
                ),
              ),
            AnimatedBuilder(
              animation: _borderAnimation,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_borderRadius.r),
                    boxShadow: _isFocused && !hasError
                        ? [
                      BoxShadow(
                        color: AppColors.primaryClr.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: child,
                );
              },
              child: SizedBox(
                width: _width.w,
                height: _height.h,
                child: TextField(
                  enabled: widget.enabled,
                  controller: widget.controller,
                  keyboardType: widget.keyboardType,
                  obscureText: _obscure,
                  focusNode: _focusNode,
                  maxLength: widget.maxLength,
                  inputFormatters: widget.inputFormatters,
                  onChanged: (value) {
                    widget.onChanged?.call(value);
                    fieldState.didChange(value);
                    fieldState.validate();
                  },
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.blackClr,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyClr,
                      fontWeight: FontWeight.w400,
                    ),
                    counterText: "",
                    filled: true,
                    fillColor: widget.enabled
                        ? AppColors.whiteClr
                        : AppColors.lightGreyClr,
                    isDense: true,
                    prefixIcon: _buildPrefixIcon(hasError),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 48.w,
                      minHeight: 48.h,
                    ),
                    suffixIcon: _buildSuffixIcon(hasError),
                    enabledBorder: _buildBorder(borderColor, 1.0),
                    focusedBorder: _buildBorder(
                      borderColor,
                      _borderAnimation.value,
                    ),
                    errorBorder: _buildBorder(AppColors.errorClr, 1.5),
                    focusedErrorBorder: _buildBorder(AppColors.errorClr, 2.0),
                    disabledBorder: _buildBorder(Colors.grey.shade200, 1.0),
                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                    errorMaxLines: 1,
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: effectiveError != null
                  ? Padding(
                padding: EdgeInsets.only(top: 6.h, left: 8.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 14.sp,
                      color: AppColors.errorClr,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        effectiveError,
                        style: TextStyle(
                          color: AppColors.errorClr,
                          fontSize: 12.sp,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  Widget? _buildPrefixIcon(bool hasError) {
    if (widget.prefixImagePath != null) {
      return Padding(
        padding: EdgeInsets.only(left: 14.w, right: 10.w),
        child: Image.asset(
          widget.prefixImagePath!,
          width: 20.w,
          height: 20.h,
          fit: BoxFit.contain,
          color: hasError
              ? AppColors.errorClr
              : (_isFocused ? AppColors.primaryClr : AppColors.greyClr),
        ),
      );
    }
    if (widget.prefixIcon != null) {
      return Padding(
        padding: EdgeInsets.only(left: 14.w, right: 10.w),
        child: Icon(
          widget.prefixIcon,
          size: 20.sp,
          color: hasError
              ? AppColors.errorClr
              : (_isFocused ? AppColors.primaryClr : AppColors.greyClr),
        ),
      );
    }
    return null;
  }

  Widget? _buildSuffixIcon(bool hasError) {
    if (widget.isPassword) {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: 48.w, minHeight: 48.h),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            key: ValueKey(_obscure),
            size: 22.sp,
            color: _isFocused ? AppColors.primaryClr : AppColors.greyClr,
          ),
        ),
        onPressed: () {
          setState(() {
            _obscure = !_obscure;
          });
        },
      );
    }

    // Success indicator
    if (widget.showSuccessState &&
        widget.controller != null &&
        widget.controller!.text.isNotEmpty &&
        !hasError) {
      return Padding(
        padding: EdgeInsets.only(right: 14.w),
        child: Icon(
          Icons.check_circle,
          size: 22.sp,
          color: AppColors.successClr,
        ),
      );
    }

    return null;
  }
}
