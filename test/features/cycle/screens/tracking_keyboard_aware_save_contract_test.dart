import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/cycle/screens/tracking_screen.dart',
  ).readAsStringSync();

  test('Save remains hidden while the software keyboard is visible', () {
    expect(source, contains('MediaQuery.viewInsetsOf(context).bottom > 0'));
    expect(
      source,
      contains('!_isKeyboardVisible && (_hasUnsavedChanges || _isSaving)'),
    );
  });

  test('Notes keyboard exposes Done and dismisses focus', () {
    expect(source, contains('keyboardType: TextInputType.multiline'));
    expect(source, contains('textInputAction: TextInputAction.done'));
    expect(source, isNot(contains('textInputAction: TextInputAction.newline')));
    expect(source, contains('onEditingComplete: ()'));
    expect(source, contains('FocusManager.instance.primaryFocus?.unfocus();'));
  });

  test('Successful save clears the dirty state', () {
    expect(source, contains('_hasUnsavedChanges = false;'));
  });
}
