import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const paywallPath =
      'lib/features/premium/screens/premium_paywall_screen.dart';

  String source() => File(paywallPath).readAsStringSync();

  test('Premium paywall keeps release-proven capabilities', () {
    final text = source();

    expect(text, contains('Unlimited AI Insights'));
    expect(text, contains('Advanced Analytics'));
    expect(text, contains('Explore your health trends and patterns'));
    expect(text, contains('Export Your Data'));
    expect(text, contains('Download reports in PDF or CSV format'));
  });

  test('Premium paywall excludes capabilities not yet release-proven', () {
    final text = source();

    expect(text, isNot(contains('Deep health condition detection & tracking')));
    expect(text, isNot(contains('Ad-Free Experience')));
    expect(text, isNot(contains('Priority Support')));
  });

  test('active Premium metadata excludes unproven secondary claims', () {
    final paths = <String>[
      'lib/features/premium/services/subscription_service.dart',
      'lib/features/premium/providers/subscription_provider.dart',
      'lib/features/premium/widgets/upgrade_prompt_dialog.dart',
      'lib/features/premium/models/subscription_plan.dart',
      'lib/features/premium/services/premium_service.dart',
    ];

    final combined = paths
        .map((path) => File(path).readAsStringSync())
        .join('\n');

    expect(combined, isNot(contains('Advanced health condition detection')));

    expect(combined.toLowerCase(), isNot(contains('ad-free experience')));

    expect(combined.toLowerCase(), isNot(contains('priority support')));

    expect(
      combined.toLowerCase(),
      isNot(contains('24/7 priority customer support')),
    );
  });

  test('serialized prioritySupport compatibility key remains fail closed', () {
    final model = File(
      'lib/features/premium/models/premium_feature.dart',
    ).readAsStringSync();

    final provider = File(
      'lib/features/premium/providers/premium_provider.dart',
    ).readAsStringSync();

    expect(model, contains('prioritySupport'));

    final caseIndex = provider.indexOf("case 'prioritySupport':");

    expect(caseIndex, greaterThanOrEqualTo(0));

    final end = (caseIndex + 350) < provider.length
        ? caseIndex + 350
        : provider.length;

    final region = provider.substring(caseIndex, end);

    expect(region, contains('return false;'));
  });

  test('whole Premium domain excludes unsupported women-health marketing', () {
    final premiumRoot = Directory('lib/features/premium');

    final combined = premiumRoot
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n')
        .toLowerCase();

    for (final forbidden in <String>[
      '95%+ prediction accuracy',
      '95%+ accuracy',
      'healthcare provider integration',
      'healthcare integration',
      'connect with doctors',
      'connect wearable devices',
      'sync with wearables',
      'multi-user profiles',
      'manage multiple family member profiles',
      'manage up to 5 profiles',
      'family health tracking',
      'predictive health modeling',
      'export to healthcare providers',
      'white-glove support',
      'lifetime data storage',
      'deep health condition detection',
    ]) {
      expect(
        combined,
        isNot(contains(forbidden)),
        reason: 'Unsupported Premium promise must not ship: $forbidden',
      );
    }
  });
}
