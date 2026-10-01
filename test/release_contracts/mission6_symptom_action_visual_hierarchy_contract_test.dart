import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final action = File(
    'lib/core/ui/app_section_action_button.dart',
  ).readAsStringSync();

  final health = File(
    'lib/features/health/screens/health_screen.dart',
  ).readAsStringSync();

  test('shared section action is a true primary filled action', () {
    expect(action, contains('backgroundColor: accentColor'));

    expect(action, contains('foregroundColor: AppTheme.onBrightAccent'));

    expect(
      action,
      isNot(contains('backgroundColor: accentColor.withValues(alpha: 0.14)')),
    );
  });

  test('Add Symptom keeps Flow Ai rose action semantics', () {
    expect(health, contains("label: 'Add Symptom'"));

    expect(health, contains('accentColor: AppTheme.symptomActionRose'));

    expect(health, contains('onPressed: _openSymptomTracker'));
  });

  test('symptom chips remain visually secondary and neutral', () {
    expect(health, contains('theme.colorScheme.surfaceContainerHighest'));

    expect(health, contains('theme.colorScheme.onSurfaceVariant'));
  });
}
