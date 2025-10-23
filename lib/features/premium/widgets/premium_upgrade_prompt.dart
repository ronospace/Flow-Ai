import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../screens/premium_paywall_screen.dart';

/// A reusable widget for prompting users to upgrade to premium
class PremiumUpgradePrompt extends StatelessWidget {
  final String title;
  final String message;
  final String? feature;
  final bool showAsDialog;

  const PremiumUpgradePrompt({
    super.key,
    required this.title,
    required this.message,
    this.feature,
    this.showAsDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade50,
            Colors.amber.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showPaywall(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Upgrade to Premium',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PremiumPaywallScreen(
          highlightFeature: feature,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

/// Show a premium upgrade dialog
Future<bool?> showPremiumUpgradeDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? feature,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.workspace_premium,
            color: Colors.amber.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Maybe Later'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PremiumPaywallScreen(
                  highlightFeature: feature,
                ),
                fullscreenDialog: true,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade600,
          ),
          child: const Text('Upgrade Now'),
        ),
      ],
    ),
  );
}

/// Check if user has premium access, show upgrade prompt if not
Future<bool> checkPremiumAccess(
  BuildContext context, {
  required String featureTitle,
  required String featureDescription,
  String? feature,
}) async {
  final subscriptionProvider = Provider.of<SubscriptionProvider>(
    context,
    listen: false,
  );

  if (subscriptionProvider.isPremium) {
    return true; // Has access
  }

  // Show upgrade prompt
  await showPremiumUpgradeDialog(
    context,
    title: 'Premium Feature',
    message: '$featureDescription\n\nUpgrade to premium to unlock this feature.',
    feature: feature,
  );

  return false; // No access
}

/// Widget that blocks a feature for free users
class PremiumFeatureGate extends StatelessWidget {
  final Widget child;
  final String featureTitle;
  final String featureDescription;
  final String? featureId;

  const PremiumFeatureGate({
    super.key,
    required this.child,
    required this.featureTitle,
    required this.featureDescription,
    this.featureId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, _) {
        if (subscriptionProvider.isPremium) {
          return child; // Show feature
        }

        // Show upgrade prompt instead
        return PremiumUpgradePrompt(
          title: featureTitle,
          message: featureDescription,
          feature: featureId,
        );
      },
    );
  }
}

/// Banner showing remaining free insights
class FreeInsightsLimitBanner extends StatelessWidget {
  const FreeInsightsLimitBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        if (subscriptionProvider.isPremium) {
          return const SizedBox.shrink(); // Don't show for premium users
        }

        final remaining = subscriptionProvider.remainingFreeInsights;
        final used = subscriptionProvider.aiInsightsUsed;
        final limit = subscriptionProvider.aiInsightsLimit;

        if (!subscriptionProvider.shouldShowUpgradePrompt()) {
          return const SizedBox.shrink(); // Don't show yet
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: remaining <= 0
                ? Colors.red.shade50
                : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: remaining <= 0
                  ? Colors.red.shade300
                  : Colors.orange.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                remaining <= 0 ? Icons.block : Icons.info_outline,
                color: remaining <= 0 ? Colors.red : Colors.orange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      remaining <= 0
                          ? 'Free insights used up'
                          : '$remaining of $limit free insights left',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upgrade for unlimited insights',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PremiumPaywallScreen(
                        highlightFeature: 'insights',
                      ),
                      fullscreenDialog: true,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Upgrade'),
              ),
            ],
          ),
        );
      },
    );
  }
}
