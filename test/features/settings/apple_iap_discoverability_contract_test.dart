import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final settings = File(
    'lib/features/settings/screens/settings_screen.dart',
  ).readAsStringSync();

  final router = File('lib/core/routing/app_router.dart').readAsStringSync();

  test('Settings exposes exactly one permanent Premium entry point', () {
    expect(RegExp("title: 'Flow Ai Premium'").allMatches(settings).length, 1);

    expect(
      settings,
      contains("'View Monthly and Yearly subscription options'"),
    );

    expect(settings, contains("context.push('/premium')"));
  });

  test('Premium route resolves directly to production paywall', () {
    expect(router, contains("path: '/premium'"));
    expect(router, contains("name: 'premium'"));
    expect(
      router,
      contains('builder: (context, state) => const PremiumPaywallScreen()'),
    );
  });
}
