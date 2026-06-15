import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cross-platform system-overlay policy derived from active app brightness.
///
/// Android reads [SystemUiOverlayStyle.statusBarIconBrightness], while iOS
/// reads [SystemUiOverlayStyle.statusBarBrightness].
abstract final class SystemUiOverlayTheme {
  static SystemUiOverlayStyle forBrightness(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final iconBrightness = isDark ? Brightness.light : Brightness.dark;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: iconBrightness,
      statusBarBrightness: brightness,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: iconBrightness,
    );
  }
}
