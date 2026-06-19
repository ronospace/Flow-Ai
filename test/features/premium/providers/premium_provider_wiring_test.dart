import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production wiring has one validated entitlement authority', () {
    final main = File('lib/main.dart').readAsStringSync();
    final provider = File(
      'lib/features/premium/providers/premium_provider.dart',
    ).readAsStringSync();
    final router = File('lib/core/routing/app_router.dart').readAsStringSync();

    expect(
      main,
      contains(
        'ChangeNotifierProxyProvider<SubscriptionProvider, PremiumProvider>',
      ),
    );
    expect(main, contains('updateSubscriptionProvider(subscriptionProvider)'));
    expect(provider, contains('_subscriptionProvider?.isPremium ?? false'));
    expect(provider, isNot(contains('_premiumService.hasPremium')));
    expect(provider, isNot(contains('_premiumService.hasFeature')));
    expect(provider, isNot(contains('_premiumService.purchaseSubscription')));
    expect(provider, isNot(contains('_premiumService.restoreSubscription')));
    expect(
      router,
      contains("builder: (context, state) => const PremiumPaywallScreen()"),
    );
  });
}
