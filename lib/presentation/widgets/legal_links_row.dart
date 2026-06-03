import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/legal_urls.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/url_launcher_service.dart';

/// Opens the privacy policy in the system browser.
class LegalLinksRow extends StatelessWidget {
  final TextAlign textAlign;
  final bool showAgreementHint;

  const LegalLinksRow({
    super.key,
    this.textAlign = TextAlign.center,
    this.showAgreementHint = false,
  });

  @override
  Widget build(BuildContext context) {
    final launcher = sl<UrlLauncherService>();
    final style = TextStyle(
      fontSize: 12.sp,
      color: const Color(0xFF64748B),
      height: 1.4,
    );
    final linkStyle = style.copyWith(
      color: const Color(0xFF1E3A8A),
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    return Column(
      children: [
        if (showAgreementHint) ...[
          Text(
            'legal.agreement_hint'.tr(),
            textAlign: textAlign,
            style: style,
          ),
          SizedBox(height: 8.h),
        ],
        Text.rich(
          TextSpan(
            style: style,
            children: [
              TextSpan(
                text: 'legal.privacy_policy'.tr(),
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launcher.launchURL(LegalUrls.privacyPolicy),
              ),
            ],
          ),
          textAlign: textAlign,
        ),
      ],
    );
  }
}
