import 'package:flutter/widgets.dart';

class AppLayoutMetrics {
  static const double sideMargin = 20;
  static const double radius = 24;
  static const double gap = 8;

  // Authentication composition.
  static const double authLogoSize = 84;
  static const double authCompositionVerticalEdge = 18;
  static const double authCardMaxWidth = 430;
  static const double authOuterHorizontal = 24;
  static const double authOuterBottom = authCompositionVerticalEdge;
  static const double authCardHorizontal = 18;
  static const double authCardTop = 18;
  static const double authCardBottom = 6;
  static const double authFieldGap = 16;
  static const double authDividerGap = 18;
  static const double authSubmitModeGap = 10;
  static const double authCardBottomContentGap = 14;
  static const double authHeaderHorizontal = 32;
  static const double authHeaderTop = authCompositionVerticalEdge;
  static const double authHeaderBottom = 12;
  static const double authTallHeightBreakpoint = 860;
  static const double authHeaderBottomTall = 32;

  static double authHeaderBottomForHeight(double safeHeight) =>
      safeHeight >= authTallHeightBreakpoint
      ? authHeaderBottomTall
      : authHeaderBottom;

  static const double authLogoEntranceScale = 0.78;
  static const double authCardRadius = 24;
  static const double authCardShadowBlur = 28;
  static const double authCardShadowYOffset = 10;
  static const double authWordmarkLetterSpacing = -0.4;
  static const double authPrimaryActionHeight = 52;
  static const double authDividerLabelHorizontal = 14;
  static const double authDividerLabelFontSize = 13;

  // Coming Soon full-screen composition.
  static const double comingSoonCompactHeightBreakpoint = 860;
  static const double comingSoonTightHeightBreakpoint = 700;

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
