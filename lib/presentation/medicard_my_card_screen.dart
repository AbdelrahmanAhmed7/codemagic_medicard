import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/constants.dart';
import '../core/constants/legal_urls.dart';
import '../core/di/service_locator.dart';
import '../core/helpers/shared_pref_helper.dart';
import '../core/services/url_launcher_service.dart';
import '../core/theming/app_text_styles.dart';
import 'widgets/legal_links_row.dart';
import '../data/card_personal_info_response_model.dart';
import 'logic/medicard_home_cubit.dart';
import 'logic/medicard_home_state.dart';

class MedicardMyCardScreen extends StatefulWidget {
  final CardPersonalInfoDataModel personalData;
  final String cardNo;

  const MedicardMyCardScreen({
    super.key,
    required this.personalData,
    required this.cardNo,
  });

  @override
  State<MedicardMyCardScreen> createState() => _MedicardMyCardScreenState();
}

class _MedicardMyCardScreenState extends State<MedicardMyCardScreen> {
  late CardPersonalInfoDataModel _currentData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentData = widget.personalData;
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await context.read<MedicardHomeCubit>().getHomeInfo(
      cardNo: widget.cardNo,
      lang: context.locale.languageCode,
    );
    // Note: The BlocConsumer/Builder will handle the state update if we wrap this screen in a BlocProvider or use the existing one.
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicardHomeCubit, MedicardHomeState>(
      listener: (context, state) {
        state.maybeWhen(
          success: (homeInfo, personalInfo, sliderInfo) {
            if (personalInfo != null) {
              setState(() {
                _currentData = personalInfo.data!;
              });
            }
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F6FB),
          appBar: AppBar(
            title: Text(
              'profile.title'.tr(),
              style: AppTextStyles.font18BlackSemiBold(
                context,
              ).copyWith(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1E3A8A),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => context.pop(
                true,
              ), // Return true to signal potential change to Home
            ),
            actions: [
              if (_isLoading || state is Loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              else
                TextButton.icon(
                  onPressed: () async {
                    final result = await context.push(
                      '/medicard-edit-profile',
                      extra: {
                        'personalData': _currentData,
                        'cardNo': widget.cardNo,
                      },
                    );
                    if (result == true) {
                      _refreshData();
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                  label: Text(
                    'common.edit'.tr(),
                    style: AppTextStyles.font14BlackMedium(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
                ),
              SizedBox(width: 10.w),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // Force scroll for RefreshIndicator
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h + MediaQuery.of(context).padding.bottom),
              child: Column(
                children: [
                  _buildMediCard(_currentData), // Updated to the premium design
                  SizedBox(height: 12.h),
                  _buildProfileSection(context, _currentData),
                  SizedBox(height: 24.h),
                  const LegalLinksRow(),
                  SizedBox(height: 24.h),
                  _buildDeleteAccountButton(context),
                  SizedBox(height: 16.h),
                  _buildLogoutButton(context),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediCard(CardPersonalInfoDataModel data) {
    return Container(
      height: 230.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE8EEF5), Color(0xFFF5F7FA)],
                ),
              ),
            ),

            // Wave decoration at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120.h,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1E3A8A), Color(0xFF1E3A8A)],
                  ),
                ),
                child: CustomPaint(painter: _WavePainter()),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        AppAssets.mediLogo,
                        width: 80.w,
                        height: 35.h,
                        fit: BoxFit.contain,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.green, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'insurance_plan.active'.tr(),
                              style: TextStyle(
                                color: const Color(0xFF1E3A8A),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Card Number
                  Text(
                    data.cardId,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E3A8A),
                      letterSpacing: 2,
                    ),
                  ),

                  const Spacer(),

                  // Bottom section with user info and photo
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'personal_info.full_name'.tr(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              '${data.firstName} ${data.lastName}',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '${'insurance_plan.valid_until'.tr()}: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(data.expireDate))}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (data.image != null && data.image!.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Container(
                          width: 65.w,
                          height: 65.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: CachedNetworkImage(
                              imageUrl: data.image!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                color: const Color(0xFF1E3A8A),
                                size: 30.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    CardPersonalInfoDataModel data,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE6ECF7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: data.image != null && data.image!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: CachedNetworkImage(
                          imageUrl: data.image!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            color: const Color(0xFF1E3A8A),
                            size: 40.sp,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: const Color(0xFF1E3A8A),
                        size: 40.sp,
                      ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.firstName} ${data.lastName}',
                      style: AppTextStyles.font20BlackSemiBold(context),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'insurance_plan.active'.tr(),
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.25)),
          SizedBox(height: 20.h),
          _buildInfoItem(
            context,
            icon: Icons.credit_card,
            title: 'auth.login.card_id'.tr(),
            value: data.cardId,
          ),
          _buildInfoItem(
            context,
            icon: Icons.phone_android,
            title: 'personal_info.phone_number'.tr(),
            value: data.mobile,
          ),
          _buildInfoItem(
            context,
            icon: Icons.calendar_month,
            title: 'personal_info.date_of_birth'.tr(),
            value: _formatDate(data.birthdate),
          ),
          _buildInfoItem(
            context,
            icon: data.isMale ? Icons.male : Icons.female,
            title: 'personal_info.gender'.tr(),
            value: data.isMale
                ? 'personal_info.male'.tr()
                : 'personal_info.female'.tr(),
          ),
          _buildInfoItem(
            context,
            icon: Icons.email_outlined,
            title: 'personal_info.email_address'.tr(),
            value:
                (data.email != null && data.email!.isNotEmpty)
                    ? data.email!
                    : '-',
          ),
          _buildInfoItem(
            context,
            icon: Icons.badge_outlined,
            title: 'auth.signup.national_id'.tr(),
            value: (data.nationalId != null && data.nationalId!.isNotEmpty)
                ? data.nationalId!
                : '-',
          ),
          _buildInfoItem(
            context,
            icon: Icons.flight_takeoff,
            title: 'medicard_edit_profile.passport'.tr(),
            value: (data.passport != null && data.passport!.isNotEmpty)
                ? data.passport!
                : '-',
          ),
          _buildInfoItem(
            context,
            icon: Icons.verified_user_outlined,
            title: 'common.active'.tr(),
            value: _formatDate(data.activatedDate),
          ),
          _buildInfoItem(
            context,
            icon: Icons.event_busy_outlined,
            title: 'insurance_plan.valid_until'.tr(),
            value: _formatDate(data.expireDate),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.font12GreyRegular(
                    context,
                  ).copyWith(color: const Color(0xFF7A879E)),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  style: AppTextStyles.font14BlackMedium(
                    context,
                  ).copyWith(color: const Color(0xFF1F2937)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showDeleteAccountDialog(context),
        icon: const Icon(Icons.delete_forever_outlined, color: Color(0xFFB91C1C)),
        label: Text(
          'account_deletion.title'.tr(),
          style: AppTextStyles.font16BlackMedium(context).copyWith(
            color: const Color(0xFFB91C1C),
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          side: const BorderSide(color: Color(0xFFFECACA)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final launcher = sl<UrlLauncherService>();
    const email = LegalUrls.accountDeletionEmail;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.email_outlined,
                color: const Color(0xFF1E3A8A),
                size: 40.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                'account_deletion.contact_title'.tr(),
                style: AppTextStyles.font18BlackSemiBold(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'account_deletion.contact_message'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.font14GreyRegular(context).copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    launcher.launchEmail(
                      email,
                      subject: 'MediCard account deletion request',
                      body:
                          'Please delete my MediCard account.\nCard number: ${widget.cardNo}',
                    );
                  },
                  icon: const Icon(Icons.mail_outline, color: Colors.white),
                  label: Text(
                    'account_deletion.send_email'.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('common.cancel'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _clearLocalSession() async {
    await SharedPrefHelper.removeData(SharedPrefKeys.medicardCardNo);
    await SharedPrefHelper.clearAllSecuredData();
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutConfirmation(context),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          'profile.log_out'.tr(),
          style: AppTextStyles.font16BlackMedium(
            context,
          ).copyWith(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE5484D),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: const Color(0xFFE5484D),
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'logout.confirm_button'.tr(),
                  style: AppTextStyles.font18BlackSemiBold(context),
                ),
                SizedBox(height: 12.h),
                Text(
                  'logout.confirmation_message'.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.font14GreyRegular(context).copyWith(
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'common.cancel'.tr(),
                          style:
                              AppTextStyles.font14BlackMedium(context).copyWith(
                                color: const Color(0xFF64748B),
                              ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _clearLocalSession();
                          if (context.mounted) context.go('/medicard');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5484D),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'logout.confirm_button'.tr(),
                          style:
                              AppTextStyles.font14BlackMedium(context).copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F1F4A).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.5,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width,
      size.height * 0.3,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
