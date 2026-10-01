import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/tracking/screens/enhanced_daily_feelings_tracker.dart',
  ).readAsStringSync();

  test('Daily Feelings Save appears without an artificial delay', () {
    expect(source, isNot(contains('scale(delay: 1600.ms)')));
    expect(source, isNot(contains('delay: 1600.ms')));
  });

  test('Save uses one existing persistence action', () {
    expect(source, contains('onTap: enabled ? _saveEntry : null'));
    expect(RegExp(r'Future<void> _saveEntry\(\)').allMatches(source).length, 1);
  });

  test('Save feedback uses a frosted glass surface', () {
    expect(source, contains('BackdropFilter('));
    expect(source, contains('ImageFilter.blur(sigmaX: 18, sigmaY: 18)'));
    expect(source, contains('ClipRRect('));
  });

  test('Save gives immediate saving feedback', () {
    expect(source, contains("'Saving…'"));
    expect(source, contains("'Save'"));
    expect(source, contains('daily-feelings-saving'));
    expect(source, contains('daily-feelings-save-ready'));
  });

  test('Done-gated Save behavior remains intact', () {
    expect(
      source,
      contains('if (!_hasUnsavedChanges || !_notesEditCommitted)'),
    );
  });
}
