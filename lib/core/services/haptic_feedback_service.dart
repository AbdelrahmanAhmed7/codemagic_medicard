import 'package:flutter/services.dart';

/// Centralized service for haptic feedback throughout the app
class HapticFeedbackService {
  static const HapticFeedbackService instance = HapticFeedbackService._();
  const HapticFeedbackService._();

  /// Light impact - for subtle interactions (tabs, selections)
  void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact - for button presses, confirmations
  void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for important actions (delete, submit)
  void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click - for list items, switches
  void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate - for notifications, errors
  void vibrate() {
    HapticFeedback.vibrate();
  }

  /// Success feedback - for successful actions
  void success() {
    lightImpact();
  }

  /// Error feedback - for errors
  void error() {
    heavyImpact();
  }

  /// Warning feedback - for warnings
  void warning() {
    mediumImpact();
  }
}