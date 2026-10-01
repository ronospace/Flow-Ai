import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flow_ai/features/premium/providers/subscription_provider.dart';

class FeatureGate {
  static bool isPremium(BuildContext context) {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    return subscriptionProvider.isPremium;
  }

  static bool adsEnabled(BuildContext context) => !isPremium(context);

  static bool canUploadImages(BuildContext context) => isPremium(context);
}
