import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('onboarding completion must support account-scoped ownership', () {
    final preferences = File(
      'lib/core/services/user_preferences_service.dart',
    ).readAsStringSync();

    expect(
      preferences,
      contains('onboarding_complete'),
      reason: 'Legacy onboarding completion must remain migratable.',
    );

    expect(preferences, contains('onboarding_complete_account_'));
    expect(preferences, contains('onboarding_complete_legacy_claimed_user_id'));
    expect(preferences, contains('isOnboardingCompleteForUser'));
    expect(preferences, contains('setOnboardingCompleteForUser'));
  });
}
