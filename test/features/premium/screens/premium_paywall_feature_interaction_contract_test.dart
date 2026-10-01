import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Premium paywall feature interaction contract', () {
    late String source;

    setUpAll(() {
      source = File(
        'lib/features/premium/screens/premium_paywall_screen.dart',
      ).readAsStringSync();
    });

    test('benefit cards are explicit interactive controls', () {
      expect(source, contains('child: InkWell('));
      expect(
        source,
        contains('onTap: () => _handleFeatureTap(context, feature)'),
      );
      expect(source, contains('premium-feature-'));
      expect(source, contains('borderRadius: BorderRadius.circular(16)'));
    });

    test('feature taps guide users to subscription options', () {
      expect(
        source,
        contains('final GlobalKey _subscriptionOptionsKey = GlobalKey();'),
      );
      expect(source, contains('key: _subscriptionOptionsKey'));
      expect(source, contains('Scrollable.ensureVisible('));
      expect(
        source,
        contains('Choose a plan below to unlock \${feature.title}.'),
      );
    });

    test('only supported Premium benefits remain present', () {
      for (final label in <String>[
        'Unlimited AI Insights',
        'Advanced Analytics',
        'Export Your Data',
      ]) {
        expect(source, contains(label), reason: 'Missing benefit: $label');
      }
      expect(source, isNot(contains('Ad-Free Experience')));
      expect(source, isNot(contains('Priority Support')));
    });
  });
}
