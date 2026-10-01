import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/premium/screens/premium_paywall_screen.dart',
  ).readAsStringSync();

  test('Premium header never truncates the primary subtitle', () {
    expect(source, contains("'Access Unlimited Premium Features'"));

    final start = source.indexOf("'Access Unlimited Premium Features'");

    expect(start, greaterThanOrEqualTo(0));

    final fittedBoxStart = source.lastIndexOf('FittedBox(', start);
    expect(fittedBoxStart, greaterThanOrEqualTo(0));

    final end = (start + 900).clamp(0, source.length);
    final block = source.substring(fittedBoxStart, end);

    expect(block, contains('FittedBox('));
    expect(block, contains('fit: BoxFit.scaleDown'));
    expect(block, contains('maxLines: 1'));
    expect(block, contains('softWrap: false'));
  });

  test(
    'Premium subtitle preserves accepted iPhone size and scales on wider screens',
    () {
      final normalized = source.replaceAll(RegExp(r'\s+'), ' ');

      expect(
        normalized,
        contains(
          'final subtitleFontSize = MediaQuery.sizeOf(context).width >= 400.0 ? 15.0 : 14.0;',
        ),
      );

      expect(normalized, contains('fontSize: subtitleFontSize'));

      expect(source, isNot(contains('TargetPlatform.android')));

      expect(source, isNot(contains('Platform.isAndroid')));
    },
  );

  test('free purchase hierarchy keeps restore and legal after catalog', () {
    final catalog = source.indexOf('_buildCatalogSection(');
    final restore = source.indexOf('_buildRestorePurchasesButton(', catalog);
    final legal = source.indexOf('_buildPremiumLegalSection(context)', restore);

    expect(catalog, greaterThanOrEqualTo(0));
    expect(restore, greaterThan(catalog));
    expect(legal, greaterThan(restore));
  });

  test('compact legal cards remain responsive', () {
    expect(
      source,
      contains('constraints: const BoxConstraints(minHeight: 52)'),
    );
    expect(source, contains('constraints.maxWidth < 300'));
    expect(source, contains('Icons.keyboard_arrow_down_rounded'));
  });
}
