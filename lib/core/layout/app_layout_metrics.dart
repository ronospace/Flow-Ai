import 'package:flutter/widgets.dart';

class AppLayoutMetrics {
  static const double sideMargin = 20;
  static const double radius = 24;
  static const double gap = 8;

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
