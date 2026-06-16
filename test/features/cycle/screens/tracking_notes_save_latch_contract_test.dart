import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/cycle/screens/tracking_screen.dart',
  ).readAsStringSync();

  test('Notes latches editing before keyboard visibility changes', () {
    expect(source, contains('bool _notesEditorActive = false;'));
    expect(source, contains('onTap: _beginNotesEditing,'));
    expect(source, contains('onEditingComplete: _finishNotesEditing,'));
  });

  test('Save remains hidden throughout Notes editing', () {
    expect(source, contains('_notesEditorActive || _notesFocusNode.hasFocus'));
    expect(source, contains('!_isNotesEditing &&'));
    expect(source, contains('!_isKeyboardVisible &&'));
  });

  test('Save button is removed from painting while hidden', () {
    expect(source, contains('Offstage('));
    expect(source, contains('offstage: !_showSaveAction'));
  });
}
