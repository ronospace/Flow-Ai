import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _futureMethodByName(String source, String name) {
  final declaration = RegExp(
    r'^\s*Future[^\n]*\s+' + RegExp.escape(name) + r'\s*\(',
    multiLine: true,
  );

  final match = declaration.firstMatch(source);

  expect(match, isNotNull, reason: 'Missing Future method: $name');

  final nextDeclaration = RegExp(
    r'^\s*Future[^\n]*\s+[A-Za-z_][A-Za-z0-9_]*\s*\(',
    multiLine: true,
  );

  var end = source.length;

  for (final next in nextDeclaration.allMatches(source, match!.end)) {
    end = next.start;
    break;
  }

  return source.substring(match.start, end);
}

void main() {
  final source = File(
    'lib/core/database/database_service.dart',
  ).readAsStringSync();

  test('daily tracking v2 schema is account isolated', () {
    expect('version: 2,'.allMatches(source).length, 2);

    expect(source, contains('user_id TEXT NOT NULL'));

    expect(source, contains('UNIQUE(user_id, date)'));

    expect(source, isNot(contains('UNIQUE(date)')));

    expect(source, contains('idx_daily_tracking_user_date'));
  });

  test('v1 unowned health rows remain preserved and unowned', () {
    final upgrade = _futureMethodByName(source, '_upgradeDatabase');

    expect(upgrade, contains('if (oldVersion < 2)'));

    expect(upgrade, contains('daily_tracking_legacy_v1_unowned'));

    expect(upgrade, isNot(contains('_requireActiveAccountId')));

    expect(
      RegExp(
        r'INSERT\s+INTO\s+daily_tracking',
        caseSensitive: false,
      ).hasMatch(upgrade),
      isFalse,
    );
  });

  test('every direct daily tracking API resolves live account', () {
    const methods = <String>[
      'saveDailyTracking',
      'getDailyTracking',
      'getDailyTrackingRange',
      'getRecentTrackingData',
      'getAllTrackingData',
      'getTrackingByDate',
    ];

    for (final name in methods) {
      final body = _futureMethodByName(source, name);

      expect(body, contains('_requireActiveAccountId()'), reason: name);

      expect(body, isNot(contains("'current_user'")), reason: name);

      expect(body, isNot(contains("'anonymous_user'")), reason: name);
    }
  });

  test('all direct daily reads filter by active account', () {
    const methods = <String>[
      'getDailyTracking',
      'getDailyTrackingRange',
      'getRecentTrackingData',
      'getAllTrackingData',
      'getTrackingByDate',
    ];

    for (final name in methods) {
      final body = _futureMethodByName(source, name);

      expect(body, contains('user_id = ?'), reason: name);

      expect(body, contains('activeUserId'), reason: name);
    }
  });

  test('daily write persists explicit active ownership', () {
    final save = _futureMethodByName(source, 'saveDailyTracking');

    expect(save, contains("'user_id': activeUserId"));

    expect(save, contains(r"'id': '${activeUserId}_${dateStr}_tracking'"));
  });

  test('range compatibility API delegates to scoped canonical API', () {
    final alias = _futureMethodByName(source, 'getTrackingDataInRange');

    expect(alias, contains('return getDailyTrackingRange(start, end);'));
  });
}
