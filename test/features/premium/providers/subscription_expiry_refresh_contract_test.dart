import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('subscription provider schedules UI refresh at premium expiry', () {
    final source = File(
      'lib/features/premium/providers/subscription_provider.dart',
    ).readAsStringSync();

    expect(source, contains('Timer? _expiryTimer;'));
    expect(source, contains('void _scheduleExpiryRefresh()'));
    expect(source, contains('expiry.difference(DateTime.now())'));
    expect(source, contains("delay + const Duration(seconds: 1)"));
    expect(source, contains('_scheduleExpiryRefresh();'));
    expect(source, contains('_expiryTimer?.cancel();'));
    expect(source, contains('notifyListeners();'));
  });

  test('account transition and dispose cancel expiry timer', () {
    final source = File(
      'lib/features/premium/providers/subscription_provider.dart',
    ).readAsStringSync();

    final cancelCount = RegExp(
      r'_expiryTimer\?\.cancel\(\);',
    ).allMatches(source).length;

    expect(cancelCount, greaterThanOrEqualTo(3));
  });

  test(
    'expiry refresh keeps AdMob suppression aligned to live entitlement',
    () {
      final source = File(
        'lib/features/premium/providers/subscription_provider.dart',
      ).readAsStringSync();

      expect(
        source,
        contains('AdMobService().setPremiumSuppressed(premiumNow);'),
      );
    },
  );
}
