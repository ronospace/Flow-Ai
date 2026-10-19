import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final policy = File(
    'lib/features/premium/models/premium_tile_policy.dart',
  ).readAsStringSync();

  final preview = File(
    'lib/features/cycle/widgets/premium_features_preview.dart',
  ).readAsStringSync();

  final card = File(
    'lib/features/cycle/widgets/premium_feature_preview_card.dart',
  ).readAsStringSync();

  const titles = <String>[
    'AI Health Coach',
    'Partner Connect',
    'Healthcare Portal',
    'Advanced Analytics',
  ];

  test('each preview tile has exactly one policy classification', () {
    for (final title in titles) {
      expect(
        RegExp("title: '$title'").allMatches(preview).length,
        1,
        reason: '$title visible tile duplicated or missing',
      );

      expect(
        RegExp("'$title': PremiumTileState\\.").allMatches(policy).length,
        1,
        reason: '$title policy duplicated or missing',
      );
    }
  });

  test('current production tile truth remains fail closed', () {
    expect(policy, contains("'AI Health Coach': PremiumTileState.comingSoon"));

    expect(
      policy,
      contains("'Advanced Analytics': PremiumTileState.premiumLocked"),
    );

    expect(policy, contains("'Partner Connect': PremiumTileState.free"));

    expect(policy, contains("'Healthcare Portal': PremiumTileState.free"));
  });

  test('Premium lock visual has one centralized card implementation', () {
    expect(RegExp(r'final bool isPremiumLocked;').allMatches(card).length, 1);

    expect(RegExp(r'this\.isPremiumLocked = false').allMatches(card).length, 1);

    expect(card, contains("? 'PRO' : estimatedDate"));
    expect(card, contains("? Icons.lock_rounded"));
    expect(card, contains("? 'Premium'"));
  });

  test('Advanced Analytics consumes central Premium tile policy', () {
    final lockCall = RegExp(
      r"PremiumTilePolicy"
      r"\s*\.\s*isPremiumLocked"
      r"\s*\("
      r"\s*'Advanced Analytics'"
      r"\s*,?"
      r"\s*\)",
    );

    expect(
      lockCall.allMatches(preview).length,
      1,
      reason:
          'Advanced Analytics must consume exactly one centralized Premium lock.',
    );
  });
}
