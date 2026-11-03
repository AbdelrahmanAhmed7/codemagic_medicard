import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_assets.dart';
import '../core/theming/app_colors.dart';
import '../core/theming/app_toast.dart';
import '../core/theming/app_text_styles.dart';
import '../core/utils/app_button.dart';
import '../core/utils/app_text_field.dart';
import '../core/utils/language_helper.dart';
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
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;
  String _mobileNumber = '';

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  Future<void> _sendOtp() async {
    if (_isLoading) return;
    final mobileNumber = _normalizedMobileNumber();
    setState(() => _isLoading = true);
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
      });
    } catch (error) {
      if (mounted) showErrorToast(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final message = await widget.apiService.resetPassword(
        lang: context.locale.languageCode,
        mobileNumber: _mobileNumber,
        otp: LanguageHelper.convertArabicToEnglishNumerals(
          _otpController.text.trim(),
        ),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (!mounted) return;
      showSuccessToast(message);
      context.go('/medicard-login');
    } catch (error) {
      if (mounted) showErrorToast(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    if (_isLoading) return;
    if (_otpSent) {
      setState(() {
        _otpSent = false;
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
      appBar: AppBar(
        backgroundColor: AppColors.backgroundClr,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading
                ? null
                : () => context.setLocale(
                    Locale(context.locale.languageCode == 'ar' ? 'en' : 'ar'),
                  ),
            icon: const Icon(Icons.translate_rounded),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

  Widget _buildMobileStep() => Column(
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
        ],
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
  );

  Widget _buildResetStep() => Column(
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
      AppTextField(
        controller: _otpController,
        hintText: 'auth.forgot_password.otp_placeholder'.tr(),
        prefixIcon: Icons.password_rounded,
        keyboardType: TextInputType.number,
        maxLength: 8,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
        ],
      ),
      SizedBox(height: 16.h),
      _fieldLabel('auth.reset_password.new_password'),
      AppTextField(
        controller: _passwordController,
        hintText: 'auth.reset_password.new_password_placeholder'.tr(),
        prefixIcon: Icons.lock_outline_rounded,
        isPassword: true,
      ),
      SizedBox(height: 16.h),
      _fieldLabel('auth.reset_password.confirm_password'),
      AppTextField(
        controller: _confirmPasswordController,
        hintText: 'auth.reset_password.confirm_password_placeholder'.tr(),
        prefixIcon: Icons.lock_reset_rounded,
        isPassword: true,
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
          onPressed: _isLoading ? null : _sendOtp,
          child: Text('auth.forgot_password.resend_code'.tr()),
        ),
      ),
    ],
  );

  Widget _fieldLabel(String key) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text(key.tr(), style: AppTextStyles.font16BlackMedium(context)),
  );
}
