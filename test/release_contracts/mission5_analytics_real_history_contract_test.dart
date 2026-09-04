import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String methodBody(String source, String signature) {
  final start = source.indexOf(signature);
  expect(start, isNonNegative);

  final parameterOpen = source.indexOf('(', start);
  expect(parameterOpen, isNonNegative);

  var depth = 0;
  var parameterClose = -1;

  for (var i = parameterOpen; i < source.length; i++) {
    if (source[i] == '(') depth++;
    if (source[i] == ')') {
      depth--;
      if (depth == 0) {
        parameterClose = i;
        break;
      }
    }
  }

  expect(parameterClose, isNonNegative);

  final bodyBrace = source.indexOf('{', parameterClose + 1);
  expect(bodyBrace, isNonNegative);

  var braceDepth = 0;

  for (var i = bodyBrace; i < source.length; i++) {
    if (source[i] == '{') braceDepth++;
    if (source[i] == '}') braceDepth--;

    if (braceDepth == 0) {
      return source.substring(start, i + 1);
    }
  }

  fail('Unbalanced method body');
}

void main() {
  test('analytics history is centralized, real, and fail-closed', () {
    final source = File(
      'lib/core/services/analytics_service.dart',
    ).readAsStringSync();

    final provider = File(
      'lib/features/analytics/providers/analytics_provider.dart',
    ).readAsStringSync();

    expect(source, contains('class AnalyticsHistory'));
    expect(source, contains('Map<DateTime, double> mood'));
    expect(source, contains('Map<DateTime, double> energy'));
    expect(source, contains('Map<DateTime, double> sleepHours'));
    expect(source, contains('List<double> cycleRegularity'));

    final body = methodBody(
      source,
      'Future<AnalyticsHistory> getAnalyticsHistory',
    );

    expect(body, contains('getTrackingDataInRange('));
    expect(body, contains('getHistoricalSleepHours('));
    expect(body, contains('getCyclesInRange('));

    expect(body, isNot(contains('List.generate')));
    expect(body, isNot(contains('Random(')));

    expect(body, contains("DateTime.tryParse(rawDate?.toString() ?? '')"));

    expect(
      body,
      isNot(
        contains(
          "DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now()",
        ),
      ),
    );

    expect(provider, contains('AnalyticsHistory _analyticsHistory'));
    expect(provider, contains('loadAnalyticsHistory()'));
    expect(provider, contains('_analyticsService.getAnalyticsHistory('));
  });
}
