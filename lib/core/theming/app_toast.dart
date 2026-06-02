import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

import '../services/haptic_feedback_service.dart';

enum ToastType { success, error, warning, info }

void showToast(
  String message, {
  ToastType type = ToastType.info,
  bool isError = false,
  ToastGravity gravity = ToastGravity.BOTTOM,
}) {
  final effectiveType = isError ? ToastType.error : type;

  // haptic feedback
  if (effectiveType == ToastType.error) {
    HapticFeedbackService.instance.heavyImpact();
  } else if (effectiveType == ToastType.success) {
    HapticFeedbackService.instance.lightImpact();
  }

  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: gravity,
    textColor: Colors.white,
    fontSize: 14.0,
  );
}

/// Shorthand helpers
void showSuccessToast(String message) =>
    showToast(message, type: ToastType.success);

void showErrorToast(String message) =>
    showToast(message, type: ToastType.error, isError: true);

void showInfoToast(String message) =>
    showToast(message, type: ToastType.info);

/// For location messages that need an action — still uses toast for the message,
/// caller handles the action separately
void showWarningToast(String message) =>
    showToast(message, type: ToastType.warning);
