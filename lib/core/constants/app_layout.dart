import 'package:flutter/widgets.dart';

class AppLayout {
  const AppLayout._();

  static const double bottomNavigationHeight = 72.0;
  static const double bottomNavigationContentGap = 32.0;

  /// Insets for a screen-owned action placed above the app shell.
  ///
  /// The app shell already owns persistent-navigation and system-safe-area
  /// clearance, so child screens must not repeat those measurements.
  static const EdgeInsets bottomActionPadding = EdgeInsets.fromLTRB(
    16,
    8,
    16,
    8,
  );

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
