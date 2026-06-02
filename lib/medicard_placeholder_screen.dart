import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_assets.dart';
import 'core/theming/app_colors.dart';
import 'core/theming/app_text_styles.dart';

class MediCardPlaceholderScreen extends StatelessWidget {
  const MediCardPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundClr,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundClr,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/choose'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.blackClr,
        ),
        title: Text(
          'MediCard',
          style: AppTextStyles.font16BlackMedium(context),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.logo,
                width: 140.w,
                height: 140.w,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 24.h),
              Text(
                'MediCard',
                style: AppTextStyles.font20BlackSemiBold(context),
              ),
              SizedBox(height: 8.h),
              Text(
                'This section is under construction.',
                style: AppTextStyles.font14GreyRegular(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
