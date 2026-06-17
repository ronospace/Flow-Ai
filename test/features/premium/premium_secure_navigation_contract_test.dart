import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production navigation uses only the secure Premium paywall', () {
    const legacyDefinition =
        'lib/features/premium/screens/premium_subscription_screen.dart';

    final legacyReferences = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final path = entity.path.replaceAll(r'\', '/');

      if (path.endsWith(legacyDefinition)) {
        continue;
      }

      final source = entity.readAsStringSync();

      if (source.contains('PremiumSubscriptionScreen') ||
          source.contains('premium_subscription_screen.dart')) {
        legacyReferences.add(path);
      }
    }

    expect(legacyReferences, isEmpty);

    final router = File('lib/core/routing/app_router.dart').readAsStringSync();

    expect(router, contains('PremiumPaywallScreen'));
    expect(router, contains('/premium'));
  });
}
