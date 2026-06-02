import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/api_result.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/constants.dart';
import '../core/helpers/shared_pref_helper.dart';
import '../core/theming/app_toast.dart';
import '../data/card_home_info_response_model.dart';
import '../data/card_personal_info_response_model.dart';
import '../medicard_network/presentation/provider_details_screen.dart';
import '../medicard_network/repository/medicard_network_repository.dart';
import '../network/data/top_providers_slider_model.dart';
import '../core/di/service_locator.dart';
import 'logic/medicard_home_cubit.dart';
import 'logic/medicard_home_state.dart';
import 'widgets/top_providers_slider.dart';

class MediCardHomeScreen extends StatefulWidget {
  final String? cardNo;

  const MediCardHomeScreen({super.key, this.cardNo});

  @override
  State<MediCardHomeScreen> createState() => _MediCardHomeScreenState();
}

class _MediCardHomeScreenState extends State<MediCardHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    if (widget.cardNo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final lang = context.locale.languageCode;
        context.read<MedicardHomeCubit>().getHomeInfo(
          cardNo: widget.cardNo!,
          lang: lang,
        );
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// فتح تفاصيل provider مباشرة بالـ providerId
  Future<void> _openProviderDetails(SliderProvider sliderProvider) async {
    final lang = context.locale.languageCode;
    final cardNo = await SharedPrefHelper.getString(SharedPrefKeys.medicardCardNo);
    final repo = sl<MedicardNetworkRepository>();

    // show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await repo.searchProviders(
      lang: lang,
      cardNo: cardNo.isEmpty ? null : cardNo,
      searchKey: sliderProvider.name,
      page: 1,
      pageSize: 5,
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // close loading

    result.when(
      success: (response) {
        final providers = response.data?.providers ?? [];
        // ابحث عن provider بنفس الـ providerId
        final match = providers.where((p) => p.providerId == sliderProvider.providerId).toList();
        final target = match.isNotEmpty ? match.first : (providers.isNotEmpty ? providers.first : null);

        if (target != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProviderDetailsScreen(provider: target),
            ),
          );
        } else {
          // fallback: افتح صفحة الـ network مع الـ search
          context.push('/medicard-network', extra: {'searchQuery': sliderProvider.name});
        }
      },
      failure: (_) {
        context.push('/medicard-network', extra: {'searchQuery': sliderProvider.name});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicardHomeCubit, MedicardHomeState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          success: (homeInfo, personalInfo, sliderInfo) {
            _animController.forward();
          },
          failed: (error) {
            showErrorToast(error);
          },
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F4F9),
          body: state.maybeWhen(
            loading: () => Stack(
              children: [
                _buildTopDecoration(),
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(),
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            success: (homeInfo, personalInfo, sliderInfo) => FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildBody(
                  homeInfo.data!,
                  personalInfo?.data,
                  sliderInfo?.data ?? [],
                ),
              ),
            ),
            orElse: () => Stack(
              children: [
                _buildTopDecoration(),
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildEmptyState()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Top decorative arc ───────────────────────────────────────────────────

  Widget _buildTopDecoration() {
    return Container(
      height: 240.h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2460), Color(0xFF1E3A8A), Color(0xFF2952CC)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160.w,
              height: 160.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -30,
            child: Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Image.asset(
              AppAssets.mediLogo,
              width: 26.w,
              height: 26.w,
              fit: BoxFit.contain,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MediCard',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.4,
                    height: 1.1,
                  ),
                ),
                Text(
                  'medicard_registration.card_subtitle'.tr(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final isArabic = context.locale.languageCode == 'ar';
              final newLocale = isArabic
                  ? const Locale('en')
                  : const Locale('ar');
              final cubit = context.read<MedicardHomeCubit>();

              await context.setLocale(newLocale);

              if (mounted && widget.cardNo != null) {
                cubit.getHomeInfo(
                  cardNo: widget.cardNo!,
                  lang: newLocale.languageCode,
                );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.translate_rounded,
                    color: Colors.white,
                    size: 14.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    context.locale.languageCode == 'ar' ? 'EN' : 'عربي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody(
    CardHomeInfoDataModel homeData,
    CardPersonalInfoDataModel? personalData,
    List<SliderProvider> sliderData,
  ) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildTopDecoration(),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    // Welcome text sits on top of the blue arc
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'home.hello'.tr()} ${homeData.firstName} 👋',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 22.h),
                        ],
                      ),
                    ),
                    // Card (overlapping the arc)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: _buildMediCard(homeData),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.only(bottom: 30.h + MediaQuery.of(context).padding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sliderData.isNotEmpty) ...[
                  SizedBox(height: 30.h),
                  TopProvidersSlider(
                    providers: sliderData,
                    onProviderTap: (name) {
                      final provider = sliderData.firstWhere((p) => p.name == name);
                      _openProviderDetails(provider);
                    },
                  ),
                ],

                SizedBox(height: 8.h),

                // Section title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Container(
                        width: 4.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'policy_screen.services'.tr(),
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1F36),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                // Actions grid
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _buildQuickActions(personalData),
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
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── MediCard (UNCHANGED) ─────────────────────────────────────────────────

  Widget _buildMediCard(CardHomeInfoDataModel data) {
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
                      SizedBox(width: 12.w),
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

                      if (data.memberPhoto != null &&
                          data.memberPhoto!.isNotEmpty) ...[
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
                              imageUrl: data.memberPhoto!,
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

  // ─── Quick Actions ────────────────────────────────────────────────────────

  Widget _buildQuickActions(CardPersonalInfoDataModel? personalData) {
    final actions = [
      {
        'icon': Icons.local_hospital_rounded,
        'title': 'onboarding.find_hospitals'.tr(),
        'subtitle': 'network.search_description'.tr(),
        'color': const Color(0xFF2D5BE3),
        'bgColor': const Color(0xFFEBF0FF),
        'onTap': () => context.push('/medicard-network'),
      },
      {
        'icon': Icons.support_agent_rounded,
        'title': 'medicard_support.title'.tr(),
        'subtitle': 'contact_us.chat_subtitle'.tr(),
        'color': const Color(0xFFD97706),
        'bgColor': const Color(0xFFFFF8E6),
        'onTap': () => context.push('/medicard-support'),
      },
      {
        'icon': Icons.badge_rounded,
        'title': 'profile.title'.tr(),
        'subtitle': 'profile.personal_information'.tr(),
        'color': const Color(0xFF7C3AED),
        'bgColor': const Color(0xFFF3EDFF),
        // ✅ _buildQuickActions fix
        'onTap': () async {
          if (personalData != null) {
            final cubit = context.read<MedicardHomeCubit>();
            final lang = context.locale.languageCode;

            final result = await context.push(
              '/medicard-my-card',
              extra: {'personalData': personalData, 'cardNo': widget.cardNo},
            );

            if (result == true && context.mounted && widget.cardNo != null) {
              cubit.getHomeInfo(
                cardNo: widget.cardNo!,
                lang: lang,
              );
            }
          } else {
            showErrorToast('medicard_home.no_personal_data'.tr());
          }
        },
      },
    ];

    return Column(
      children: actions
          .map(
            (action) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _ActionCard(action: action),
            ),
          )
          .toList(),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF0FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.credit_card_off_rounded,
              size: 52.sp,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'common.no_data'.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'common.try_again'.tr(),
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

// ─── Action Card Widget ──────────────────────────────────────────────────────

class _ActionCard extends StatefulWidget {
  final Map<String, dynamic> action;

  const _ActionCard({required this.action});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final Color color = widget.action['color'];

    return GestureDetector(
      onTap: widget.action['onTap'],
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) => setState(() => pressed = false),
      onTapCancel: () => setState(() => pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: pressed ? 0.96 : 1,
        child: Container(
          padding: EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.9),
                color.withValues(alpha: 0.35),
              ],
            ),
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .12),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                /// ICON
                Container(
                  width: 54.w,
                  height: 54.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: .7)],
                    ),
                  ),
                  child: Icon(
                    widget.action['icon'],
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),

                SizedBox(width: 16.w),

                /// CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.action['title'],
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.action['subtitle'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                /// ARROW
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: color.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Wave Painter (UNCHANGED) ─────────────────────────────────────────────────

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
