import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/cycle/screens/tracking_screen.dart',
  ).readAsStringSync();

  test('Notes editing retains explicit Done completion', () {
    expect(source, contains('final FocusNode _notesFocusNode'));
    expect(source, contains('onTap: _beginNotesEditing'));
    expect(source, contains('onEditingComplete: _finishNotesEditing'));
    expect(source, contains('_notesFocusNode.unfocus();'));
  });

  test('Notes Done flushes through serialized autosave authority', () {
    expect(
      source,
      contains('_flushPendingAutosave(showFailureFeedback: true)'),
    );
    expect(source, contains('Future<void> _saveChain = Future<void>.value()'));
    expect(source, contains('await _saveChain;'));
  });
}
