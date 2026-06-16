import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/cycle/screens/tracking_screen.dart',
    ).readAsStringSync();
  });

  test('save action is hidden while the keyboard is visible', () {
    expect(source, contains('bool get _isKeyboardVisible =>'));
    expect(source, contains('MediaQuery.viewInsetsOf(context).bottom > 0;'));
    expect(
      source,
      contains('!_isKeyboardVisible && (_hasUnsavedChanges || _isSaving);'),
    );
  });

  test('saved state does not keep the large save action visible', () {
    expect(
      source,
      isNot(
        contains(
          'bool get _showSaveAction => '
          '_hasUnsavedChanges || _isSaving || _recentlySaved;',
        ),
      ),
    );
  });

  test('notes remain multiline and Return inserts a newline', () {
    expect(source, contains('keyboardType: TextInputType.multiline'));
    expect(source, contains('textInputAction: TextInputAction.newline'));
  });

  test('notes edits immediately mark tracking state unsaved', () {
    expect(source, contains('_notes = value;'));
    expect(source, contains('_markUnsavedChanges();'));
  });
}
