import 'package:flutter/material.dart';

class AppColors {
  static const blackClr = Color(0xff090F47);
  static const errorClr = Color(0xFFEA5D5D);
  static const primaryClr = Color(0xFF4285F4);
  static const backgroundClr = Color(0xFFF5F5F5);
  static const splashScreenBackgroundClr = Color(0xFFEAF4FE);
  
  // Plan Colors (fallback only)
  static const goldPlanColor = Color(0xFFFFD700);
  
  // Quick Access Colors
  static const approvalColor = Color(0xFFDCEDE3);
  static const refundColor = Color(0xFFCBDCF9);
  static const chronicMedicineColor = Color(0xFFF5E1E9);
  static const approvalTextColor = Color(0xFF287826);
  static const refundTextColor = Color(0xFF1F427F);
  static const chronicMedicineTextColor = Color(0xFF9D4C6C);
  
  // White and other colors
  static const whiteClr = Color(0xFFFFFFFF);
  static const lightGreyClr = Color(0xFFF8F9FA);
  static const greyClr = Color(0xFF9E9E9E);
  static const blueClr = Color(0xFF0B51C1);
  static const successClr = Color(0xFF35BA83);
  static Color borderClr = greyClr.withValues(alpha: 0.5);
  static const greenClrW = Color(0xff347C28);
  static const blueClrW = Color(0xff083D91);
  
  // Enhanced gradient colors
  static const primaryDarkClr = Color(0xFF2962FF);
  static const primaryLightClr = Color(0xFF82B1FF);
  static const secondaryClr = Color(0xFF6C63FF);
  
  // Semantic colors
  static const warningClr = Color(0xFFFFA726);
  static const infoClr = Color(0xFF29B6F6);
  
  // Shadow colors
  static const cardShadowClr = Color(0x1A000000);
  static const primaryShadowClr = Color(0x404285F4);
  static const successShadowClr = Color(0x4035BA83);
  static const errorShadowClr = Color(0x40EA5D5D);
  
  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primaryClr, primaryDarkClr],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const primaryGradientVertical = LinearGradient(
    colors: [primaryClr, primaryDarkClr],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const errorGradient = LinearGradient(
    colors: [Color(0xFFEF5350), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const cardGradient = LinearGradient(
    colors: [whiteClr, Color(0xFFFAFAFA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const shimmerGradient = LinearGradient(
    colors: [
      Color(0xFFEEEEEE),
      Color(0xFFF5F5F5),
      Color(0xFFEEEEEE),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );
}