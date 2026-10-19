import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final analytics = File(
    'lib/features/analytics/screens/enhanced_analytics_dashboard_screen.dart',
  ).readAsStringSync();

  final lock = File(
    'lib/features/premium/widgets/premium_feature_lock_screen.dart',
  ).readAsStringSync();

  test('Advanced Analytics uses full-screen Premium lock instead of alert', () {
    expect(analytics, contains('PremiumFeatureLockScreen('));
    expect(
      analytics,
      contains("PremiumPaywallScreen(highlightFeature: 'analytics')"),
    );

    final blockedStart = analytics.indexOf(
      'Widget _buildPremiumBlockedScreen(ThemeData theme)',
    );
    final headerStart = analytics.indexOf(
      'Widget _buildHeader(ThemeData theme',
    );

    expect(blockedStart, greaterThanOrEqualTo(0));
    expect(headerStart, greaterThan(blockedStart));

    final blocked = analytics.substring(blockedStart, headerStart);

    expect(blocked, isNot(contains('showPremiumUpgradeDialog(')));
    expect(blocked, isNot(contains('Colors.amber')));
    expect(blocked, isNot(contains('Health Intelligence Score')));
    expect(blocked, isNot(contains('greater accuracy')));
  });

  test('full-screen Premium lock owns luxury visual language', () {
    expect(lock, contains('Color(0xFF130C1B)'));
    expect(lock, contains('Color(0xFFFF5FA2)'));
    expect(lock, contains('Color(0xFFD88EFF)'));
    expect(lock, contains('BackdropFilter('));
    expect(lock, contains('CustomPaint('));
    expect(lock, contains('Unlock Premium'));
    expect(lock, contains('Maybe Later'));
    expect(lock, contains('Secure and private'));
    expect(lock, contains('Not medical advice'));
  });

  test('Premium preview copy avoids unsupported product claims', () {
    expect(lock, isNot(contains('Trusted by women')));
    expect(lock, isNot(contains('Health Intelligence Score')));
    expect(lock, isNot(contains('greater accuracy')));
    expect(lock, isNot(contains('Priority Support')));
  });
}
