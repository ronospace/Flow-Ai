import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/tracking/screens/enhanced_daily_feelings_tracker.dart',
  ).readAsStringSync();

  test('Daily Feelings removes the manual Save CTA', () {
    expect(source, isNot(contains('floatingActionButton:')));
    expect(source, isNot(contains('_buildSaveButton(')));
    expect(source, isNot(contains('_saveEntry(')));
    expect(source, isNot(contains('Save feelings')));
  });

  test('Daily Feelings uses one serialized revision-safe autosave owner', () {
    expect(source, contains('Future<void> _saveChain = Future<void>.value();'));
    expect(source, contains('int _editRevision = 0;'));
    expect(source, contains('int _savedRevision = 0;'));
    expect(source, contains('int _queuedRevision = 0;'));
    expect(source, contains('void _registerMutation()'));
    expect(source, contains('void _scheduleAutosave()'));
    expect(source, contains('void _queueAutosave()'));
    expect(source, contains('Future<bool> _flushPendingAutosave'));
  });

  test('Daily Feelings flushes date back and lifecycle boundaries', () {
    expect(source, contains('WidgetsBindingObserver'));
    expect(source, contains('didChangeAppLifecycleState'));
    expect(source, contains('AppLifecycleState.paused'));
    expect(source, contains('AppLifecycleState.hidden'));
    expect(source, contains('AppLifecycleState.detached'));
    expect(source, contains('Future<void> _handleBack() async'));
  });

  test('Daily Feelings keeps Notes Done-gated', () {
    expect(source, contains("String _committedNotes = '';"));
    expect(source, contains('bool _notesDraftDirty = false;'));
    expect(source, contains('textInputAction: TextInputAction.done'));
    expect(source, contains('_commitNotesDraftForPersistence()'));
    expect(source, contains('onSubmitted: (_)'));
  });
}
