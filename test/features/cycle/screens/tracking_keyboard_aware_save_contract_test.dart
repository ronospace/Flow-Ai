import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/cycle/screens/tracking_screen.dart',
  ).readAsStringSync();

  test('Notes keyboard uses Done as persistence boundary', () {
    expect(source, contains('keyboardType: TextInputType.text'));
    expect(source, contains('textInputAction: TextInputAction.done'));
    expect(source, isNot(contains('textInputAction: TextInputAction.newline')));
    expect(source, contains('onEditingComplete: _finishNotesEditing'));
    expect(
      source,
      contains('_flushPendingAutosave(showFailureFeedback: true)'),
    );
  });

  test('Track no longer exposes redundant manual Save UI', () {
    expect(source, isNot(contains('_showSaveAction')));
    expect(source, isNot(contains('_buildSaveActionArea')));
    expect(source, isNot(contains('_buildSaveButton')));
    expect(source, isNot(contains('track-save-button')));
    expect(source, isNot(contains('Save Changes')));
  });
}
