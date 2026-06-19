import 'package:flutter_test/flutter_test.dart';
import 'package:flow_ai/features/premium/models/premium_feature.dart';
import 'package:flow_ai/features/premium/providers/premium_provider.dart';
import 'package:flow_ai/features/premium/providers/subscription_provider.dart';

class FakeSubscriptionProvider extends SubscriptionProvider {
  bool premium = false;

  @override
  bool get isPremium => premium;

  @override
  bool get hasUnlimitedInsights => premium;

  @override
  bool get canExportData => premium;

  @override
  bool get hasAdvancedAnalytics => premium;

  @override
  bool get hasPrioritySupport => premium;

  void publish(bool value) {
    premium = value;
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PremiumProvider follows validated SubscriptionProvider authority', () {
    final canonical = FakeSubscriptionProvider();
    final compatibility = PremiumProvider()
      ..updateSubscriptionProvider(canonical);

    addTearDown(compatibility.dispose);

    expect(compatibility.hasPremium, isFalse);

    canonical.publish(true);
    expect(compatibility.hasPremium, isTrue);

    final analytics = PremiumFeatureType.values.firstWhere(
      (feature) => feature.name == 'advancedAnalytics',
    );
    expect(compatibility.hasFeature(analytics), isTrue);

    canonical.publish(false);
    expect(compatibility.hasPremium, isFalse);
    expect(compatibility.hasFeature(analytics), isFalse);
  });
}
