import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final feelings = File(
    'lib/features/tracking/screens/enhanced_daily_feelings_tracker.dart',
  ).readAsStringSync();

  final aiChat = File(
    'lib/core/services/enhanced_ai_chat_service.dart',
  ).readAsStringSync();

  test('unrecorded feelings have no implicit midpoint value', () {
    expect(feelings, isNot(contains('recordedValue ?? 5.0')));

    expect(feelings, contains("'Not recorded'"));
  });

  test('recorded slider values are only dereferenced after null guard', () {
    expect(feelings, contains('recordedValue == null'));

    expect(feelings, contains('value: sliderValue!'));
  });

  test('AI failure fails closed without synthetic local response', () {
    expect(aiChat, contains('Flow Ai service is unavailable'));

    expect(aiChat, isNot(contains('return _getEnhancedLocalResponse(')));
  });

  test('legacy comprehensive health fallback marker is absent', () {
    expect(
      aiChat,
      isNot(
        contains('// Enhanced fallback responses with comprehensive knowledge'),
      ),
    );
  });

  test('unrecorded health inputs render without a numeric slider value', () {
    expect(feelings, contains('Widget _buildUnrecordedScale({'));

    expect(feelings, contains('child: recordedValue == null'));

    expect(feelings, contains('selected: false'));

    expect(feelings, isNot(contains('recordedValue ?? 5.0')));
  });
}
