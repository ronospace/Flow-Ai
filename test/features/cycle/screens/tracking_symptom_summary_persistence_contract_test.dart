import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('saving does not collapse selected symptoms', () {
    final trackingSource = File(
      'lib/features/cycle/screens/tracking_screen.dart',
    ).readAsStringSync();

    final saveLinkedCollapse = RegExp(
      r'collapseSelectedSummary\s*:\s*'
      r'[^,]*\b_recentlySaved\b',
      multiLine: true,
      dotAll: true,
    );

    expect(
      saveLinkedCollapse.hasMatch(trackingSource),
      isFalse,
      reason:
          'Saving must not collapse selected symptoms. '
          'Collapse requires an explicit user-controlled action.',
    );
  });

  test('selected symptoms default to expanded', () {
    final selectorSource = File(
      'lib/features/cycle/widgets/symptom_selector.dart',
    ).readAsStringSync();

    expect(selectorSource, contains('this.collapseSelectedSummary = false'));
  });
  test('saved-state collapse is disabled by the owner', () {
    final selectorSource = File(
      'lib/features/cycle/widgets/symptom_selector.dart',
    ).readAsStringSync();

    expect(
      selectorSource,
      contains('bool get _shouldCollapseSelectedSummary => false;'),
    );
    expect(selectorSource, isNot(contains('widget.collapseSelectedSummary')));
  });
}
