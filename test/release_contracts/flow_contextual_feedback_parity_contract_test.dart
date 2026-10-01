import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String picker;

  setUpAll(() {
    picker = File(
      'lib/features/cycle/widgets/flow_intensity_picker.dart',
    ).readAsStringSync();
  });

  test('contextual feedback preserves canonical bulb presentation', () {
    expect(picker, contains("ValueKey('flow-contextual-feedback')"));
    expect(picker, contains('Icons.lightbulb_outline'));
    expect(picker, contains('AppTheme.accentMint'));
    expect(picker, contains('const SizedBox(width: 12)'));
    expect(picker, contains('fontSize: 13'));
  });

  test('contextual feedback uses canonical Flow messages', () {
    expect(picker, contains('Start tracking to get personalized insights'));
    expect(
      picker,
      contains(
        'Light spotting is normal at the beginning or end of your cycle.',
      ),
    );
    expect(picker, contains('Light flow - stay hydrated and rest as needed.'));
    expect(picker, contains("Normal flow pattern - you\\'re doing great!"));
    expect(picker, contains('Heavy flow - monitor iron intake and rest.'));
    expect(
      picker,
      contains('Very heavy flow - consider tracking for your doctor.'),
    );
  });

  test('contextual feedback does not reuse option description', () {
    final start = picker.indexOf("ValueKey('flow-contextual-feedback')");
    expect(start, greaterThanOrEqualTo(0));

    final section = picker.substring(
      start,
      (start + 1500).clamp(0, picker.length),
    );

    expect(section, isNot(contains('selectedOption.description')));
    expect(section, contains('_getContextualFlowFeedback('));
  });
}
