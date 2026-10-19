import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final ai = File(
    'lib/core/services/enhanced_ai_chat_service.dart',
  ).readAsStringSync();

  final flowAI = File(
    'lib/core/services/flowai_service.dart',
  ).readAsStringSync();

  final subscriptionService = File(
    'lib/features/premium/services/subscription_service.dart',
  ).readAsStringSync();

  final premiumGate = File(
    'lib/features/premium/widgets/premium_upgrade_prompt.dart',
  ).readAsStringSync();

  final analytics = File(
    'lib/features/analytics/screens/enhanced_analytics_dashboard_screen.dart',
  ).readAsStringSync();

  test('AI execution is quota-aware and real-service only', () {
    expect(ai, contains('SubscriptionService()'));
    expect(ai, contains('PremiumFeature.unlimitedInsights'));
    expect(ai, contains('getRemainingFreeInsights()'));

    expect(
      RegExp(
        r'incrementInsightsUsageForUser\s*\(\s*ownerId\s*,?\s*\)',
        multiLine: true,
      ).hasMatch(ai),
      isTrue,
    );

    expect(
      ai,
      isNot(
        contains(
          'return _getEnhancedLocalResponse(userMessage, '
          'contextPrompt: contextPrompt);',
        ),
      ),
    );

    expect(ai, contains('Flow Ai service is unavailable'));
  });

  test('central Premium UX gate checks concrete capabilities', () {
    expect(premiumGate, contains("'data_export'"));
    expect(premiumGate, contains('PremiumFeature.dataExport'));
    expect(premiumGate, contains("'advanced_analytics'"));
    expect(premiumGate, contains('PremiumFeature.advancedAnalytics'));
    expect(premiumGate, contains("'unlimited_insights'"));
    expect(premiumGate, contains('PremiumFeature.unlimitedInsights'));
  });

  test('Advanced Analytics gates access before loading data', () {
    final gate = analytics.indexOf("feature: 'advanced_analytics'");
    final load = analytics.indexOf(
      'context.read<AnalyticsProvider>().loadAllAnalytics()',
    );

    expect(gate, greaterThanOrEqualTo(0));
    expect(load, greaterThan(gate));
    expect(analytics, contains('_loadAnalyticsWithPremiumAccess()'));
  });

  test(
    'Advanced Analytics revokes live when Premium entitlement disappears',
    () {
      expect(analytics, contains('context.watch<SubscriptionProvider>()'));
      expect(analytics, contains('subscriptionProvider.hasAdvancedAnalytics'));
      expect(analytics, contains('_buildPremiumBlockedScreen(theme)'));

      final watch = analytics.indexOf('context.watch<SubscriptionProvider>()');
      final render = analytics.indexOf('return Scaffold(');

      expect(watch, greaterThanOrEqualTo(0));
      expect(render, greaterThan(watch));
    },
  );

  test('real FlowAI context uses account-scoped recorded health data', () {
    expect(ai, contains('final database = DatabaseService.instance;'));
    expect(
      ai,
      contains('await ActiveAccountScope.instance.requireOwnership(ownerId);'),
    );
    expect(ai, contains('await database.getCurrentCycle();'));
    expect(ai, contains('await database.getDailyTrackingRange('));
    expect(ai, contains('CycleCalculationEngine('));
    expect(ai, contains("predictions.currentPhase.name != 'unknown'"));
    expect(
      ai,
      isNot(contains('Map<String, dynamic>? _getCycleContextData() => null')),
    );
    expect(ai, isNot(contains('List<String>? _getRecentSymptoms() => null')));
    expect(ai, isNot(contains('String? _getCurrentCyclePhase() => null')));
    expect(ai, contains('conversationContext: conversationContext'));
    expect(ai, contains("return 'Online Flow Ai unavailable';"));
    expect(ai, isNot(contains("return 'Enhanced local responses';")));
    expect(flowAI, contains('String? conversationContext,'));
    expect(flowAI, contains("final combinedContext = <String>["));
    expect(
      flowAI,
      contains(
        'conversationContext: combinedContext.isEmpty ? null : combinedContext',
      ),
    );
  });
  test('Step 7 hardening serializes quota and fails unknown gates closed', () {
    expect(ai, contains('Future<void> _aiExecutionTail'));
    expect(ai, contains('_generateEnhancedAIResponseUnlocked('));
    expect(ai, contains('hasUnlimitedInsightsAtDelivery'));
    expect(ai, contains('subscriptionService.getRemainingFreeInsights() <= 0'));

    expect(premiumGate, contains('bool _hasPremiumFeatureAccess('));
    expect(premiumGate, contains('null => subscriptionProvider.isPremium'));
    expect(premiumGate, contains('_ => false'));
    expect(
      premiumGate,
      contains('_hasPremiumFeatureAccess(subscriptionProvider, featureId)'),
    );

    expect(subscriptionService, contains('void _publishCurrentEntitlement()'));
    expect(
      subscriptionService,
      contains('_entitlementController.add(subscription);'),
    );

    final freeTransition = RegExp(
      r'_currentSubscription\s*=\s*UserSubscription\.free\([^)]+\);\s*'
      r'_publishCurrentEntitlement\(\);',
      multiLine: true,
    );
    expect(freeTransition.hasMatch(subscriptionService), isTrue);
  });
}
