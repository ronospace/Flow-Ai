import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String executableSource(String source) {
  final withoutBlockComments = source.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');

  return withoutBlockComments
      .split('\n')
      .where((line) => !line.trimLeft().startsWith('//'))
      .join('\n');
}

void main() {
  group('MON-11 analytics ownership and privacy', () {
    test('production telemetry has one authoritative owner', () {
      final production = File(
        'lib/core/services/production_analytics_service.dart',
      );
      final retired = File(
        'lib/features/analytics/services/advanced_analytics_service.dart',
      );

      expect(production.existsSync(), isTrue);
      expect(retired.existsSync(), isFalse);

      final source = production.readAsStringSync();

      expect(source, contains('class ProductionAnalyticsService'));
      expect(source, contains('_analyticsEnabled = false'));
      expect(source, contains('setAnalyticsEnabled'));
      expect(source, contains('setAuthenticatedUser'));
    });

    test('raw telemetry user identity is not persisted', () {
      final source = File(
        'lib/core/services/production_analytics_service.dart',
      ).readAsStringSync();

      expect(source, isNot(contains("static const String _keyUserId")));
      expect(source, isNot(contains('setString(_keyUserId')));
      expect(source, isNot(contains("'user_id': _userId")));
    });

    test('subscription compatibility surface has no executable transport', () {
      final raw = File(
        'lib/features/premium/services/subscription_analytics_service.dart',
      ).readAsStringSync();

      final source = executableSource(raw);

      expect(source, isNot(contains('FirebaseAnalytics.instance')));
      expect(source, isNot(contains('Mixpanel.')));
      expect(source, isNot(contains('Amplitude.')));
      expect(source, isNot(contains('http.post')));
      expect(source, isNot(contains('Timer.periodic')));
      expect(source, isNot(contains("'transaction_id':")));
      expect(source, isNot(contains("'original_transaction_id':")));
      expect(source, isNot(contains("'user_id':")));
    });

    test('retired parallel telemetry storage cannot return', () {
      final dartFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      final source = dartFiles
          .map((file) => executableSource(file.readAsStringSync()))
          .join('\n');

      expect(source, isNot(contains('class AdvancedAnalyticsService')));
      expect(source, isNot(contains("'analytics_events'")));
      expect(source, isNot(contains("'analytics_user_id'")));
      expect(source, isNot(contains("'analytics_user_type'")));
      expect(source, isNot(contains("'analytics_subscription_status'")));
    });
  });
}
