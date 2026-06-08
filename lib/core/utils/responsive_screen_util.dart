import 'dart:math' show min;

import 'package:flutter/material.dart';

/// Keeps [ScreenUtil] width/height scale factors equal on every device so
/// `.w`, `.h`, and `.sp` stay proportional and layouts do not overflow on iPad.
class ResponsiveScreenUtil {
  ResponsiveScreenUtil._();

  static const Size phoneDesignSize = Size(375, 812);

  static Size adaptiveDesignSize(Size screenSize) {
    final scaleW = screenSize.width / phoneDesignSize.width;
    final scaleH = screenSize.height / phoneDesignSize.height;
    final scale = min(scaleW, scaleH);

    if (scale <= 0) return phoneDesignSize;

    return Size(screenSize.width / scale, screenSize.height / scale);
  }
}
