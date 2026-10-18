import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final screen = File(
    'lib/features/onboarding/screens/onboarding_screen.dart',
  ).readAsStringSync();

  final setup = File(
    'lib/features/onboarding/widgets/setup_form.dart',
  ).readAsStringSync();

  test('notification permission advances without success feedback', () {
    final block = screen
        .split('Future<void> _handlePermissionRequest(')[1]
        .split('Future<void> _handleSetupAutosave(')[0];

    expect(block, contains('requestNotificationPermission()'));
    expect(block, contains('_nextStep(provider)'));
    expect(block, isNot(contains('_showSuccessMessage')));
    expect(block, isNot(contains('AdaptiveMessages.showSuccess')));
  });

  test('setup no longer exposes manual save action', () {
    expect(setup, isNot(contains('Save Preferences')));
    expect(setup, isNot(contains('_saveSetup')));
    expect(setup, isNot(contains('onSave')));
    expect(setup, isNot(contains('_formKey')));
  });

  test('setup autosaves every editable group', () {
    final sliderAutosaveHandlers = RegExp(
      r'onChangeEnd:\s*\(_\)\s*\{[\s\S]*?_queueAutosave\(\);',
    ).allMatches(setup).length;

    expect(sliderAutosaveHandlers, 2);

    expect(
      RegExp(r'_queueAutosave\(\);').allMatches(setup).length,
      greaterThanOrEqualTo(3),
    );

    expect(setup, contains("'cycleLength': _cycleLength"));
    expect(setup, contains("'periodLength': _periodLength"));
    expect(setup, contains("'goals': List<String>.from(_selectedGoals)"));
    expect(
      setup,
      contains("'reminders': Map<String, bool>.from(_reminderSettings)"),
    );
  });

  test('setup autosave writes are serialized', () {
    expect(setup, contains('Future<void> _saveChain = Future<void>.value()'));
    expect(
      setup,
      contains(
        '_saveChain = _saveChain.then((_) => widget.onChanged(snapshot))',
      ),
    );
  });

  test('default setup preferences are persisted automatically', () {
    expect(setup, contains('WidgetsBinding.instance.addPostFrameCallback'));
    expect(setup, contains('_queueAutosave();'));
  });
}
