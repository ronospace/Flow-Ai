import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final database = File(
    'lib/core/database/database_service.dart',
  ).readAsStringSync();

  final tracking = File(
    'lib/features/cycle/screens/tracking_screen.dart',
  ).readAsStringSync();

  final model = File(
    'lib/core/models/daily_tracking_data.dart',
  ).readAsStringSync();

  final cloud = File(
    'lib/core/services/cloud_sync_service.dart',
  ).readAsStringSync();

  test('daily tracking schema v3 records explicit metric provenance', () {
    expect('version: 3,'.allMatches(database).length, 2);

    expect(database, contains('mood_observed INTEGER NOT NULL DEFAULT 0'));
    expect(database, contains('energy_observed INTEGER NOT NULL DEFAULT 0'));
    expect(database, contains('pain_observed INTEGER NOT NULL DEFAULT 0'));

    expect(database, contains('if (oldVersion < 3)'));
    expect(database, contains('ADD COLUMN mood_observed'));
    expect(database, contains('ADD COLUMN energy_observed'));
    expect(database, contains('ADD COLUMN pain_observed'));
  });

  test('legacy v2 rows remain unverified after migration', () {
    expect(
      database,
      isNot(contains('UPDATE daily_tracking SET mood_observed = 1')),
    );

    expect(
      database,
      isNot(contains('UPDATE daily_tracking SET energy_observed = 1')),
    );

    expect(
      database,
      isNot(contains('UPDATE daily_tracking SET pain_observed = 1')),
    );
  });

  test('Track owns explicit observation state for all three metrics', () {
    expect(tracking, contains('bool _moodObserved'));
    expect(tracking, contains('bool _energyObserved'));
    expect(tracking, contains('bool _painObserved'));

    expect(tracking, contains('_moodObserved = true;'));
    expect(tracking, contains('_energyObserved = true;'));
    expect(tracking, contains('_painObserved = true;'));
  });

  test('autosave snapshot preserves metric provenance', () {
    expect(tracking, contains('moodObserved: _moodObserved'));
    expect(tracking, contains('energyObserved: _energyObserved'));
    expect(tracking, contains('painObserved: _painObserved'));

    expect(tracking, contains('final bool moodObserved;'));
    expect(tracking, contains('final bool energyObserved;'));
    expect(tracking, contains('final bool painObserved;'));
  });

  test('persistence writes only explicitly observed metric values', () {
    expect(
      tracking,
      contains('mood: snapshot.moodObserved ? snapshot.mood : null'),
    );
    expect(
      tracking,
      contains('energy: snapshot.energyObserved ? snapshot.energy : null'),
    );
    expect(
      tracking,
      contains('pain: snapshot.painObserved ? snapshot.pain : null'),
    );

    expect(tracking, contains('moodObserved: snapshot.moodObserved'));
    expect(tracking, contains('energyObserved: snapshot.energyObserved'));
    expect(tracking, contains('painObserved: snapshot.painObserved'));
  });

  test('daily tracking model represents pain and provenance', () {
    expect(model, contains('final int? pain;'));
    expect(model, contains('final bool moodObserved;'));
    expect(model, contains('final bool energyObserved;'));
    expect(model, contains('final bool painObserved;'));

    expect(model, contains("'pain': pain"));
    expect(model, contains("'moodObserved': moodObserved"));
    expect(model, contains("'energyObserved': energyObserved"));
    expect(model, contains("'painObserved': painObserved"));
  });

  test('cloud restore awaits persistence and bounds flow', () {
    expect(cloud, contains('await _databaseService.updateCycle(cycle);'));
    expect(cloud, contains('flowIndex < FlowIntensity.values.length'));
    expect(cloud, contains('await _databaseService.saveDailyTracking('));
    expect(cloud, isNot(contains('FlowIntensity.values[data.flowIntensity!]')));
  });

  test('verified zero-based flow contract', () {
    expect(model, contains('FlowIntensity enum index: 0-5'));
    expect(cloud, contains('FlowIntensity.values.byName(flowName).index'));
    expect(
      cloud,
      isNot(contains('FlowIntensity.values.byName(flowName).index + 1')),
    );
    expect(cloud, contains('FlowIntensity.values[flowIndex]'));
  });

  test('full-state tracking write supports intentional clears', () {
    expect(database, contains("'mood_observed': moodObserved == true ? 1 : 0"));
    expect(tracking, contains('flowIntensity: snapshot.flowIntensity'));
    expect(tracking, contains('symptoms: snapshot.symptoms'));
    expect(tracking, contains('symptomSeverity: snapshot.symptomSeverity'));
    expect(tracking, contains('painAreas: snapshot.painAreas'));
    expect(tracking, contains("notes: fullNotes ?? ''"));
  });

  test('model and backup preserve tracking maps', () {
    expect(model, contains('final Map<String, double> symptomSeverity;'));
    expect(model, contains('final Map<String, double> painAreas;'));
    expect(model, contains("'symptomSeverity': symptomSeverity"));
    expect(model, contains("'painAreas': painAreas"));

    expect(cloud, contains("row['symptom_severity']"));
    expect(cloud, contains("row['pain_areas']"));
    expect(cloud, contains('symptomSeverity: data.symptomSeverity'));
    expect(cloud, contains('painAreas: data.painAreas'));
  });

  test('backup restore does not discard pain or provenance', () {
    expect(cloud, contains('pain: data.pain?.toDouble()'));
    expect(cloud, contains('moodObserved: data.moodObserved'));
    expect(cloud, contains('energyObserved: data.energyObserved'));
    expect(cloud, contains('painObserved: data.painObserved'));
  });
}
