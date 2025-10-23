import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../models/premium_feature.dart';
import '../providers/premium_provider.dart';

class SubscriptionStatusWidget extends StatelessWidget {
  final bool isCompact;
  final VoidCallback? onTap;

  const SubscriptionStatusWidget({
    super.key,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premiumProvider, child) {
        if (!premiumProvider.hasPremium) {
          return _buildFreeVersionCard(context, premiumProvider);
        }

        final subscription = premiumProvider.currentSubscription!;
        
        if (isCompact) {
          return _buildCompactSubscriptionCard(context, subscription, premiumProvider);
        }

        return _buildFullSubscriptionCard(context, subscription, premiumProvider);
      },
    );
  }

  Widget _buildFreeVersionCard(BuildContext context, PremiumProvider provider) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pushNamed('/premium'),
      child: Card(
        child: Container(
          decoration: BoxDecoration(
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.diamond_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Free Version',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Upgrade to unlock premium features',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                if (!isCompact) ...[
                  const SizedBox(height: 16),
                  _buildFreeFeaturesList(context),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onTap ?? () => Navigator.of(context).pushNamed('/premium'),
                      icon: const Icon(Icons.diamond),
                      label: const Text('Upgrade to Premium'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactSubscriptionCard(
    BuildContext context, 
    Subscription subscription, 
    PremiumProvider provider
  ) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pushNamed('/premium'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getStatusColor(subscription.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.diamond,
                  color: _getStatusColor(subscription.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.tier.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getStatusText(subscription),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(subscription.status),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(context, subscription.status),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullSubscriptionCard(
    BuildContext context, 
    Subscription subscription, 
    PremiumProvider provider
  ) {
    final theme = Theme.of(context);
    final daysRemaining = subscription.remainingDays;
    final isExpiringSoon = daysRemaining <= 7;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: subscription.status == SubscriptionStatus.active
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
              )
            : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.diamond,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              subscription.tier.displayName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(context, subscription.status),
                          ],
                        ),
                        Text(
                          '${subscription.tier.priceString}/month',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Subscription details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      'Status',
                      _getStatusText(subscription),
                      _getStatusColor(subscription.status),
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      context,
                      'Next Billing',
                      _formatDate(subscription.endDate),
                      isExpiringSoon ? Colors.orange : theme.colorScheme.onSurface,
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      context,
                      'Payment Method',
                      subscription.paymentMethod.displayName,
                      theme.colorScheme.onSurface,
                    ),
                  ],
                ),
              ),

              // Days remaining warning
              if (isExpiringSoon && subscription.status == SubscriptionStatus.active) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your subscription expires in $daysRemaining day${daysRemaining == 1 ? '' : 's'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (subscription.status == SubscriptionStatus.cancelled) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Subscription cancelled. Access until ${_formatDate(subscription.endDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap ?? () => Navigator.of(context).pushNamed('/premium'),
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text('Manage'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showUsageStats(context, provider);
                      },
                      icon: const Icon(Icons.bar_chart, size: 16),
                      label: const Text('Usage'),
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

  Widget _buildFreeFeaturesList(BuildContext context) {
    final freeFeatures = [
      'Basic cycle tracking',
      'Simple predictions',
      'Limited exports (5/month)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Features:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...freeFeatures.map((feature) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                feature,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, SubscriptionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, 
    String label, 
    String value, 
    Color? valueColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.cancelled:
        return Colors.red;
      case SubscriptionStatus.expired:
        return Colors.grey;
      case SubscriptionStatus.pending:
        return Colors.orange;
      case SubscriptionStatus.suspended:
        return Colors.amber;
    }
  }

  String _getStatusText(Subscription subscription) {
    switch (subscription.status) {
      case SubscriptionStatus.active:
        final daysRemaining = subscription.remainingDays;
        return 'Active ($daysRemaining days remaining)';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.pending:
        return 'Payment Pending';
      case SubscriptionStatus.suspended:
        return 'Suspended - Payment Issue';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showUsageStats(BuildContext context, PremiumProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Premium Feature Usage',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Usage statistics for this month',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildUsageCard(
                      context,
                      'Custom Reports',
                      provider.monthlyUsage[PremiumFeatureType.customReports] ?? 0,
                      null,
                      Icons.assessment,
                    ),
                    _buildUsageCard(
                      context,
                      'Data Exports',
                      provider.monthlyUsage[PremiumFeatureType.unlimitedExports] ?? 0,
                      null,
                      Icons.download,
                    ),
                    _buildUsageCard(
                      context,
                      'AI Predictions',
                      provider.monthlyUsage[PremiumFeatureType.advancedAI] ?? 0,
                      null,
                      Icons.smart_toy,
                    ),
                    _buildUsageCard(
                      context,
                      'Health Syncs',
                      provider.monthlyUsage[PremiumFeatureType.biometricSync] ?? 0,
                      null,
                      Icons.fitness_center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageCard(
    BuildContext context,
    String title,
    int usage,
    int? limit,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    limit != null ? '$usage / $limit used' : '$usage used',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              usage.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
