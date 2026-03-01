import 'package:flutter/widgets.dart';
import 'premium_service.dart';
import 'package:provider/provider.dart';

class FeatureGate {
  static bool isPremium(BuildContext context) =>
      context.read<PremiumService>().isPremium;

  static bool adsEnabled(BuildContext context) =>
      !isPremium(context);

  static bool canUploadImages(BuildContext context) =>
      isPremium(context);
}
