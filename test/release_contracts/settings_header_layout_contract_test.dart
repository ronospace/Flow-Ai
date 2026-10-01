import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Settings has one fixed SafeArea-owned header', () {
    final source = File(
      'lib/features/settings/screens/settings_screen.dart',
    ).readAsStringSync();

    expect(source, contains('child: SafeArea('));
    expect(source, contains('// Fixed Settings header.'));
    expect(
      source,
      contains('padding: const EdgeInsets.fromLTRB(20, 12, 20, 20)'),
    );
    expect(source, contains('AppPageTypography.title(context)'));

    expect(source, isNot(contains('expandedHeight: 96')));
    expect(source, isNot(contains('FlexibleSpaceBar(')));
  });
}
