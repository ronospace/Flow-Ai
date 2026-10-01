import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cycle and analytics caches are account scoped', () {
    final provider = File(
      'lib/features/cycle/providers/cycle_provider.dart',
    ).readAsStringSync();

    final analytics = File(
      'lib/core/services/analytics_service.dart',
    ).readAsStringSync();

    expect(provider, contains('ActiveAccountScope.instance.requireUserId()'));
    expect(provider, contains("key: 'cycle_data_\$activeUserId'"));
    expect(provider, contains("key: 'cycle_insights_\$activeUserId'"));

    expect(provider, isNot(contains("key: 'cycle_data'")));
    expect(provider, isNot(contains("key: 'cycle_insights'")));

    expect(analytics, contains('ActiveAccountScope.instance.requireUserId()'));
    expect(analytics, contains('cycle_analytics_\${activeUserId}_'));
    expect(analytics, contains('health_analytics_\${activeUserId}_'));
  });
}
