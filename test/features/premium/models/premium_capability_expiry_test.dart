import 'package:flow_ai/features/premium/models/subscription_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  UserSubscription subscription({
    SubscriptionTier tier = SubscriptionTier.premium,
    SubscriptionStatus status = SubscriptionStatus.active,
    DateTime? expiry,
  }) => UserSubscription(
    userId: 'account-a',
    tier: tier,
    status: status,
    expiryDate: expiry,
    hasUnlimitedInsights: true,
    isAdFree: true,
    canExportData: true,
    hasAdvancedAnalytics: true,
    hasPrioritySupport: true,
  );

  for (final feature in PremiumFeature.values) {
    test('${feature.name} rejects expired and missing-expiry grants', () {
      for (final expiry in [null, DateTime.utc(2020)]) {
        final value = subscription(expiry: expiry);
        expect(value.isPremium, isFalse);
        expect(value.canAccessFeature(feature), isFalse);
        // Persisted feature flags cannot revive an expired entitlement.
        expect(
          UserSubscription.fromJson(value.toJson()).canAccessFeature(feature),
          isFalse,
        );
      }
    });

    test('${feature.name} rejects free tier even with every flag enabled', () {
      expect(
        subscription(
          tier: SubscriptionTier.free,
          expiry: DateTime.utc(2100),
        ).canAccessFeature(feature),
        isFalse,
      );
    });

    test('${feature.name} follows lifecycle status', () {
      for (final status in SubscriptionStatus.values) {
        final expected =
            status == SubscriptionStatus.active ||
            status == SubscriptionStatus.trial ||
            status == SubscriptionStatus.grace_period;
        expect(
          subscription(
            status: status,
            expiry: DateTime.utc(2100),
          ).canAccessFeature(feature),
          expected,
          reason: status.name,
        );
      }
    });

    test('${feature.name} requires its own capability flag', () {
      final value = UserSubscription(
        userId: 'account-a',
        tier: SubscriptionTier.premium,
        status: SubscriptionStatus.active,
        expiryDate: DateTime.utc(2100),
      );
      expect(value.isPremium, isTrue);
      expect(value.canAccessFeature(feature), isFalse);
    });
  }
}
