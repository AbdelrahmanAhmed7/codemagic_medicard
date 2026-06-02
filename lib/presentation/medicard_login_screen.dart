import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_assets.dart';
import '../core/theming/app_colors.dart';
import '../core/theming/app_toast.dart';
import '../core/theming/app_text_styles.dart';
import '../core/utils/app_button.dart';
import '../core/utils/app_text_field.dart';
import '../core/utils/language_helper.dart';
import 'logic/medicard_login_cubit.dart';
import 'logic/medicard_login_state.dart';

class MediCardLoginScreen extends StatefulWidget {
  const MediCardLoginScreen({super.key});

  @override
  State<MediCardLoginScreen> createState() => _MediCardLoginScreenState();
}

class _MediCardLoginScreenState extends State<MediCardLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicardNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _medicardNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicardLoginCubit, MedicardLoginState>(
      listenWhen: (previous, current) {
        return true;
      },
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          success: (response) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.go(
                  '/medicard-home?cardNo=${_medicardNumberController.text}',
                );
              }
            });
          },
          failed: (error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                showErrorToast(error);
              }
            });
          },
        );
      },
      buildWhen: (previous, current) {
        return true;
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return Scaffold(
          backgroundColor: AppColors.backgroundClr,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h + MediaQuery.of(context).padding.bottom),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.blackClr,
                            ),
                            onPressed: () => context.go('/medicard'),
                            padding: EdgeInsets.zero,
                          ),
                          IconButton(
                            onPressed: () {
                              if (context.locale.languageCode == 'ar') {
                                context.setLocale(const Locale('en'));
                              } else {
                                context.setLocale(const Locale('ar'));
                              }
                            },
                            icon: const Icon(
                              Icons.translate,
                              color: AppColors.blackClr,
                            ),
                          ),
                        ],
                      ),

                      Center(
                        child: Image.asset(
                          AppAssets.mediLogo,
                          width: 120.w,
                          height: 120.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 32.h),

                      Text(
                        'auth.login.title'.tr(),
                        style: AppTextStyles.font20BlackSemiBold(context),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'auth.login.subtitle'.tr(),
                        style: AppTextStyles.font16GreyRegular(context),
                      ),
                      SizedBox(height: 40.h),

                      Text(
                        'auth.login.medicard_number'.tr(),
                        style: AppTextStyles.font16BlackMedium(context),
                      ),
                      SizedBox(height: 8.h),
                      AppTextField(
                        controller: _medicardNumberController,
                        hintText: 'auth.login.medicard_number_placeholder'.tr(),
                        prefixImagePath: AppAssets.cardIcon,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'auth.login.validation.medicard_required'
                                .tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      Text(
                        'auth.login.password'.tr(),
                        style: AppTextStyles.font16BlackMedium(context),
                      ),
                      SizedBox(height: 8.h),
                      AppTextField(
                        controller: _passwordController,
                        hintText: 'auth.login.password_placeholder'.tr(),
                        isPassword: true,
                        prefixImagePath: AppAssets.passwordIcon,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'auth.login.validation.password_required'
                                .tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 28.h),

                      AppButton(
                        text: 'auth.login.login_button'.tr(),
                        useGradient: true,
                        isLoading: isLoading,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF233154),
                            const Color(0xFF233154).withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();

                                if (_formKey.currentState!.validate()) {
                                  final cardNo =
                                      LanguageHelper.convertArabicToEnglishNumerals(
                                        _medicardNumberController.text.trim(),
                                      );
                                  final password =
                                      LanguageHelper.convertArabicToEnglishNumerals(
                                        _passwordController.text.trim(),
                                      );

                                  final cubit = context
                                      .read<MedicardLoginCubit>();
                                  final lang = context.locale.languageCode;

                                  cubit.login(
                                    cardNo: cardNo,
                                    password: password,
                                    lang: lang,
                                  );
                                } else {
                                  showErrorToast('auth.login.fill_all_fields'.tr());
                                }
                              },
                      ),
                      Center(
                        child: Image.asset(
                          AppAssets.khusm,
                          width: 200.w,
                          height: 100.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
