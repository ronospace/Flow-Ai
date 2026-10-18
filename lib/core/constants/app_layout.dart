import 'package:flutter/widgets.dart';

class AppLayout {
  const AppLayout._();

  static const double bottomNavigationHeight = 72.0;
  static const double bottomNavigationContentGap = 32.0;

  /// Calendar page landing scroll padding.
  ///
  /// The app shell owns the persistent bottom-navigation carrier, so Calendar
  /// must not duplicate that clearance inside its own scroll view.
  static const EdgeInsets calendarLandingScrollPadding = EdgeInsets.zero;

  /// Stable bottom summary-card margin for the Calendar landing position.
  static const EdgeInsets calendarLandingSummaryCardMargin = EdgeInsets.all(
    24.0,
  );

  /// Scroll offset tolerance before Calendar springs back to its landing point.
  static const double calendarLandingSpringBackTolerance = 0.5;

  /// Duration used when Calendar returns to the stable landing point.
  static const Duration calendarLandingSpringBackDuration = Duration(
    milliseconds: 520,
  );

  /// Curve used when Calendar returns to the stable landing point.
  static const Curve calendarLandingSpringBackCurve = Curves.easeInOutCubic;

  /// Authoritative onboarding page-transition duration.
  static const Duration onboardingPageTransitionDuration = Duration(
    milliseconds: 300,
  );

  /// Authoritative onboarding page-transition curve.
  static const Curve onboardingPageTransitionCurve = Curves.easeInOut;

  /// Authoritative onboarding page physics.
  ///
  /// PageScrollPhysics preserves page snapping while BouncingScrollPhysics
  /// provides the same centralized edge spring-back behavior on both
  /// supported mobile platforms.
  static const ScrollPhysics onboardingPagePhysics = PageScrollPhysics(
    parent: BouncingScrollPhysics(),
  );

  /// The long Setup step owns a vertical scroll view. Disabling horizontal
  /// finger paging there prevents gesture-arena competition with that
  /// vertical scroller while programmatic onboarding navigation remains
  /// available.
  static const ScrollPhysics onboardingSetupPagePhysics =
      NeverScrollableScrollPhysics();

  /// Minimum horizontal release velocity required to navigate the Setup step.
  ///
  /// Matches the established horizontal-swipe threshold used elsewhere in
  /// the app.
  static const double onboardingSetupSwipeVelocityThreshold = 120.0;

  /// Authoritative vertical scrolling behavior for the long onboarding
  /// setup step.
  static const ScrollPhysics onboardingSetupScrollPhysics =
      BouncingScrollPhysics();

  /// Setup reuses the established production spring-back motion contract.
  static const double onboardingSetupLandingTolerance =
      calendarLandingSpringBackTolerance;

  static const Duration onboardingSetupLandingSpringBackDuration =
      calendarLandingSpringBackDuration;

  static const Curve onboardingSetupLandingSpringBackCurve =
      calendarLandingSpringBackCurve;

  /// The fixed onboarding navigation owns the lower action spacing, so the
  /// setup scroller must not add a second bottom inset.
  static const EdgeInsets onboardingSetupScrollPadding = EdgeInsets.fromLTRB(
    24,
    24,
    24,
    0,
  );

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
