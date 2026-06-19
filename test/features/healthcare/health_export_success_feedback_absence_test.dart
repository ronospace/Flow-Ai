import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('export success path stays silent and structurally clean', () {
    const sourcePath =
        'lib/features/healthcare/screens/'
        'healthcare_provider_portal_screen.dart';

    final source = File(sourcePath).readAsStringSync();
    const forbiddenFeedback = 'Health data exported successfully!';

    final exportStart = source.indexOf('Future<void> _exportData()');
    final shareStart = source.indexOf(
      'Future<void> _shareExport()',
      exportStart,
    );

    expect(exportStart, greaterThanOrEqualTo(0));
    expect(shareStart, greaterThan(exportStart));

    final exportMethod = source.substring(exportStart, shareStart);
    final emptyMountedGuard = RegExp(
      r'if\s*\(\s*mounted\s*\)\s*\{\s*\}',
      multiLine: true,
    );

    expect(source, isNot(contains(forbiddenFeedback)));
    expect(emptyMountedGuard.hasMatch(exportMethod), isFalse);
    expect(source, contains('Future<void> _shareExport()'));
    expect(source, contains('Share.shareXFiles'));
  });
}
