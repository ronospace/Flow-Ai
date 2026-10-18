import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Track content owns the full layout after Save action removal', () {
    final source = File(
      'lib/features/cycle/screens/tracking_screen.dart',
    ).readAsStringSync();

    final buildStart = source.indexOf('Widget build(BuildContext context)');
    final buildEnd = source.indexOf('Widget _buildCustomAppBar()', buildStart);

    expect(buildStart, greaterThanOrEqualTo(0));
    expect(buildEnd, greaterThan(buildStart));

    final buildSource = source.substring(buildStart, buildEnd);

    expect(buildSource, contains('Expanded('));
    expect(buildSource, contains('PageView('));

    expect(buildSource, isNot(contains('_buildSaveActionArea()')));
    expect(buildSource, isNot(contains('Stack(')));
    expect(buildSource, isNot(contains('Positioned(')));

    expect(source, isNot(contains('_showSaveAction')));
    expect(source, isNot(contains('_buildSaveButton')));
    expect(source, isNot(contains('track-save-button')));
    expect(source, isNot(contains('AppLayout.bottomActionPadding')));
  });
}
