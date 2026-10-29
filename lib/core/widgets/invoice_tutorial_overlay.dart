import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─── Home Banner ─────────────────────────────────────────────────────────────
// A persistent banner shown inside the home screen body (not an overlay).
// Dismissed once the user taps "Got it" — stored in SharedPrefs.

class InvoiceHomeBanner extends StatelessWidget {
  final VoidCallback onDismiss;

  const InvoiceHomeBanner({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF0D9488)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'tutorial.invoice_home_title'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Body text
            Text(
              'tutorial.invoice_home_body'.tr(),
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
            SizedBox(height: 14.h),
            // CTA button
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 18.w,
                  vertical: 9.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'tutorial.got_it'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF059669),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Create Form Guide ────────────────────────────────────────────────────────
// A static info card shown at the top of the invoice create form.
// Shows all 3 steps at once. Dismissed with an X button.

class InvoiceFormGuide extends StatelessWidget {
  final VoidCallback onDismiss;

  const InvoiceFormGuide({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        icon: Icons.apartment_rounded,
        color: const Color(0xFF2D5BE3),
        text: 'tutorial.invoice_step1'.tr(),
      ),
      (
        icon: Icons.location_on_rounded,
        color: const Color(0xFF0F766E),
        text: 'tutorial.invoice_step2'.tr(),
      ),
      (
        icon: Icons.edit_note_rounded,
        color: const Color(0xFF7C3AED),
        text: 'tutorial.invoice_step3'.tr(),
      ),
    ];

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2EAF4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 0),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: const Color(0xFFF59E0B),
                  size: 18.sp,
                ),
                SizedBox(width: 7.w),
                Expanded(
                  child: Text(
                    'tutorial.invoice_form_title'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onDismiss,
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          // Steps
          ...steps.map(
            (step) => Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: step.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                    child: Icon(
                      step.icon,
                      size: 17.sp,
                      color: step.color,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        step.text,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.4,
                          color: const Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
}
