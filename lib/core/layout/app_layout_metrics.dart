import 'package:flutter/widgets.dart';

class AppLayoutMetrics {
  static const double sideMargin = 20;
  static const double radius = 24;
  static const double gap = 8;

  // Authoritative responsive breakpoints.
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static double width(BuildContext c) => MediaQuery.sizeOf(c).width;

  static bool isMobile(BuildContext c) => width(c) < mobileBreakpoint;

  static bool isTablet(BuildContext c) {
    final w = width(c);
    return w >= mobileBreakpoint && w < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext c) => width(c) >= desktopBreakpoint;

  // Preserves the existing Zyra `width > 900` behavior exactly.
  static bool isWiderThanTablet(BuildContext c) => width(c) > tabletBreakpoint;

  static double safeTop(BuildContext c) => MediaQuery.of(c).padding.top;

  static double safeBottom(BuildContext c) => MediaQuery.of(c).padding.bottom;

  static double dialogBottom(BuildContext c) => safeBottom(c) + gap;

  static double centeredMaxWidth(BuildContext c, {double max = 720}) {
    final w = MediaQuery.of(c).size.width;
    return w < max ? w - (sideMargin * 2) : max;
  }

  static double centeredLeft(BuildContext c, {double max = 720}) {
    final w = MediaQuery.of(c).size.width;
    final width = centeredMaxWidth(c, max: max);
    return (w - width) / 2;
  }

  static double centeredRight(BuildContext c, {double max = 720}) {
    return centeredLeft(c, max: max);
  }
}
