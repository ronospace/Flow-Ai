import 'dart:io';

import 'package:flow_ai/features/cycle/widgets/premium_feature_preview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpPair(WidgetTester tester, {required double scale}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));

  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  key: const ValueKey('soon-card'),
                  width: 171,
                  height: 210,
                  child: PremiumFeaturePreviewCard(
                    title: 'AI Health Coach',
                    description: 'Personal health guidance powered by AI',
                    icon: Icons.auto_awesome,
                    color: Colors.purple,
                    estimatedDate: 'Q2 2026',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  key: const ValueKey('active-card'),
                  width: 171,
                  height: 210,
                  child: PremiumFeaturePreviewCard(
                    title: 'Partner Connect',
                    description:
                        'Securely share cycle data with trusted partners',
                    icon: Icons.favorite,
                    color: Colors.pink,
                    estimatedDate: 'NEW',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  test('description is tight-expanded and remains two lines', () {
    final source = File(
      'lib/features/cycle/widgets/premium_feature_preview_card.dart',
    ).readAsStringSync();

    expect(
      RegExp(
        r'Expanded\(\s*flex\s*:\s*2,\s*'
        r'child\s*:\s*Text\(\s*description,\s*'
        r'maxLines\s*:\s*2,',
        dotAll: true,
      ).hasMatch(source),
      isTrue,
    );

    expect(source, contains('maxLines: 1'));
    expect(source, contains('softWrap: false'));
  });

  for (final scale in <double>[1.0, 1.2, 1.35]) {
    testWidgets('status rows are low and aligned at ${scale}x', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpPair(tester, scale: scale);

      expect(tester.takeException(), isNull);

      final soonCard = tester.getRect(find.byKey(const ValueKey('soon-card')));
      final activeCard = tester.getRect(
        find.byKey(const ValueKey('active-card')),
      );

      final soon = tester.getRect(find.text('Coming Soon'));
      final active = tester.getRect(find.text('Active'));

      final soonGap = soonCard.bottom - soon.bottom;
      final activeGap = activeCard.bottom - active.bottom;
      final alignment = (soon.bottom - active.bottom).abs();

      expect(soonGap, inInclusiveRange(6, 49));
      expect(activeGap, inInclusiveRange(6, 49));
      expect(alignment, lessThanOrEqualTo(3));

      debugPrint(
        'PREMIUM_FIT scale=$scale '
        'soonGap=$soonGap activeGap=$activeGap '
        'alignment=$alignment',
      );
    });
  }
}
