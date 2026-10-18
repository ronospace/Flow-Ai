import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/cycle/screens/tracking_screen.dart',
  ).readAsStringSync();

  test('Track owns lifecycle-aware persistence', () {
    expect(
      source,
      contains('with TickerProviderStateMixin, WidgetsBindingObserver'),
    );
    expect(source, contains('WidgetsBinding.instance.addObserver(this);'));
    expect(source, contains('WidgetsBinding.instance.removeObserver(this);'));
    expect(source, contains('didChangeAppLifecycleState'));
    expect(source, contains('AppLifecycleState.paused'));
    expect(source, contains('AppLifecycleState.hidden'));
    expect(source, contains('AppLifecycleState.detached'));
  });

  test('tracking persistence uses one serialized autosave authority', () {
    expect('_saveChain = _saveChain.then('.allMatches(source).length, 1);
    expect(source, contains('await _saveChain;'));
    expect(
      source,
      contains('_TrackingSaveSnapshot _captureTrackingSnapshot()'),
    );

    expect(source, isNot(contains('_saveTrackingData')));
    expect(source, isNot(contains('_buildSaveButton')));
    expect(source, isNot(contains('_buildSaveActionArea')));
  });

  test('pending persistence reports whether target revision was saved', () {
    expect(source, contains('final targetRevision = _editRevision;'));
    expect(source, contains('final saved = _savedRevision >= targetRevision;'));
    expect(source, contains('return saved;'));
  });

  test('date switch flushes old date and aborts on failure', () {
    final methodStart = source.indexOf(
      'Future<void> _showDatePicker() async {',
    );
    final methodEnd = source.indexOf('String _getMoodEmoji(', methodStart);
    final method = source.substring(methodStart, methodEnd);

    final flush = method.indexOf('final saved = await _flushPendingAutosave(');
    final failureGate = method.indexOf('if (!mounted || !saved)');
    final assignment = method.indexOf('_selectedDate = picked;');

    expect(flush, greaterThanOrEqualTo(0));
    expect(failureGate, greaterThan(flush));
    expect(assignment, greaterThan(failureGate));
  });

  test('date loads reject stale async results', () {
    expect(source, contains('int _loadGeneration = 0;'));
    expect(source, contains('final generation = ++_loadGeneration;'));
    expect(source, contains('generation != _loadGeneration'));
    expect(
      source,
      contains('!_isSameTrackingDate(requestedDate, _selectedDate)'),
    );
  });

  test('Notes Done is an immediate persistence boundary', () {
    expect(source, contains('textInputAction: TextInputAction.done'));
    expect(source, contains('onEditingComplete: _finishNotesEditing'));
    expect(
      source,
      contains('_flushPendingAutosave(showFailureFeedback: true)'),
    );
  });

  test('dispose invalidates loads and preserves pending write attempt', () {
    final start = source.indexOf('void dispose() {');
    final end = source.indexOf('void didChangeAppLifecycleState', start);
    final dispose = source.substring(start, end);

    expect(dispose, contains('_autosaveTimer?.cancel();'));
    expect(dispose, contains('if (_hasUnsavedChanges)'));
    expect(dispose, contains('_queueAutosave();'));
    expect(dispose, contains('_loadGeneration++;'));
  });

  group('Notes semantic persistence', () {
    test('keystrokes stay draft-only until Done', () {
      final notesStart = source.indexOf('Widget _buildNotesTab()');
      final notesEnd = source.indexOf('Widget _buildQuickNote(', notesStart);

      expect(notesStart, greaterThanOrEqualTo(0));
      expect(notesEnd, greaterThan(notesStart));

      final notes = source.substring(notesStart, notesEnd);
      final changedStart = notes.indexOf('onChanged: (value) {');
      final changedEnd = notes.indexOf('onTapOutside:', changedStart);

      expect(changedStart, greaterThanOrEqualTo(0));
      expect(changedEnd, greaterThan(changedStart));

      final changed = notes.substring(changedStart, changedEnd);

      expect(changed, contains('_notes = value;'));
      expect(changed, contains('_notesDraftDirty'));
      expect(changed, contains('_hasUnsavedChanges'));
      expect(changed, isNot(contains('_markUnsavedChanges();')));
      expect(changed, isNot(contains('_scheduleAutosave();')));
      expect(changed, isNot(contains('_queueAutosave();')));
    });

    test('Done commits draft through centralized persistence boundary', () {
      final commitStart = source.indexOf(
        'bool _commitNotesDraftForPersistence()',
      );
      final finishStart = source.indexOf(
        'void _finishNotesEditing()',
        commitStart,
      );

      expect(commitStart, greaterThanOrEqualTo(0));
      expect(finishStart, greaterThan(commitStart));

      final commitMethod = source.substring(commitStart, finishStart);

      final commit = commitMethod.indexOf('_committedNotes = _notes;');
      final clearDirty = commitMethod.indexOf(
        '_notesDraftDirty = false;',
        commit,
      );
      final revision = commitMethod.indexOf('_editRevision++;', clearDirty);
      final dirty = commitMethod.indexOf(
        '_hasUnsavedChanges = true;',
        revision,
      );

      expect(commit, greaterThanOrEqualTo(0));
      expect(clearDirty, greaterThan(commit));
      expect(revision, greaterThan(clearDirty));
      expect(dirty, greaterThan(revision));

      final finishEnd = source.indexOf(
        'void _markUnsavedChanges()',
        finishStart,
      );

      expect(finishEnd, greaterThan(finishStart));

      final finishMethod = source.substring(finishStart, finishEnd);

      final promote = finishMethod.indexOf('_commitNotesDraftForPersistence()');
      final flush = finishMethod.indexOf(
        '_flushPendingAutosave(showFailureFeedback: true)',
      );

      expect(promote, greaterThanOrEqualTo(0));
      expect(flush, greaterThan(promote));
    });

    test('snapshots exclude uncommitted Notes drafts', () {
      final start = source.indexOf(
        '_TrackingSaveSnapshot _captureTrackingSnapshot()',
      );
      final end = source.indexOf('void _queueAutosave()', start);

      expect(start, greaterThanOrEqualTo(0));
      expect(end, greaterThan(start));

      final snapshot = source.substring(start, end);

      expect(snapshot, contains('notes: _committedNotes,'));
      expect(snapshot, isNot(contains('notes: _notes,')));
    });

    test('completed writes preserve unfinished draft state', () {
      expect(
        source,
        contains(
          '_hasUnsavedChanges = !isCurrentRevision || _notesDraftDirty;',
        ),
      );
    });

    test('Quick Tags use guarded legacy-compatible encoding', () {
      expect(source, contains('static const Map<String, String> _quickNotes'));
      expect(source, contains('_decodeStoredNotes('));
      expect(source, contains('tags.every(_quickNotes.containsKey)'));
      expect(source, isNot(contains("existingData['quick_notes']")));
    });
  });
}
