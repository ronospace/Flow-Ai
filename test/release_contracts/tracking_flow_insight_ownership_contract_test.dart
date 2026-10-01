import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String tracking;
  late String picker;

  setUpAll(() {
    tracking = File(
      'lib/features/cycle/screens/tracking_screen.dart',
    ).readAsStringSync();

    picker = File(
      'lib/features/cycle/widgets/flow_intensity_picker.dart',
    ).readAsStringSync();
  });

  test('TrackingScreen does not duplicate Flow insight ownership', () {
    expect(tracking, isNot(contains('Simplified AI insight')));
    expect(tracking, isNot(contains('_getFlowInsight(')));
    expect(tracking, isNot(contains('String _getFlowInsight(')));
  });

  test('FlowIntensityPicker remains authoritative insight owner', () {
    expect(picker, contains('_buildAIInsightsPanel(selectedOption)'));
    expect(picker, contains("ValueKey('flow-ai-insights')"));
    expect(picker, contains('AppLocalizations.of(context).aiHealthInsights'));
    expect(picker, contains('_getAIInsight(option)'));
  });
}
