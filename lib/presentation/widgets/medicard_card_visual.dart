import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'medicard_card_shell.dart';

class MediCardCardVisual extends StatefulWidget {
  final String cardNumber;
  final String firstName;
  final String lastName;
  final String birthdate;
  final String? expireDate;
  final File? profileImage;
  final VoidCallback? onRemoveImage;

  const MediCardCardVisual({
    super.key,
    required this.cardNumber,
    required this.firstName,
    required this.lastName,
    required this.birthdate,
    this.expireDate,
    this.profileImage,
    this.onRemoveImage,
  });

  @override
  State<MediCardCardVisual> createState() => _MediCardCardVisualState();
}

class _MediCardCardVisualState extends State<MediCardCardVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _cardRotationAnimation;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _cardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _cardRotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeOut),
    );

    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get display values from inputs or show placeholders
    String displayCardNumber = widget.cardNumber.isEmpty
        ? 'XXXXXXXXXXXX'
        : widget.cardNumber;

    String displayName = '';
    if (widget.firstName.isNotEmpty || widget.lastName.isNotEmpty) {
      displayName = '${widget.firstName} ${widget.lastName}'.trim();
    }
    if (displayName.isEmpty) {
      displayName = 'medicard_registration.card_placeholder_name'.tr();
    }

    String displayValidThru = widget.expireDate ?? '24-02-2027';

    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardScaleAnimation.value,
          child: Transform.rotate(
            angle: _cardRotationAnimation.value,
            child: _MediCardVisualContent(
              cardNumber: displayCardNumber,
              name: displayName,
              validThru: displayValidThru,
              profileImage: widget.profileImage,
              onRemoveImage: widget.onRemoveImage,
            ),
          ),
        );
      },
    );
  }
}

class _MediCardVisualContent extends StatelessWidget {
  final String cardNumber;
  final String name;
  final String validThru;
  final File? profileImage;
  final VoidCallback? onRemoveImage;

  const _MediCardVisualContent({
    required this.cardNumber,
    required this.name,
    required this.validThru,
    this.profileImage,
    this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return MedicardCardShell(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 55.h),

            // Card Number
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                cardNumber,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),

            const Spacer(),

            // Bottom section with user info and profile image
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'medicard_registration.card_member_name'.tr(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        name,
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
                        '${'medicard_registration.card_valid_thru'.tr()}: $validThru',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Image (if available)
                if (profileImage != null) ...[
                  SizedBox(width: 8.w),
                  Stack(
                    children: [
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
                          child: Image.file(profileImage!, fit: BoxFit.cover),
                        ),
                      ),
                      if (onRemoveImage != null)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            onTap: onRemoveImage,
                            child: Container(
                              width: 24.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
