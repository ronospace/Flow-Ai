import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/cycle/screens/tracking_screen.dart',
  ).readAsStringSync();

  test('Save is hidden while Notes owns focus or keyboard is visible', () {
    expect(source, contains('final FocusNode _notesFocusNode'));
    expect(source, contains('_notesFocusNode.hasFocus'));
    expect(source, contains('MediaQuery.viewInsetsOf(context).bottom > 0'));
    expect(source, contains('!_isNotesEditing'));
    expect(source, contains('!_isKeyboardVisible'));
  });

  test('Notes keyboard uses Done and dismisses focus', () {
    expect(source, contains('keyboardType: TextInputType.text'));
    expect(source, contains('textInputAction: TextInputAction.done'));
    expect(source, isNot(contains('textInputAction: TextInputAction.newline')));
    expect(source, contains('onEditingComplete: _finishNotesEditing,'));
    expect(source, contains('_notesFocusNode.unfocus();'));
  });

  test('Save appears only for dirty state after editing finishes', () {
    expect(
      source,
      contains('(_hasUnsavedChanges || _isSaving || _recentlySaved)'),
    );
    expect(source, contains('_hasUnsavedChanges = false;'));
  });
}
