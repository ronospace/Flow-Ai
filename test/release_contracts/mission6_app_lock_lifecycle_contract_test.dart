import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('temporary lifecycle transitions do not immediately lock Flow Ai', () {
    final router = File('lib/core/routing/app_router.dart').readAsStringSync();

    final service = File(
      'lib/core/services/app_lock_service.dart',
    ).readAsStringSync();

    expect(router, contains('case AppLifecycleState.inactive:'));

    expect(router, contains('case AppLifecycleState.paused:'));

    expect(router, contains('appLock.recordBackgrounded();'));

    expect(router, contains('appLock.recordResumed();'));

    expect(router, isNot(contains('state == AppLifecycleState.inactive ||')));

    expect(service, contains('DateTime? _backgroundedAt;'));

    expect(service, contains('void recordBackgrounded()'));

    expect(service, contains('void recordResumed()'));
  });

  test('explicit lock and reset still invalidate unlocked state', () {
    final service = File(
      'lib/core/services/app_lock_service.dart',
    ).readAsStringSync();

    expect(
      RegExp(
        r'void lock\(\)\s*\{[\s\S]*?_isUnlocked = false;',
      ).hasMatch(service),
      isTrue,
    );

    expect(
      RegExp(
        r'void reset\(\)\s*\{[\s\S]*?_isUnlocked = false;',
      ).hasMatch(service),
      isTrue,
    );

    expect(
      service,
      isNot(contains('AppLifecycleState')),
      reason:
          'Lifecycle interpretation belongs to the shell; lock state ownership remains centralized here.',
    );
  });
}
