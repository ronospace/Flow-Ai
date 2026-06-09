import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Track save action participates in layout instead of overlaying content',
    () {
      final source = File(
        'lib/features/cycle/screens/tracking_screen.dart',
      ).readAsStringSync();

      final buildStart = source.indexOf('Widget build(BuildContext context)');
      final buildEnd = source.indexOf(
        'Widget _buildCustomAppBar()',
        buildStart,
      );

      expect(buildStart, greaterThanOrEqualTo(0));
      expect(buildEnd, greaterThan(buildStart));

      final buildSource = source.substring(buildStart, buildEnd);

      expect(buildSource, contains('_buildSaveActionArea()'));
      expect(buildSource, isNot(contains('Stack(')));
      expect(buildSource, isNot(contains('Positioned(')));

      expect(source, contains('AppLayout.bottomActionPadding'));
      expect(
        source,
        isNot(contains('bottom: MediaQuery.of(context).viewInsets.bottom > 0')),
      );
    },
  );
}
