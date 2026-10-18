import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final layout = File(
    'lib/core/layout/app_layout_metrics.dart',
  ).readAsStringSync();

  final auth = File(
    'lib/features/auth/screens/auth_screen.dart',
  ).readAsStringSync();

  test('auth responsive composition remains safe-height driven', () {
    expect(
      layout,
      contains('static const double authTallHeightBreakpoint = 860;'),
    );

    expect(layout, contains('static const double authHeaderBottom = 12;'));

    expect(layout, contains('static const double authHeaderBottomTall = 32;'));

    expect(
      layout,
      contains('static double authHeaderBottomForHeight(double safeHeight)'),
    );

    expect(layout, contains('safeHeight >= authTallHeightBreakpoint'));
    expect(layout, contains('? authHeaderBottomTall'));
    expect(layout, contains(': authHeaderBottom'));
  });

  test('AuthScreen consumes centralized safe-height responsive spacing', () {
    expect(
      auth,
      contains('AppLayoutMetrics.authHeaderBottomForHeight(availableHeight)'),
    );

    expect(
      auth,
      isNot(contains('TargetPlatform.android')),
      reason: 'Responsive vertical composition must not branch on Android.',
    );

    expect(
      auth,
      isNot(contains('Transform.translate')),
      reason: 'Auth parity must not use local translation hacks.',
    );
  });

  test('component geometry remains outside the responsive mutation', () {
    expect(layout, contains('static const double authLogoSize = 84;'));

    expect(
      layout,
      contains('static const double authPrimaryActionHeight = 52;'),
    );

    expect(layout, contains('static const double authFieldGap = 16;'));

    expect(layout, contains('static const double authDividerGap = 18;'));
  });
}
