import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_assets.dart';

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
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOut,
      ),
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
    String displayCardNumber =
        widget.cardNumber.isEmpty ? 'XXXXXXXXXXXX' : widget.cardNumber;

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
                  colors: [
                    Color(0xFFE8EEF5),
                    Color(0xFFF5F7FA),
                  ],
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
                    colors: [
                      Color(0xFF1E3A8A),
                      Color(0xFF1E3A8A),
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: _WavePainter(),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Image.asset(
                    AppAssets.mediLogo,
                    width: 80.w,
                    height: 35.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 16.h),

                  // Card Number
                  Text(
                    cardNumber,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E3A8A),
                      letterSpacing: 2,
                    ),
                  ),

                  const Spacer(),

                  // Bottom section with QR, user info, and profile image
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // QR Code
                      Container(
                        width: 65.w,
                        height: 65.h,
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Image.asset(
                          AppAssets.qrCode,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: 12.w),

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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.r),
                                child: Image.file(
                                  profileImage!,
                                  fit: BoxFit.cover,
                                ),
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
          ],
        ),
      ),
    );
  }
}

// Custom painter for wave decoration
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
