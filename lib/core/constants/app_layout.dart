import 'package:flutter/widgets.dart';

class AppLayout {
  const AppLayout._();

  static const double bottomNavigationHeight = 72.0;
  static const double bottomNavigationContentGap = 32.0;

  static double bottomNavigationClearance(BuildContext context) {
    return bottomNavigationHeight +
        MediaQuery.viewPaddingOf(context).bottom +
        bottomNavigationContentGap;
  }

  static double scrollBottomPadding(BuildContext context) {
    return bottomNavigationClearance(context);
  }

  static EdgeInsets scrollPadding(
    BuildContext context, {
    double horizontal = 20,
    double top = 20,
  }) {
    return EdgeInsets.fromLTRB(
      horizontal,
      top,
      horizontal,
      scrollBottomPadding(context),
    );
  }
}
