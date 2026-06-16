import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String extractNotesMethod(String source) {
  const startSignature = '  Widget _buildNotesTab() {';
  const endSignature = '  Widget _buildQuickNote(';

  final start = source.indexOf(startSignature);

  if (start < 0) {
    throw StateError('_buildNotesTab() was not found');
  }

  final end = source.indexOf(endSignature, start);

  if (end <= start) {
    throw StateError('_buildQuickNote() was not found after _buildNotesTab()');
  }

  return source.substring(start, end);
}

void main() {
  late String notes;

  setUpAll(() {
    final source = File(
      'lib/features/cycle/screens/tracking_screen.dart',
    ).readAsStringSync();

    notes = extractNotesMethod(source);
  });

  test('Notes has one keyboard-aware vertical owner', () {
    expect(
      RegExp(r'\bSingleChildScrollView\s*\(').allMatches(notes),
      hasLength(1),
    );

    expect(notes, contains("ValueKey('track-notes-scroll-view')"));

    expect(
      notes,
      contains(
        'keyboardDismissBehavior: '
        'ScrollViewKeyboardDismissBehavior.onDrag',
      ),
    );
  });

  test('Notes avoids duplicate keyboard-inset compensation', () {
    expect(notes, isNot(contains('MediaQuery.viewInsetsOf(context).bottom')));

    expect(notes, contains('scrollPadding:'));
  });

  test('Notes removes rigid editor frames and legacy spacer', () {
    expect(notes, isNot(contains('BoxConstraints(minHeight: 200)')));

    expect(notes, isNot(contains('BoxConstraints(minHeight: 180)')));

    expect(notes, isNot(contains('SizedBox(height: 140)')));

    expect(notes, contains("ValueKey('track-notes-editor')"));

    expect(notes, contains("ValueKey('track-notes-input-area')"));
  });

  test('Notes field is multiline and semantic', () {
    expect(notes, contains("ValueKey('track-notes-field')"));

    expect(notes, contains('keyboardType: TextInputType.multiline'));
    expect(notes, contains('textInputAction: TextInputAction.done'));
    expect(notes, contains('onEditingComplete: ()'));
    expect(notes, contains('FocusManager.instance.primaryFocus?.unfocus();'));

    expect(notes, contains('textInputAction: TextInputAction.done'));

    expect(notes, contains('textCapitalization: TextCapitalization.sentences'));

    expect(notes, contains('textField: true'));

    expect(notes, contains('label: AppLocalizations.of(context).notesTab'));
  });

  test('every changed Notes value marks tracking state unsaved', () {
    final onChangedStart = notes.indexOf('onChanged: (value) {');

    if (onChangedStart < 0) {
      fail('Notes onChanged owner was not found');
    }

    final onTapOutsideStart = notes.indexOf('onTapOutside:', onChangedStart);

    if (onTapOutsideStart <= onChangedStart) {
      fail('Notes onTapOutside boundary was not found');
    }

    final onChangedBlock = notes.substring(onChangedStart, onTapOutsideStart);

    expect(onChangedBlock, contains('_notes = value;'));

    expect(onChangedBlock, contains('_markUnsavedChanges();'));

    expect(
      notes,
      isNot(contains('_notesController.text.trim() != _notes.trim()')),
    );
  });
}
