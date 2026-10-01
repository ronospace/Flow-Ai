import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String picker;
  late String tracking;

  setUpAll(() {
    picker = File(
      'lib/features/cycle/widgets/flow_intensity_picker.dart',
    ).readAsStringSync();

    tracking = File(
      'lib/features/cycle/screens/tracking_screen.dart',
    ).readAsStringSync();
  });

  test('picker owns canonical contextual feedback', () {
    expect(picker, contains("ValueKey('flow-contextual-feedback')"));
    expect(picker, contains('_getContextualFlowFeedback('));
    expect(picker, contains('Icons.lightbulb_outline'));
  });

  test('contextual feedback does not reuse option description', () {
    final start = picker.indexOf("ValueKey('flow-contextual-feedback')");

    expect(start, greaterThanOrEqualTo(0));

    final end = (start + 1600).clamp(0, picker.length);
    final section = picker.substring(start, end);

    expect(section, isNot(contains('selectedOption.description')));
  });

  test('AI Health Insights remains independently owned', () {
    expect(picker, contains('_buildAIInsightsPanel(selectedOption)'));
    expect(picker, contains("ValueKey('flow-ai-insights')"));
  });

  test('old Track duplicate feedback owner remains retired', () {
    expect(tracking, isNot(contains('_getFlowInsight')));
    expect(tracking, isNot(contains('Simplified AI insight')));
  });
}
