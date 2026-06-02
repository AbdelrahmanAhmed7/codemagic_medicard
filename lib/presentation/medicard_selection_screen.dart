import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_assets.dart';
import '../core/di/service_locator.dart';
import '../core/services/url_launcher_service.dart';
import '../core/theming/app_colors.dart';
import '../core/theming/app_text_styles.dart';
import '../core/utils/language_helper.dart';
import 'logic/medicard_support_cubit.dart';
import 'logic/medicard_support_state.dart';

class MedicardSelectionScreen extends StatelessWidget {
  const MedicardSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundClr,
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(
            top: -100.h,
            right: -100.w,
            child: Container(
              width: 300.w,
              height: 300.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.h),
                            Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1E3A8A,
                                    ).withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                AppAssets.mediLogo,
                                width: 80.w,
                                height: 80.w,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              'medicard_selection.title'.tr(),
                              style: AppTextStyles.font20BlackSemiBold(context)
                                  .copyWith(
                                    color: const Color(0xFF1E3A8A),
                                    letterSpacing: 1.2,
                                  ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'medicard_selection.subtitle'.tr(),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.font14GreyRegular(context),
                            ),
                            const Spacer(),
                            SizedBox(height: 20.h),
                            _buildOptionCard(
                              context,
                              title: 'medicard_selection.activate.title'.tr(),
                              subtitle: 'medicard_selection.activate.subtitle'
                                  .tr(),
                              description:
                                  'medicard_selection.activate.description'
                                      .tr(),
                              icon: Icons.app_registration_rounded,
                              color: const Color(0xFF1E3A8A),
                              onTap: () => context.push('/medicard-activation'),
                            ),
                            SizedBox(height: 20.h),
                            _buildOptionCard(
                              context,
                              title: 'medicard_selection.login.title'.tr(),
                              subtitle: 'medicard_selection.login.subtitle'
                                  .tr(),
                              description:
                                  'medicard_selection.login.description'.tr(),
                              icon: Icons.login_rounded,
                              color: const Color(0xFF1E3A8A),
                              variant: true,
                              onTap: () => context.push('/medicard-login'),
                            ),
                            SizedBox(height: 20.h),
                            _buildOptionCard(
                              context,
                              title: 'medicard_selection.buy.title'.tr(),
                              subtitle: 'medicard_selection.buy.subtitle'.tr(),
                              description: 'medicard_selection.buy.description'
                                  .tr(),
                              icon: Icons.shopping_cart_checkout_rounded,
                              color: const Color(0xFF10B981),
                              onTap: () => _showBuyDialog(context),
                            ),

                            // Khusm Logo at bottom
                            Center(
                              child: Image.asset(
                                AppAssets.khusm,
                                width: 200.w,
                                height: 100.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool variant = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: variant ? Colors.white : color,
            borderRadius: BorderRadius.circular(24.r),
            border: variant
                ? Border.all(color: color.withValues(alpha: 0.2), width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: variant ? 0.05 : 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: variant
                      ? color.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  icon,
                  color: variant ? color : Colors.white,
                  size: 30.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.font16BlackMedium(
                        context,
                      ).copyWith(color: variant ? color : Colors.white),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.font12BlackMedium(context).copyWith(
                        color: variant
                            ? color.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.7),
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: AppTextStyles.font12GreyRegular(context).copyWith(
                        color: variant
                            ? Colors.grey[600]
                            : Colors.white.withValues(alpha: 0.9),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: variant ? color : Colors.white,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBuyDialog(BuildContext context) {
    final UrlLauncherService launcher = UrlLauncherService();
    final String lang = LanguageHelper.getLanguageCode(context);

    showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => sl<MedicardSupportCubit>()..load(lang),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: BlocBuilder<MedicardSupportCubit, MedicardSupportState>(
              builder: (context, state) {
                if (state is MedicardSupportLoading) {
                  return SizedBox(
                    height: 200.h,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF10B981),
                      ),
                    ),
                  );
                }

                if (state is MedicardSupportFailed) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                      SizedBox(height: 16.h),
                      Text(
                        state.error,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () => context
                            .read<MedicardSupportCubit>()
                            .load(LanguageHelper.getLanguageCode(context)),
                        child: Text('common.retry'.tr()),
                      ),
                    ],
                  );
                }

                if (state is MedicardSupportSuccess) {
                  final data = state.response.data;
                  if (data != null) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: const Color(0xFF10B981),
                            size: 36.sp,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'medicard_selection.buy.dialog_title'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1F36),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'medicard_selection.buy.dialog_subtitle'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: const Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 28.h),
                        Column(
                          children: [
                            if (data.hotLine.isNotEmpty)
                              _buildBuyContactFeature(
                                icon: Icons.phone_in_talk_rounded,
                                color: const Color(0xFF2563EB),
                                title: 'medicard_selection.buy.hotline'.tr(),
                                value: data.hotLine,
                                onTap: () =>
                                    launcher.makePhoneCall(data.hotLine),
                              ),
                            if (data.hotLine.isNotEmpty) SizedBox(height: 12.h),
                            if (data.whatsApp.isNotEmpty)
                              _buildBuyContactFeature(
                                assetPath: 'assets/whatsapp.png',
                                color: const Color(0xFF10B981),
                                title: 'medicard_selection.buy.whatsapp'.tr(),
                                value: data.whatsApp,
                                onTap: () =>
                                    launcher.launchWhatsApp(data.whatsApp),
                              ),
                            if (data.whatsApp.isNotEmpty)
                              SizedBox(height: 12.h),
                            if (data.website.isNotEmpty)
                              _buildBuyContactFeature(
                                icon: Icons.language_rounded,
                                color: const Color(0xFF6366F1),
                                title: 'medicard_selection.buy.website'.tr(),
                                value: data.website
                                    .replaceAll('https://', '')
                                    .replaceAll('http://', '')
                                    .replaceAll('/', ''),
                                onTap: () => launcher.launchURL(data.website),
                              ),
                            if (data.website.isNotEmpty) SizedBox(height: 12.h),
                            if (data.email.isNotEmpty)
                              _buildBuyContactFeature(
                                icon: Icons.email_rounded,
                                color: const Color(0xFFF43F5E),
                                title: 'medicard_selection.buy.email'.tr(),
                                value: data.email,
                                onTap: () => launcher.launchEmail(data.email),
                              ),
                          ],
                        ),
                        SizedBox(height: 32.h),
                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'common.ok'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBuyContactFeature({
    IconData? icon,
    String? assetPath,
    required Color color,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: assetPath != null
                  ? Image.asset(assetPath, width: 22.sp, height: 22.sp)
                  : Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12.sp,
              color: color.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
