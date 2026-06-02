import 'package:flutter/material.dart';

// ─── Brand Palette ────────────────────────────────────────────────────────────
class NC {
  static const primary    = Color(0xFF0A2463);
  static const primaryMid = Color(0xFF1E40AF);
  static const primaryLt  = Color(0xFF3B82F6);
  static const accent     = Color(0xFF06B6D4);
  static const success    = Color(0xFF10B981);
  static const warning    = Color(0xFFF59E0B);
  static const danger     = Color(0xFFEF4444);
  static const bg         = Color(0xFFF0F4FF);
  static const surface    = Color(0xFFFFFFFF);
  static const surface2   = Color(0xFFF8FAFF);
  static const border     = Color(0xFFE2E8F0);
  static const textMid    = Color(0xFF475569);
  static const textLight  = Color(0xFF94A3B8);
}

// ─── Category color helper ────────────────────────────────────────────────────
Color networkCatColor(String categoryName) {
  if (categoryName.contains('صيدل'))                              return NC.success;
  if (categoryName.contains('مستشفى'))                           return NC.primaryMid;
  if (categoryName.contains('أسنان') || categoryName.contains('الاسنان')) return NC.warning;
  if (categoryName.contains('بصري'))                             return const Color(0xFF8B5CF6);
  if (categoryName.contains('أشعة'))                             return const Color(0xFFEC4899);
  if (categoryName.contains('معمل'))                             return NC.accent;
  return NC.primaryLt;
}