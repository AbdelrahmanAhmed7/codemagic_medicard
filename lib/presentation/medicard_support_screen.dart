import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/services/url_launcher_service.dart';
import '../core/theming/app_toast.dart';
import '../core/utils/error_state_widget.dart';
import '../core/utils/language_helper.dart';
import '../core/utils/shimmer_card.dart';
import '../data/card_support_contact_response_model.dart';
import 'logic/medicard_support_cubit.dart';
import 'logic/medicard_support_state.dart';

class MediCardSupportScreen extends StatefulWidget {
  const MediCardSupportScreen({super.key});

  @override
  State<MediCardSupportScreen> createState() => _MediCardSupportScreenState();
}

class _MediCardSupportScreenState extends State<MediCardSupportScreen> {
  final UrlLauncherService _launcher = UrlLauncherService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MedicardSupportCubit>().load(
        LanguageHelper.getLanguageCode(context),
      );
    });
  }

  Future<void> _launch(Future<bool> Function() action) async {
    final opened = await action();
    if (!opened && mounted) {
      showErrorToast('errors.something_went_wrong'.tr());
    }
  }

  String _clean(String value) => value.trim();

  List<_SupportAction> _primary(CardSupportContactData data) {
    final hotLine = _clean(data.hotLine);
    final email = _clean(data.email);
    final whatsApp = _clean(data.whatsApp);

    return [
      if (hotLine.isNotEmpty)
        _SupportAction(
          icon: Icons.support_agent_rounded,
          title: 'medicard_support.hotline'.tr(),
          subtitle: hotLine,
          onTap: () => _launch(() => _launcher.makePhoneCall(hotLine)),
        ),
      if (email.isNotEmpty)
        _SupportAction(
          icon: Icons.email_outlined,
          title: 'medicard_support.email'.tr(),
          subtitle: email,
          onTap: () => _launch(() => _launcher.launchEmail(email)),
        ),
      if (whatsApp.isNotEmpty)
        _SupportAction(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'medicard_support.whatsapp'.tr(),
          subtitle: whatsApp,
          onTap: () => _launch(() => _launcher.launchWhatsApp(whatsApp)),
        ),
    ];
  }

  List<_SupportAction> _digital(CardSupportContactData data) {
    final website = _clean(data.website);
    final linkedIn = _clean(data.linkedIn);
    final instagram = _clean(data.instagram);
    final facebook = _clean(data.facebook);

    return [
      if (website.isNotEmpty)
        _SupportAction(
          icon: Icons.language_rounded,
          title: 'medicard_support.website'.tr(),
          subtitle: website,
          onTap: () => _launch(() => _launcher.launchURL(website)),
        ),
      if (linkedIn.isNotEmpty)
        _SupportAction(
          icon: Icons.business_center_outlined,
          title: 'medicard_support.linkedin'.tr(),
          subtitle: linkedIn,
          onTap: () => _launch(() => _launcher.launchURL(linkedIn)),
        ),
      if (instagram.isNotEmpty)
        _SupportAction(
          icon: Icons.camera_alt_outlined,
          title: 'medicard_support.instagram'.tr(),
          subtitle: instagram,
          onTap: () => _launch(() => _launcher.launchURL(instagram)),
        ),
      if (facebook.isNotEmpty)
        _SupportAction(
          icon: Icons.facebook_rounded,
          title: 'medicard_support.facebook'.tr(),
          subtitle: facebook,
          onTap: () => _launch(() => _launcher.launchFacebook(facebook)),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: SafeArea(
        child: Column(
          children: [
            _SupportHeader(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: BlocBuilder<MedicardSupportCubit, MedicardSupportState>(
                builder: (context, state) {
                  if (state is MedicardSupportLoading ||
                      state is MedicardSupportInitial) {
                    return _buildLoading();
                  }
                  if (state is MedicardSupportFailed) {
                    return ErrorStateWidget(
                      error: state.error,
                      onRetry: () => context.read<MedicardSupportCubit>().load(
                        LanguageHelper.getLanguageCode(context),
                      ),
                    );
                  }
                  if (state is MedicardSupportSuccess) {
                    final data = state.response.data;
                    if (data == null) {
                      return _buildEmpty();
                    }
                    final primary = _primary(data);
                    final digital = _digital(data);
                    if (primary.isEmpty && digital.isEmpty) {
                      return _buildEmpty();
                    }

                    return ListView(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                      children: [
                        _buildSection(
                          title: 'medicard_support.available_channels'.tr(),
                          items: primary,
                        ),
                        if (digital.isNotEmpty) SizedBox(height: 16.h),
                        if (digital.isNotEmpty)
                          _buildSection(
                            title: 'medicard_support.digital_presence'.tr(),
                            items: digital,
                          ),
                      ],
                    );
                  }
                  return _buildEmpty();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_SupportAction> items,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2460).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2A52),
            ),
          ),
          SizedBox(height: 10.h),
          ...items.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: InkWell(
                borderRadius: BorderRadius.circular(14.r),
                onTap: item.onTap,
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FD),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFE7ECF4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCE6FA),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          item.icon,
                          size: 20.sp,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1F36),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF6C7890),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Color(0xFF9CA8BF),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        ShimmerCard(height: 180.h),
        SizedBox(height: 16.h),
        ShimmerCard(height: 220.h),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        'medicard_support.not_available'.tr(),
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF6C7890),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SupportHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _SupportHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2460), Color(0xFF1E3A8A), Color(0xFF2D5BE3)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'medicard_support.title'.tr(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'medicard_support.subtitle'.tr(),
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
