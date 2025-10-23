import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/premium_feature.dart';
import '../providers/premium_provider.dart';

class PremiumFeatureWidget extends StatelessWidget {
  final PremiumFeature feature;
  final bool showUpgradeButton;
  final VoidCallback? onUpgradePressed;
  final bool isCompact;

  const PremiumFeatureWidget({
    super.key,
    required this.feature,
    this.showUpgradeButton = true,
    this.onUpgradePressed,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premiumProvider, child) {
        final hasFeature = premiumProvider.hasFeature(feature.type);
        final isLocked = !hasFeature;

        if (isCompact) {
          return _buildCompactCard(context, hasFeature, isLocked, premiumProvider);
        }

        return _buildFullCard(context, hasFeature, isLocked, premiumProvider);
      },
    );
  }

  Widget _buildCompactCard(BuildContext context, bool hasFeature, bool isLocked, PremiumProvider provider) {
    return Card(
      elevation: isLocked ? 1 : 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildFeatureIcon(context, isLocked),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          feature.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLocked 
                              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
                              : null,
                          ),
                        ),
                      ),
                      if (isLocked) _buildLockIcon(context),
                    ],
                  ),
                  Text(
                    feature.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isLocked 
                        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isLocked && showUpgradeButton) ...[
              const SizedBox(width: 8),
              _buildUpgradeButton(context, true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context, bool hasFeature, bool isLocked, PremiumProvider provider) {
    return Card(
      elevation: isLocked ? 1 : 3,
      child: Container(
        decoration: isLocked 
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              ),
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
            ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureIcon(context, isLocked),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                feature.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isLocked 
                                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
                                    : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            if (isLocked) _buildLockIcon(context),
                            if (hasFeature) _buildActiveIcon(context),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          feature.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isLocked 
                              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (feature.benefits.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildBenefitsList(context, isLocked),
              ],
              if (hasFeature && feature.usage != null) ...[
                const SizedBox(height: 16),
                _buildUsageInfo(context, provider),
              ],
              if (isLocked && showUpgradeButton) ...[
                const SizedBox(height: 16),
                _buildUpgradeButton(context, false),
              ],
              if (hasFeature) ...[
                const SizedBox(height: 16),
                _buildFeatureActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(BuildContext context, bool isLocked) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isLocked 
          ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)
          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getFeatureIcon(),
        color: isLocked 
          ? Theme.of(context).colorScheme.outline
          : Theme.of(context).colorScheme.primary,
        size: 24,
      ),
    );
  }

  Widget _buildLockIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.lock,
        size: 16,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }

  Widget _buildActiveIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.check_circle,
        size: 16,
        color: Colors.green,
      ),
    );
  }

  Widget _buildBenefitsList(BuildContext context, bool isLocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benefits:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isLocked 
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...feature.benefits.map((benefit) => _buildBenefitItem(context, benefit, isLocked)),
      ],
    );
  }

  Widget _buildBenefitItem(BuildContext context, String benefit, bool isLocked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isLocked 
                ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              benefit,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isLocked 
                  ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageInfo(BuildContext context, PremiumProvider provider) {
    final usage = provider.getFeatureUsage(feature.type);
    final limit = feature.usage?.limit;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Usage this month',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                limit != null ? '$usage / $limit' : usage.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          if (limit != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: limit > 0 ? (usage / limit).clamp(0.0, 1.0) : 0.0,
              backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                usage >= limit 
                  ? Colors.red 
                  : Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context, bool isCompact) {
    return SizedBox(
      width: isCompact ? null : double.infinity,
      child: ElevatedButton.icon(
        onPressed: onUpgradePressed ?? () {
          // Default upgrade action - navigate to premium subscription screen
          Navigator.of(context).pushNamed('/premium');
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: isCompact ? 8 : 12,
            horizontal: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
          ),
        ),
        icon: Icon(
          Icons.diamond,
          size: isCompact ? 16 : 20,
        ),
        label: Text(
          'Upgrade',
          style: TextStyle(
            fontSize: isCompact ? 12 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _showFeatureDetails(context);
            },
            icon: const Icon(Icons.info_outline, size: 16),
            label: const Text(
              'Learn More',
              style: TextStyle(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _useFeature(context);
            },
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text(
              'Use Now',
              style: TextStyle(fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFeatureIcon() {
    switch (feature.type) {
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

  void _showFeatureDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                feature.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (feature.benefits.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Benefits:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...feature.benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
              if (feature.helpUrl != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Learn more at: ${feature.helpUrl}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _useFeature(BuildContext context) {
    final provider = context.read<PremiumProvider>();
    
    if (!provider.canUseFeature(feature.type)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${feature.name} is not available with your current subscription'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Record feature usage
    provider.recordFeatureUsage(feature.type);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Using ${feature.name}...'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Here you would typically navigate to the feature or trigger its functionality
    // For now, we'll just show a placeholder message
  }
}

// Helper widget for displaying a list of premium features
class PremiumFeatureList extends StatelessWidget {
  final List<PremiumFeature> features;
  final bool isCompact;
  final bool showUpgradeButtons;
  final VoidCallback? onUpgradePressed;

  const PremiumFeatureList({
    super.key,
    required this.features,
    this.isCompact = false,
    this.showUpgradeButtons = true,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PremiumFeatureWidget(
                  feature: feature,
                  isCompact: isCompact,
                  showUpgradeButton: showUpgradeButtons,
                  onUpgradePressed: onUpgradePressed,
                ),
              ))
          .toList(),
    );
  }
}

// Widget for displaying premium feature comparison
class PremiumFeatureComparison extends StatelessWidget {
  final List<PremiumFeature> features;
  final List<String> tiers;

  const PremiumFeatureComparison({
    super.key,
    required this.features,
    required this.tiers,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feature Comparison',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  const DataColumn(
                    label: Text('Feature'),
                  ),
                  ...tiers.map((tier) => DataColumn(
                    label: Text(
                      tier,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
                ],
                rows: features.map((feature) => DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Icon(
                            _getFeatureIcon(feature.type),
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(feature.name),
                        ],
                      ),
                    ),
                    ...tiers.map((tier) => DataCell(
                      Icon(
                        _isFeatureAvailableInTier(feature.type, tier)
                          ? Icons.check_circle
                          : Icons.cancel,
                        color: _isFeatureAvailableInTier(feature.type, tier)
                          ? Colors.green
                          : Colors.red.withValues(alpha: 0.1),
                        size: 20,
                      ),
                    )),
                  ],
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
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

  bool _isFeatureAvailableInTier(PremiumFeatureType featureType, String tier) {
    // This is a simplified logic - you might want to implement more complex tier checking
    switch (featureType) {
      case PremiumFeatureType.basicTracking:
      case PremiumFeatureType.basicPredictions:
      case PremiumFeatureType.limitedExports:
        return true; // Available in all tiers
      case PremiumFeatureType.unlimitedExports:
      case PremiumFeatureType.customReports:
        return tier != 'Free'; // Available in paid tiers
      case PremiumFeatureType.advancedAI:
      case PremiumFeatureType.healthcareIntegration:
      case PremiumFeatureType.prioritySupport:
      case PremiumFeatureType.biometricSync:
        return tier == 'Premium' || tier == 'Ultimate';
      case PremiumFeatureType.multiUserProfiles:
      case PremiumFeatureType.advancedAnalytics:
        return tier == 'Ultimate';
    }
  }
}
