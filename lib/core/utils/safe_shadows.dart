import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Utility class to create safe BoxShadows that prevent negative blur radius errors
/// This addresses the recurring "Text shadow blur radius should be non-negative" issues
class SafeShadows {
  /// Creates a safe BoxShadow that ensures non-negative blur and spread radius
  static BoxShadow safe({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    double spreadRadius = 0.0,
    BlurStyle blurStyle = BlurStyle.normal,
  }) {
    return _SafeBoxShadow(
      color: color,
      offset: offset,
      blurRadius: math.max(0.0, blurRadius),
      spreadRadius: math.max(0.0, spreadRadius),
      blurStyle: blurStyle,
    );
  }

  /// Creates a list of safe BoxShadows
  static List<BoxShadow> safeList(List<BoxShadow> shadows) {
    return shadows.map((shadow) => safe(
      color: shadow.color,
      offset: shadow.offset,
      blurRadius: math.max(0.0, shadow.blurRadius),
      spreadRadius: math.max(0.0, shadow.spreadRadius),
      blurStyle: shadow.blurStyle,
    )).toList();
  }

  /// Common elevation shadow that's safe for animations
  static List<BoxShadow> elevation(
    double elevation, {
    Color color = Colors.black,
    double opacity = 0.16,
  }) {
    if (elevation <= 0) return [];
    
    return [
      safe(
        color: color.withValues(alpha: opacity * 0.6),
        offset: Offset(0, math.max(1.0, elevation * 0.5)),
        blurRadius: math.max(1.0, elevation * 1.5),
      ),
      safe(
        color: color.withValues(alpha: opacity * 0.3),
        offset: Offset(0, math.max(0.5, elevation * 0.25)),
        blurRadius: math.max(0.5, elevation),
      ),
    ];
  }

  /// Material Design elevation shadows with safe values
  static List<BoxShadow> materialElevation(int elevation) {
    switch (elevation.clamp(0, 24)) {
      case 0:
        return [];
      case 1:
        return [
          safe(color: Colors.black.withValues(alpha: 0.2), offset: const Offset(0, 2), blurRadius: 1, spreadRadius: -1),
          safe(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 1), blurRadius: 1, spreadRadius: 0),
          safe(color: Colors.black.withValues(alpha: 0.12), offset: const Offset(0, 1), blurRadius: 3, spreadRadius: 0),
        ];
      case 2:
        return [
          safe(color: Colors.black.withValues(alpha: 0.2), offset: const Offset(0, 3), blurRadius: 1, spreadRadius: -2),
          safe(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 2), blurRadius: 2, spreadRadius: 0),
          safe(color: Colors.black.withValues(alpha: 0.12), offset: const Offset(0, 1), blurRadius: 5, spreadRadius: 0),
        ];
      case 3:
        return [
          safe(color: Colors.black.withValues(alpha: 0.2), offset: const Offset(0, 3), blurRadius: 3, spreadRadius: -2),
          safe(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 3), blurRadius: 4, spreadRadius: 0),
          safe(color: Colors.black.withValues(alpha: 0.12), offset: const Offset(0, 1), blurRadius: 8, spreadRadius: 0),
        ];
      case 4:
        return [
          safe(color: Colors.black.withValues(alpha: 0.2), offset: const Offset(0, 2), blurRadius: 4, spreadRadius: -1),
          safe(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 5, spreadRadius: 0),
          safe(color: Colors.black.withValues(alpha: 0.12), offset: const Offset(0, 1), blurRadius: 10, spreadRadius: 0),
        ];
      case 6:
        return [
          safe(color: Colors.black.withValues(alpha: 0.2), offset: const Offset(0, 3), blurRadius: 5, spreadRadius: -1),
          safe(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 6), blurRadius: 10, spreadRadius: 0),
          safe(color: Colors.black.withValues(alpha: 0.12), offset: const Offset(0, 1), blurRadius: 18, spreadRadius: 0),
        ];
      case 8:
        return [
          safe(color: Colors.black.withValues(alpha: 0.2), offset: const Offset(0, 5), blurRadius: 5, spreadRadius: -3),
          safe(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 8), blurRadius: 10, spreadRadius: 1),
          safe(color: Colors.black.withValues(alpha: 0.12), offset: const Offset(0, 3), blurRadius: 14, spreadRadius: 2),
        ];
      case 12:
        return [
          safe(color: Colors.black.withValues(alpha: 0.2), offset: const Offset(0, 7), blurRadius: 8, spreadRadius: -4),
          safe(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 12), blurRadius: 17, spreadRadius: 2),
          safe(color: Colors.black.withValues(alpha: 0.12), offset: const Offset(0, 5), blurRadius: 22, spreadRadius: 4),
        ];
      case 16:
        return [
          safe(color: Colors.black.withValues(alpha: 0.2), offset: const Offset(0, 8), blurRadius: 10, spreadRadius: -5),
          safe(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 16), blurRadius: 24, spreadRadius: 2),
          safe(color: Colors.black.withValues(alpha: 0.12), offset: const Offset(0, 6), blurRadius: 30, spreadRadius: 5),
        ];
      case 24:
        return [
          safe(color: Colors.black.withValues(alpha: 0.2), offset: const Offset(0, 11), blurRadius: 15, spreadRadius: -7),
          safe(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 24), blurRadius: 38, spreadRadius: 3),
          safe(color: Colors.black.withValues(alpha: 0.12), offset: const Offset(0, 9), blurRadius: 46, spreadRadius: 8),
        ];
      default:
        return SafeShadows.elevation(elevation.toDouble());
    }
  }
}

/// Safe BoxShadow implementation that prevents negative values during animations
class _SafeBoxShadow extends BoxShadow {
  const _SafeBoxShadow({
    super.color,
    super.offset,
    double blurRadius = 0.0,
    double spreadRadius = 0.0,
    super.blurStyle,
  }) : super(
         blurRadius: blurRadius < 0 ? 0 : blurRadius,
         spreadRadius: spreadRadius < 0 ? 0 : spreadRadius,
       );

  @override
  BoxShadow scale(double factor) {
    return _SafeBoxShadow(
      color: color,
      offset: offset * factor,
      blurRadius: math.max(0.0, blurRadius * factor),
      spreadRadius: math.max(0.0, spreadRadius * factor),
      blurStyle: blurStyle,
    );
  }
}
