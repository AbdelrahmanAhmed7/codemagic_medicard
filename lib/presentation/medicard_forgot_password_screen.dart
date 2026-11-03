import 'dart:async';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

import '../core/constants/app_assets.dart';
import '../core/network/api_error_handler.dart';
import '../core/theming/app_colors.dart';
import '../core/theming/app_toast.dart';
import '../core/theming/app_text_styles.dart';
import '../core/utils/app_button.dart';
import '../core/utils/app_text_field.dart';
import '../core/utils/language_helper.dart';
import '../core/utils/otp_sms_retriever.dart';
import '../service/password_recovery_api_service.dart';

class MedicardForgotPasswordScreen extends StatefulWidget {
  final PasswordRecoveryApiService apiService;

  const MedicardForgotPasswordScreen({super.key, required this.apiService});

  @override
  State<MedicardForgotPasswordScreen> createState() =>
      _MedicardForgotPasswordScreenState();
}

class _MedicardForgotPasswordScreenState
    extends State<MedicardForgotPasswordScreen> {
  static const _otpLength = 4;
  static const _resendDuration = 180;

  final _mobileFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;
  String _mobileNumber = '';
  int _resendSeconds = 0;
  int _otpRequestId = 0;
  Timer? _resendTimer;
  OtpSmsRetriever? _otpSmsRetriever;

  @override
  void dispose() {
    _resendTimer?.cancel();
    unawaited(_otpSmsRetriever?.dispose());
    _mobileController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = _resendDuration);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds--);
    });
  }

  String _normalizedMobileNumber() {
    final converted = LanguageHelper.convertArabicToEnglishNumerals(
      _mobileController.text.trim(),
    );
    if (converted.length == 10 && !converted.startsWith('0')) {
      return '0$converted';
    }
    return converted;
  }

  String? _validateMobile(String? value) {
    final mobileNumber = _normalizedMobileNumber();
    if ((value ?? '').trim().isEmpty) {
      return 'auth.forgot_password.validation.phone_required'.tr();
    }
    if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(mobileNumber)) {
      return 'auth.forgot_password.validation.phone_invalid'.tr();
    }
    return null;
  }

  Future<void> _sendOtp({bool isResend = false}) async {
    if (_isLoading) return;
    if (!isResend && !(_mobileFormKey.currentState?.validate() ?? false)) {
      return;
    }
    if (isResend && _resendSeconds > 0) return;
    final mobileNumber = _normalizedMobileNumber();
    setState(() => _isLoading = true);

    final previousSmsRetriever = _otpSmsRetriever;
    final smsRetriever = OtpSmsRetriever(SmartAuth.instance);
    _otpSmsRetriever = smsRetriever;
    unawaited(previousSmsRetriever?.dispose());
    smsRetriever.startListening();

    try {
      final message = await widget.apiService.forgotPassword(
        lang: context.locale.languageCode,
        mobileNumber: mobileNumber,
      );
      if (!mounted) return;
      showSuccessToast(message);
      setState(() {
        _mobileNumber = mobileNumber;
        _otpSent = true;
        _otpRequestId++;
        _otpController.clear();
      });
      _startResendTimer();
    } catch (error) {
      if (identical(_otpSmsRetriever, smsRetriever)) {
        _otpSmsRetriever = null;
      }
      await smsRetriever.dispose();
      if (mounted) showErrorToast(ErrorHandler.handle(error, context));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    if (!(_resetFormKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      final message = await widget.apiService.resetPassword(
        lang: context.locale.languageCode,
        mobileNumber: _mobileNumber,
        otp: LanguageHelper.convertArabicToEnglishNumerals(
          _otpController.text.trim(),
        ),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );
      if (!mounted) return;
      showSuccessToast(message);
      context.go('/medicard-login');
    } catch (error) {
      if (mounted) showErrorToast(ErrorHandler.handle(error, context));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    if (_isLoading) return;
    if (_otpSent) {
      _resendTimer?.cancel();
      setState(() {
        _otpSent = false;
        _resendSeconds = 0;
        _otpController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
      return;
    }
    context.go('/medicard-login');
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _goBack();
    },
    child: Scaffold(
      backgroundColor: AppColors.backgroundClr,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: _goBack,
                          tooltip: 'common.back'.tr(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _isLoading
                              ? null
                              : () => context.setLocale(
                                  Locale(
                                    context.locale.languageCode == 'ar'
                                        ? 'en'
                                        : 'ar',
                                  ),
                                ),
                          icon: const Icon(Icons.translate_rounded),
                        ),
                      ],
                    ),
                    Center(
                      child: Image.asset(
                        AppAssets.mediLogo,
                        width: 110.w,
                        height: 110.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _otpSent ? _buildResetStep() : _buildMobileStep(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildMobileStep() => Form(
    key: _mobileFormKey,
    child: Column(
      key: const ValueKey('mobile'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth.forgot_password.title'.tr(),
          style: AppTextStyles.font20BlackSemiBold(context),
        ),
        SizedBox(height: 12.h),
        Text(
          'auth.forgot_password.description'.tr(),
          style: AppTextStyles.font16GreyRegular(context),
        ),
        SizedBox(height: 32.h),
        Text(
          'auth.forgot_password.phone_number'.tr(),
          style: AppTextStyles.font16BlackMedium(context),
        ),
        SizedBox(height: 8.h),
        AppTextField(
          controller: _mobileController,
          hintText: 'auth.forgot_password.phone_placeholder'.tr(),
          prefixIcon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
            LengthLimitingTextInputFormatter(11),
          ],
          validator: _validateMobile,
        ),
        SizedBox(height: 28.h),
        Center(
          child: AppButton(
            text: 'auth.forgot_password.send_button'.tr(),
            onPressed: _sendOtp,
            isLoading: _isLoading,
            useGradient: true,
          ),
        ),
      ],
    ),
  );

  Widget _buildResetStep() => Form(
    key: _resetFormKey,
    child: Column(
      key: const ValueKey('reset'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth.reset_password.title'.tr(),
          style: AppTextStyles.font20BlackSemiBold(context),
        ),
        SizedBox(height: 12.h),
        Text(
          'auth.forgot_password.otp_instruction'.tr(
            namedArgs: {'phone': _mobileNumber},
          ),
          style: AppTextStyles.font16GreyRegular(context),
        ),
        SizedBox(height: 26.h),
        _fieldLabel('auth.forgot_password.otp_title'),
        Center(
          child: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Pinput(
              key: ValueKey('otp-$_otpRequestId'),
              controller: _otpController,
              length: _otpLength,
              smsRetriever: _otpSmsRetriever,
              autofillHints: const [AutofillHints.oneTimeCode],
              mainAxisAlignment: MainAxisAlignment.center,
              separatorBuilder: (_) => SizedBox(width: 12.w),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
              ],
              defaultPinTheme: _pinTheme(),
              focusedPinTheme: _pinTheme(
                borderColor: AppColors.primaryClr,
                borderWidth: 2,
              ),
              errorPinTheme: _pinTheme(borderColor: AppColors.errorClr),
              submittedPinTheme: _pinTheme(
                borderColor: AppColors.successClr,
                backgroundColor: AppColors.successClr.withValues(alpha: 0.06),
              ),
              validator: (value) {
                if ((value ?? '').isEmpty) {
                  return 'auth.forgot_password.validation.otp_required'.tr();
                }
                if (value!.length != _otpLength) {
                  return 'auth.forgot_password.validation.otp_incomplete'.tr();
                }
                return null;
              },
              onCompleted: (_) => FocusScope.of(context).nextFocus(),
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Center(
          child: Text(
            'auth.forgot_password.otp_expire_in'.tr(
              namedArgs: {'time': _formatDuration(_resendSeconds)},
            ),
            style: TextStyle(
              color: _resendSeconds > 0
                  ? const Color(0xFF64748B)
                  : AppColors.errorClr,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _fieldLabel('auth.reset_password.new_password'),
        AppTextField(
          controller: _passwordController,
          hintText: 'auth.reset_password.new_password_placeholder'.tr(),
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
          validator: (value) {
            if ((value ?? '').isEmpty) {
              return 'auth.reset_password.validation.new_password_required'
                  .tr();
            }
            if (value!.trim().length < 8) {
              return 'auth.reset_password.validation.password_length'.tr();
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _fieldLabel('auth.reset_password.confirm_password'),
        AppTextField(
          controller: _confirmPasswordController,
          hintText: 'auth.reset_password.confirm_password_placeholder'.tr(),
          prefixIcon: Icons.lock_reset_rounded,
          isPassword: true,
          validator: (value) {
            if ((value ?? '').isEmpty) {
              return 'auth.reset_password.validation.confirm_password_required'
                  .tr();
            }
            if (value!.trim() != _passwordController.text.trim()) {
              return 'auth.reset_password.validation.passwords_not_match'.tr();
            }
            return null;
          },
        ),
        SizedBox(height: 28.h),
        Center(
          child: AppButton(
            text: 'auth.reset_password.confirm_button'.tr(),
            onPressed: _resetPassword,
            isLoading: _isLoading,
            useGradient: true,
          ),
        ),
        SizedBox(height: 10.h),
        Center(
          child: TextButton(
            onPressed: _isLoading || _resendSeconds > 0
                ? null
                : () => _sendOtp(isResend: true),
            child: Text(
              _resendSeconds > 0
                  ? 'auth.forgot_password.resend_in'.tr(
                      namedArgs: {'time': _formatDuration(_resendSeconds)},
                    )
                  : 'auth.forgot_password.resend_code'.tr(),
            ),
          ),
        ),
      ],
    ),
  );

  PinTheme _pinTheme({
    Color borderColor = const Color(0xFFD1D5DB),
    Color backgroundColor = Colors.white,
    double borderWidth = 1,
  }) => PinTheme(
    width: 60.w,
    height: 58.h,
    textStyle: TextStyle(
      fontSize: 22.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.blackClr,
    ),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: borderColor, width: borderWidth),
    ),
  );

  Widget _fieldLabel(String key) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text(key.tr(), style: AppTextStyles.font16BlackMedium(context)),
  );
}
