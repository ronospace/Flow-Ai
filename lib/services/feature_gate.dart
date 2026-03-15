import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flow_ai/features/premium/services/premium_service.dart';

class FeatureGate {

  static bool isPremium(BuildContext context) {
    final service = context.read<PremiumService?>();
    return service?.hasPremium ?? false;
  }

  static bool adsEnabled(BuildContext context) => !isPremium(context);

  static bool canUploadImages(BuildContext context) => isPremium(context);
}
