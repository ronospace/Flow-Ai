import 'package:flutter_test/flutter_test.dart';
import 'package:flow_ai/features/premium/services/premium_service.dart';
import 'package:flow_ai/features/premium/models/subscription.dart';
import 'package:flow_ai/features/premium/models/premium_feature.dart';

void main() {
  group('Premium Service Tests', () {
    late PremiumService premiumService;

    setUp(() {
      premiumService = PremiumService();
    });

    test('should initialize premium service', () async {
      await premiumService.initialize();
      expect(premiumService.availableFeatures, isNotEmpty);
    });

    test('should have correct subscription tiers', () {
      final tiers = premiumService.availableTiers;
      expect(tiers.length, equals(3));
      expect(tiers, contains(SubscriptionTier.basic));
      expect(tiers, contains(SubscriptionTier.premium));
      expect(tiers, contains(SubscriptionTier.ultimate));
    });

    test('should check free features correctly', () async {
      await premiumService.initialize();
      
      // Free features should be available without subscription
      expect(premiumService.hasFeature(PremiumFeatureType.basicTracking), isTrue);
      expect(premiumService.hasFeature(PremiumFeatureType.basicPredictions), isTrue);
      expect(premiumService.hasFeature(PremiumFeatureType.limitedExports), isTrue);
      
      // Premium features should not be available without subscription
      expect(premiumService.hasFeature(PremiumFeatureType.advancedAI), isFalse);
      expect(premiumService.hasFeature(PremiumFeatureType.healthcareIntegration), isFalse);
    });

    test('should handle subscription tiers correctly', () {
      expect(SubscriptionTier.basic.displayName, equals('Basic'));
      expect(SubscriptionTier.premium.displayName, equals('Premium'));
      expect(SubscriptionTier.ultimate.displayName, equals('Ultimate'));
      
      expect(SubscriptionTier.basic.price, equals(4.99));
      expect(SubscriptionTier.premium.price, equals(9.99));
      expect(SubscriptionTier.ultimate.price, equals(19.99));
    });

    test('should create subscription correctly', () {
      final subscription = Subscription.sample();
      
      expect(subscription.id, isNotNull);
      expect(subscription.userId, isNotNull);
      expect(subscription.tier, isNotNull);
      expect(subscription.startDate, isNotNull);
      expect(subscription.endDate, isNotNull);
      expect(subscription.status, equals(SubscriptionStatus.active));
    });

    test('should calculate subscription remaining days', () {
      final futureDate = DateTime.now().add(const Duration(days: 10));
      final subscription = Subscription.sample().copyWith(
        endDate: futureDate,
      );
      
      expect(subscription.remainingDays, greaterThanOrEqualTo(9));
      expect(subscription.remainingDays, lessThanOrEqualTo(10));
    });

    test('should handle expired subscriptions', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final subscription = Subscription.sample().copyWith(
        endDate: pastDate,
      );
      
      expect(subscription.isExpired, isTrue);
      expect(subscription.isActive, isFalse);
      expect(subscription.remainingDays, equals(0));
    });

    test('should create feature limits correctly', () {
      final freeLimits = FeatureLimits.free();
      expect(freeLimits.maxExportsPerMonth, equals(3));
      expect(freeLimits.maxReportsPerMonth, equals(1));
      expect(freeLimits.unlimitedPredictions, isFalse);
      
      final premiumLimits = FeatureLimits.forTier(SubscriptionTier.premium);
      expect(premiumLimits.hasUnlimitedExports, isTrue);
      expect(premiumLimits.hasUnlimitedReports, isTrue);
      expect(premiumLimits.unlimitedPredictions, isTrue);
    });

    test('should handle premium feature types correctly', () {
      for (final featureType in PremiumFeatureType.values) {
        expect(featureType.displayName, isNotEmpty);
        expect(featureType.description, isNotEmpty);
        expect(featureType.iconName, isNotEmpty);
        expect(featureType.minimumTier, isNotNull);
      }
    });

    test('should identify free features', () {
      expect(PremiumFeatureType.basicTracking.isFreeFeature, isTrue);
      expect(PremiumFeatureType.basicPredictions.isFreeFeature, isTrue);
      expect(PremiumFeatureType.limitedExports.isFreeFeature, isTrue);
      
      expect(PremiumFeatureType.advancedAI.isFreeFeature, isFalse);
      expect(PremiumFeatureType.healthcareIntegration.isFreeFeature, isFalse);
      expect(PremiumFeatureType.multiUserProfiles.isFreeFeature, isFalse);
    });

    test('should handle subscription analytics', () {
      final analytics = SubscriptionAnalytics.empty('test_subscription');
      expect(analytics.subscriptionId, equals('test_subscription'));
      expect(analytics.totalDaysActive, equals(0));
      expect(analytics.engagementScore, equals(0.0));
      expect(analytics.isHighlyEngaged, isFalse);
    });

    test('should calculate engagement score', () {
      final analytics = SubscriptionAnalytics(
        subscriptionId: 'test',
        totalDaysActive: 30,
        featuresUsed: 10,
        reportsGenerated: 5,
        exportsCompleted: 3,
        providersConnected: 1,
        lastActivity: DateTime.now(),
        featureUsageCount: {},
        satisfactionRating: 4.5,
      );
      
      expect(analytics.engagementScore, greaterThan(0));
      expect(analytics.engagementScore, lessThanOrEqualTo(100));
    });
  });

  group('Premium Feature Tests', () {
    test('should create premium feature with defaults', () {
      final feature = PremiumFeature.withDefaults(
        PremiumFeatureType.advancedAI,
        SubscriptionTier.premium,
      );
      
      expect(feature.type, equals(PremiumFeatureType.advancedAI));
      expect(feature.tier, equals(SubscriptionTier.premium));
      expect(feature.isEnabled, isTrue);
      expect(feature.usageCount, equals(0));
    });

    test('should handle feature usage tracking', () {
      final feature = PremiumFeature.withDefaults(
        PremiumFeatureType.customReports,
        SubscriptionTier.basic,
      );
      
      final updatedFeature = feature.incrementUsage();
      expect(updatedFeature.usageCount, equals(1));
      expect(updatedFeature.lastUsed, isNotNull);
      
      final resetFeature = updatedFeature.resetMonthlyUsage();
      expect(resetFeature.usageCount, equals(0));
    });

    test('should check usage limits correctly', () {
      final feature = PremiumFeature(
        type: PremiumFeatureType.customReports,
        name: 'Custom Reports',
        description: 'Test feature',
        tier: SubscriptionTier.basic,
        usageCount: 5,
        usageLimitPerMonth: 10.0,
      );
      
      expect(feature.hasUsageLimit, isTrue);
      expect(feature.isWithinUsageLimit, isTrue);
      expect(feature.remainingUsage, equals(5.0));
      expect(feature.usagePercentage, equals(50.0));
    });

    test('should handle feature usage analytics', () {
      final analytics = FeatureUsageAnalytics.empty(
        PremiumFeatureType.advancedAI,
        DateTime(2024, 1, 1),
      );
      
      expect(analytics.featureType, equals(PremiumFeatureType.advancedAI));
      expect(analytics.totalUsage, equals(0));
      expect(analytics.consistencyScore, equals(0.0));
      expect(analytics.isHeavilyUsed, isFalse);
    });
  });
}
