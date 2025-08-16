import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class CorrelationInsightsCard extends StatelessWidget {
  final Map<String, double> correlations;
  final bool isPreview;
  final String? title;
  final VoidCallback? onViewMore;

  const CorrelationInsightsCard({
    super.key,
    required this.correlations,
    this.isPreview = false,
    this.title,
    this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    final displayCorrelations = isPreview 
        ? correlations.entries.take(3).toList()
        : correlations.entries.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          
          if (displayCorrelations.isEmpty)
            _buildNoCorrelationsMessage()
          else
            ...displayCorrelations.map((entry) => _buildCorrelationItem(
              context, 
              _getMetricDisplayName(entry.key), 
              entry.value,
            )),
          
          if (isPreview && correlations.length > 3) ...[
            const SizedBox(height: 12),
            _buildViewMoreButton(context),
          ],
          
          if (!isPreview) ...[
            const SizedBox(height: 16),
            _buildInsightsSummary(context),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3, end: 0);
  }
  
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.insights,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? 'Cycle Correlations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
              Text(
                isPreview 
                    ? 'How your health metrics relate to your cycle'
                    : 'Detailed correlation analysis',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mediumGrey,
                ),
              ),
            ],
          ),
        ),
        if (isPreview)
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.mediumGrey,
          ),
      ],
    );
  }
  
  Widget _buildCorrelationItem(BuildContext context, String metric, double correlation) {
    final absCorrelation = correlation.abs();
    final strength = _getCorrelationStrength(absCorrelation);
    final color = _getCorrelationColor(correlation);
    final isPositive = correlation > 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Correlation direction indicator
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$strength ${isPositive ? 'positive' : 'negative'} correlation',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          
          // Correlation strength bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(absCorrelation * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: absCorrelation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoCorrelationsMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.trending_flat,
            size: 32,
            color: AppTheme.mediumGrey.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No Strong Correlations Found',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.mediumGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Keep tracking your health data to discover patterns',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.mediumGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildViewMoreButton(BuildContext context) {
    return GestureDetector(
      onTap: onViewMore,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryRose.withOpacity(0.1),
              AppTheme.primaryPurple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryRose.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View All Correlations (${correlations.length})',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryRose,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: AppTheme.primaryRose,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInsightsSummary(BuildContext context) {
    final strongCorrelations = correlations.entries
        .where((entry) => entry.value.abs() > 0.6)
        .toList();
    
    if (strongCorrelations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.accentMint.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.accentMint,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Continue tracking to discover stronger patterns between your health metrics and cycle.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.darkGrey,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.successGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Key Insights',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _generateInsightText(strongCorrelations),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.darkGrey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
  
  String _generateInsightText(List<MapEntry<String, double>> strongCorrelations) {
    if (strongCorrelations.isEmpty) {
      return 'No strong correlations detected yet. Keep tracking for more insights.';
    }
    
    final strongest = strongCorrelations.first;
    final metricName = _getMetricDisplayName(strongest.key);
    final isPositive = strongest.value > 0;
    
    if (isPositive) {
      return 'Your $metricName shows a strong positive correlation with your cycle, suggesting it tends to increase during certain phases.';
    } else {
      return 'Your $metricName shows a strong negative correlation with your cycle, suggesting it tends to decrease during certain phases.';
    }
  }
  
  String _getMetricDisplayName(String key) {
    switch (key.toLowerCase()) {
      case 'hrv_cycle_correlation':
        return 'Heart Rate Variability';
      case 'sleep_cycle_correlation':
        return 'Sleep Quality';
      case 'temperature_cycle_correlation':
        return 'Body Temperature';
      case 'stress_cycle_correlation':
        return 'Stress Level';
      case 'activity_cycle_correlation':
        return 'Activity Level';
      default:
        // Convert snake_case to Title Case
        return key.split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ')
            .replaceAll(' Correlation', '');
    }
  }
  
  String _getCorrelationStrength(double absCorrelation) {
    if (absCorrelation >= 0.8) return 'Very strong';
    if (absCorrelation >= 0.6) return 'Strong';
    if (absCorrelation >= 0.4) return 'Moderate';
    if (absCorrelation >= 0.2) return 'Weak';
    return 'Very weak';
  }
  
  Color _getCorrelationColor(double correlation) {
    final absCorrelation = correlation.abs();
    
    if (absCorrelation >= 0.6) {
      return correlation > 0 ? AppTheme.successGreen : AppTheme.primaryRose;
    } else if (absCorrelation >= 0.4) {
      return correlation > 0 ? AppTheme.accentMint : AppTheme.warningOrange;
    } else {
      return AppTheme.mediumGrey;
    }
  }
}

class CorrelationItem {
  final String metric;
  final double correlation;
  final String description;
  final IconData icon;

  const CorrelationItem({
    required this.metric,
    required this.correlation,
    required this.description,
    required this.icon,
  });
}
