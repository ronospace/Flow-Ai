import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/premium_provider.dart';
import '../models/subscription.dart';
import '../models/premium_feature.dart';

class PremiumSubscriptionScreen extends StatefulWidget {
  const PremiumSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<PremiumSubscriptionScreen> createState() => _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState extends State<PremiumSubscriptionScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  SubscriptionTier _selectedTier = SubscriptionTier.premium;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.appStore;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PremiumProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<PremiumProvider>(
        builder: (context, premiumProvider, child) {
          if (premiumProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (premiumProvider.hasPremium) {
            return _buildCurrentSubscriptionView(premiumProvider);
          }

          return _buildSubscriptionOfferView(premiumProvider);
        },
      ),
    );
  }

  Widget _buildCurrentSubscriptionView(PremiumProvider provider) {
    final subscription = provider.currentSubscription!;
    
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, 'Your Subscription'),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildCurrentSubscriptionCard(subscription),
                const SizedBox(height: 24),
                _buildFeaturesList(provider.availableFeatures.where((f) => provider.hasFeature(f.type)).toList()),
                const SizedBox(height: 24),
                _buildUsageStats(provider),
                const SizedBox(height: 24),
                _buildSubscriptionActions(subscription),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionOfferView(PremiumProvider provider) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, 'Premium Features'),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildHeroSection(),
                const SizedBox(height: 32),
                _buildSubscriptionTiers(),
                const SizedBox(height: 32),
                _buildFeatureComparison(provider.availableFeatures),
                const SizedBox(height: 32),
                _buildPaymentMethods(),
                const SizedBox(height: 32),
                _buildSubscribeButton(provider),
                const SizedBox(height: 16),
                _buildRestoreButton(provider),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, String title) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.diamond,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Unlock Premium Features',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Get access to advanced AI predictions, healthcare integration, and unlimited features',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTiers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...SubscriptionTier.values.map((tier) => _buildTierCard(tier)),
      ],
    );
  }

  Widget _buildTierCard(SubscriptionTier tier) {
    final isSelected = _selectedTier == tier;
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTier = tier;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surface,
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                    width: 2,
                  ),
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                ),
                child: isSelected 
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    )
                  : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tier.displayName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? theme.colorScheme.primary : null,
                          ),
                        ),
                        if (tier == SubscriptionTier.premium) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'POPULAR',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tier.featuresDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tier.priceString,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    'monthly',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureComparison(List<PremiumFeature> features) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Features Included',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => _buildFeatureRow(feature)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(PremiumFeature feature) {
    final isIncluded = _getFeatureTiers(feature.type).contains(_selectedTier);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isIncluded ? Icons.check_circle : Icons.cancel,
            color: isIncluded 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isIncluded 
                      ? null 
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
                Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isIncluded 
                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...PaymentMethod.values.map((method) => _buildPaymentMethodTile(method)),
      ],
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
            color: isSelected 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) 
              : null,
          ),
          child: Row(
            children: [
              Radio<PaymentMethod>(
                value: method,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  }
                },
              ),
              const SizedBox(width: 12),
              _getPaymentMethodIcon(method),
              const SizedBox(width: 12),
              Text(
                method.displayName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscribeButton(PremiumProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.isLoading
          ? null
          : () async {
              final success = await provider.purchaseSubscription(
                _selectedTier,
                _selectedPaymentMethod,
              );
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subscription activated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.error ?? 'Purchase failed. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: provider.isLoading
          ? const CircularProgressIndicator()
          : Text(
              'Subscribe to ${_selectedTier.displayName} - ${_selectedTier.priceString}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
    );
  }

  Widget _buildRestoreButton(PremiumProvider provider) {
    return TextButton(
      onPressed: () async {
        final success = await provider.restoreSubscription();
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription restored successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No subscription found to restore.'),
            ),
          );
        }
      },
      child: const Text('Restore Purchase'),
    );
  }

  // Helper methods for current subscription view
  
  Widget _buildCurrentSubscriptionCard(Subscription subscription) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.diamond,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${subscription.tier.displayName} Plan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Active until ${_formatDate(subscription.endDate)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: subscription.status == SubscriptionStatus.active
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    subscription.status.name.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: subscription.status == SubscriptionStatus.active
                        ? Colors.green
                        : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Days Remaining',
                    subscription.remainingDays.toString(),
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Monthly Cost',
                    subscription.tier.priceString,
                    Icons.payments,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(List<PremiumFeature> features) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Premium Features',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => _buildActiveFeatureTile(feature)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFeatureTile(PremiumFeature feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFeatureIcon(feature.type),
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStats(PremiumProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage This Month',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildUsageStat(
                    'Reports Generated',
                    provider.monthlyUsage[PremiumFeatureType.customReports]?.toString() ?? '0',
                    Icons.assessment,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildUsageStat(
                    'Data Exports',
                    provider.monthlyUsage[PremiumFeatureType.unlimitedExports]?.toString() ?? '0',
                    Icons.download,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionActions(Subscription subscription) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate to manage subscription
            },
            icon: const Icon(Icons.settings),
            label: const Text('Manage Subscription'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () async {
              final confirmed = await _showCancelConfirmation();
              if (confirmed == true && mounted) {
                final provider = context.read<PremiumProvider>();
                final success = await provider.cancelSubscription();
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subscription cancelled successfully'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.cancel, color: Colors.red),
            label: const Text(
              'Cancel Subscription',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods

  List<SubscriptionTier> _getFeatureTiers(PremiumFeatureType featureType) {
    switch (featureType) {
      case PremiumFeatureType.basicTracking:
      case PremiumFeatureType.basicPredictions:
      case PremiumFeatureType.limitedExports:
        return SubscriptionTier.values;
      case PremiumFeatureType.unlimitedExports:
      case PremiumFeatureType.customReports:
        return [SubscriptionTier.basic, SubscriptionTier.premium, SubscriptionTier.ultimate];
      case PremiumFeatureType.advancedAI:
      case PremiumFeatureType.healthcareIntegration:
      case PremiumFeatureType.prioritySupport:
      case PremiumFeatureType.biometricSync:
        return [SubscriptionTier.premium, SubscriptionTier.ultimate];
      case PremiumFeatureType.multiUserProfiles:
      case PremiumFeatureType.advancedAnalytics:
        return [SubscriptionTier.ultimate];
    }
  }

  IconData _getFeatureIcon(PremiumFeatureType featureType) {
    switch (featureType) {
      case PremiumFeatureType.basicTracking:
        return Icons.calendar_month;
      case PremiumFeatureType.basicPredictions:
      case PremiumFeatureType.advancedAI:
        return Icons.smart_toy;
      case PremiumFeatureType.limitedExports:
      case PremiumFeatureType.unlimitedExports:
        return Icons.download;
      case PremiumFeatureType.customReports:
        return Icons.assessment;
      case PremiumFeatureType.healthcareIntegration:
        return Icons.local_hospital;
      case PremiumFeatureType.prioritySupport:
        return Icons.support_agent;
      case PremiumFeatureType.biometricSync:
        return Icons.fitness_center;
      case PremiumFeatureType.multiUserProfiles:
        return Icons.group;
      case PremiumFeatureType.advancedAnalytics:
        return Icons.analytics;
    }
  }

  Widget _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.appStore:
        return const Icon(Icons.apple, size: 24);
      case PaymentMethod.googlePlay:
        return const Icon(Icons.android, size: 24);
      case PaymentMethod.stripe:
        return const Icon(Icons.credit_card, size: 24);
      case PaymentMethod.paypal:
        return const Icon(Icons.payment, size: 24);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<bool?> _showCancelConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: const Text(
          'Are you sure you want to cancel your subscription? You will lose access to premium features at the end of your current billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }
}
