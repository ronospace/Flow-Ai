import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ai/period_prediction_engine.dart';

class AIPredictionCard extends StatelessWidget {
  final PeriodPrediction prediction;
  final VoidCallback? onTap;
  
  const AIPredictionCard({
    super.key,
    required this.prediction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryRose.withValues(alpha: 0.1),
              AppTheme.primaryPurple.withValues(alpha: 0.1),
              AppTheme.accentMint.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryRose.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryRose.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with AI badge
              _buildHeader(theme),
              
              const SizedBox(height: 20),
              
              // Main prediction display
              _buildPredictionDisplay(theme),
              
              const SizedBox(height: 20),
              
              // Confidence and additional info
              _buildConfidenceSection(theme),
              
              const SizedBox(height: 16),
              
              // AI Insights
              if (prediction.insights.isNotEmpty) ...[
                _buildInsightsSection(theme),
                const SizedBox(height: 12),
              ],
              
              // Fertility window
              _buildFertilityWindow(theme),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
      .shimmer(delay: 800.ms, duration: 1200.ms);
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryRose.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology_rounded,
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
                'AI Period Prediction',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                prediction.algorithm,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getConfidenceColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getConfidenceColor().withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            prediction.confidenceDescription.toUpperCase(),
            style: TextStyle(
              color: _getConfidenceColor(),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPredictionDisplay(ThemeData theme) {
    final daysUntil = prediction.daysUntilNextPeriod;
    final isToday = daysUntil == 0;
    final isPast = daysUntil < 0;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getPredictionStatusText(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getPredictionStatusColor(),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, MMMM d').format(prediction.nextPeriodDate),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getPredictionStatusColor().withValues(alpha: 0.1),
                _getPredictionStatusColor().withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: _getPredictionStatusColor().withValues(alpha: 0.1),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isPast ? '${(-daysUntil)}' : '$daysUntil',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getPredictionStatusColor(),
                ),
              ),
              Text(
                isPast ? (daysUntil == -1 ? 'day ago' : 'days ago') 
                      : (daysUntil == 1 ? 'day' : 'days'),
                style: TextStyle(
                  fontSize: 10,
                  color: _getPredictionStatusColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildConfidenceSection(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.analytics_rounded,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Text(
          'Confidence: ${prediction.confidenceLevel}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LinearProgressIndicator(
            value: prediction.confidenceLevel / 100,
            backgroundColor: AppTheme.lightGrey.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(_getConfidenceColor()),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Cycle: ${prediction.cycleLengthPrediction}d',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.mediumGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInsightsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_rounded,
              size: 16,
              color: AppTheme.accentMint,
            ),
            const SizedBox(width: 8),
            Text(
              'AI Insights',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...prediction.insights.take(2).map((insight) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 6, right: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentMint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Text(
                  insight,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGrey,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
  
  Widget _buildFertilityWindow(ThemeData theme) {
    final fertilityWindow = prediction.fertilityWindow;
    final startDate = fertilityWindow[0];
    final endDate = fertilityWindow[1];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentMint.withValues(alpha: 0.1),
            AppTheme.secondaryBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentMint.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco_rounded,
                size: 16,
                color: AppTheme.accentMint,
              ),
              const SizedBox(width: 8),
              Text(
                'Fertility Window',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Most Fertile Days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGrey,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentMint,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentMint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '6 Days',
                  style: TextStyle(
                    color: AppTheme.accentMint,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _getPredictionStatusText() {
    final daysUntil = prediction.daysUntilNextPeriod;
    
    if (daysUntil == 0) {
      return 'Today';
    } else if (daysUntil == 1) {
      return 'Tomorrow';
    } else if (daysUntil > 1) {
      return 'In $daysUntil days';
    } else if (daysUntil == -1) {
      return 'Yesterday';
    } else {
      return '${-daysUntil} days ago';
    }
  }
  
  Color _getPredictionStatusColor() {
    final daysUntil = prediction.daysUntilNextPeriod;
    
    if (daysUntil <= 0) {
      return AppTheme.primaryRose;
    } else if (daysUntil <= 3) {
      return AppTheme.warningOrange;
    } else if (daysUntil <= 7) {
      return AppTheme.accentMint;
    } else {
      return AppTheme.secondaryBlue;
    }
  }
  
  Color _getConfidenceColor() {
    if (prediction.confidenceLevel >= 85) {
      return AppTheme.successGreen;
    } else if (prediction.confidenceLevel >= 70) {
      return AppTheme.warningOrange;
    } else {
      return AppTheme.mediumGrey;
    }
  }
}

/// Compact version for home screen
class AIPredictionSummary extends StatelessWidget {
  final PeriodPrediction prediction;
  final VoidCallback? onTap;
  
  const AIPredictionSummary({
    super.key,
    required this.prediction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysUntil = prediction.daysUntilNextPeriod;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryRose.withValues(alpha: 0.1),
              AppTheme.primaryPurple.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryRose.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'AI Prediction',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentMint.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${prediction.confidenceLevel}%',
                          style: const TextStyle(
                            color: AppTheme.accentMint,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    daysUntil <= 0 
                      ? 'Period expected today'
                      : 'Next period in $daysUntil days',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.mediumGrey,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3, end: 0);
  }
}
