import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = File(
    'lib/features/premium/services/subscription_management_service.dart',
  ).readAsStringSync();

  final screen = File(
    'lib/features/premium/screens/premium_subscription_screen.dart',
  ).readAsStringSync();

  final plan = File(
    'lib/features/premium/models/subscription_plan.dart',
  ).readAsStringSync();

  final comparison = File(
    'lib/features/premium/widgets/feature_comparison_widget.dart',
  ).readAsStringSync();

  test('subscription management opens real store account pages', () {
    expect(
      service,
      contains('https://play.google.com/store/account/subscriptions'),
    );
    expect(service, contains('?package=com.flowai.app'));

    expect(service, contains('https://apps.apple.com/account/subscriptions'));

    expect(service, contains('LaunchMode.externalApplication'));
  });

  test('subscription screen wires the management action', () {
    expect(screen, contains('SubscriptionManagementService.open();'));

    expect(
      screen,
      contains("import '../services/subscription_management_service.dart';"),
    );
  });

  test('unsupported numerical accuracy claims are absent', () {
    expect(plan, isNot(contains('95% accuracy')));
    expect(comparison, isNot(contains('95% accuracy')));
  });
}
