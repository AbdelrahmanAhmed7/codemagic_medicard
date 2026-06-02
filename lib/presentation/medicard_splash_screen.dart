import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/constants.dart';
import '../core/helpers/shared_pref_helper.dart';

class MedicardSplashScreen extends StatefulWidget {
  const MedicardSplashScreen({super.key});

  @override
  State<MedicardSplashScreen> createState() => _MedicardSplashScreenState();
}

class _MedicardSplashScreenState extends State<MedicardSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final cardNo = await SharedPrefHelper.getString(
      SharedPrefKeys.medicardCardNo,
    );

    if (!mounted) return;
    if (cardNo.isNotEmpty) {
      context.go('/medicard-home?cardNo=$cardNo');
    } else {
      context.go('/medicard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2B6B),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D2B6B),
              Color(0xFF1A4DB5),
              Color(0xFF2563EB),
            ],
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
              const Spacer(),

              // Logo
              Container(
                width: 110.w,
                height: 110.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(22.w),
                  child: Image.asset(
                    AppAssets.mediLogo,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              SizedBox(height: 28.h),

              // App name
              Text(
                'MediCard',
                style: TextStyle(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),

              SizedBox(height: 8.h),

              // Tagline
              Text(
                'medicard_splash.tagline'.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 0.8,
                ),
              ),

              const Spacer(),

              // Bottom brand
              Column(
                children: [
                  Text(
                    'medicard_splash.powered_by'.tr(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Image.asset(
                    AppAssets.khusm,
                    height: 30.h,
                    fit: BoxFit.contain,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
