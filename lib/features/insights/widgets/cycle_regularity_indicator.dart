import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class CycleRegularityIndicator extends StatelessWidget {
  final double regularityScore; // 0.0 to 1.0
  final double averageCycleLength;
  final double standardDeviation;
  final int totalCycles;

  const CycleRegularityIndicator({
    super.key,
    required this.regularityScore,
    required this.averageCycleLength,
    required this.standardDeviation,
    required this.totalCycles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentMint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.timeline,
                  color: AppTheme.accentMint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Cycle Regularity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Regularity Score Bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getRegularityLabel(regularityScore),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getRegularityColor(regularityScore),
                          ),
                        ),
                        Text(
                          '${(regularityScore * 100).round()}%',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getRegularityColor(regularityScore),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: regularityScore,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getRegularityColor(regularityScore).withValues(alpha: 0.7),
                                _getRegularityColor(regularityScore),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Stats Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStat(
                        context,
                        'Average Cycle',
                        '${averageCycleLength.round()} days',
                        Icons.calendar_today,
                        AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStat(
                        context,
                        'Variation',
                        '±${standardDeviation.round()} days',
                        Icons.show_chart,
                        AppTheme.secondaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStat(
                        context,
                        'Total Cycles',
                        totalCycles.toString(),
                        Icons.repeat,
                        AppTheme.accentMint,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStat(
                        context,
                        'Consistency',
                        _getConsistencyLabel(standardDeviation),
                        Icons.check_circle_outline,
                        _getConsistencyColor(standardDeviation),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Insight message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getRegularityColor(regularityScore).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getRegularityColor(regularityScore).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getRegularityIcon(regularityScore),
                  color: _getRegularityColor(regularityScore),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getRegularityInsight(regularityScore, standardDeviation),
                    style: TextStyle(
                      color: AppTheme.mediumGrey,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // View Sources link
          GestureDetector(
            onTap: () {
              // Navigate to detailed insights or show citation dialog
              _showCitationDialog(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book,
                  size: 14,
                  color: AppTheme.primaryPurple,
                ),
                const SizedBox(width: 6),
                Text(
                  'View Sources',
                  style: TextStyle(
                    color: AppTheme.primaryPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildStat(BuildContext context, String label, String value, 
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.mediumGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getRegularityColor(double score) {
    if (score >= 0.8) {
      return AppTheme.successGreen;
    } else if (score >= 0.6) {
      return AppTheme.accentMint;
    } else if (score >= 0.4) {
      return AppTheme.primaryPurple;
    } else {
      return AppTheme.accentCoral;
    }
  }

  String _getRegularityLabel(double score) {
    if (score >= 0.8) {
      return 'Very Regular';
    } else if (score >= 0.6) {
      return 'Mostly Regular';
    } else if (score >= 0.4) {
      return 'Somewhat Irregular';
    } else {
      return 'Irregular';
    }
  }

  IconData _getRegularityIcon(double score) {
    if (score >= 0.8) {
      return Icons.check_circle;
    } else if (score >= 0.6) {
      return Icons.timeline;
    } else {
      return Icons.warning;
    }
  }

  Color _getConsistencyColor(double stdDev) {
    if (stdDev <= 2) {
      return AppTheme.successGreen;
    } else if (stdDev <= 4) {
      return AppTheme.accentMint;
    } else if (stdDev <= 7) {
      return AppTheme.primaryPurple;
    } else {
      return AppTheme.accentCoral;
    }
  }

  String _getConsistencyLabel(double stdDev) {
    if (stdDev <= 2) {
      return 'Excellent';
    } else if (stdDev <= 4) {
      return 'Good';
    } else if (stdDev <= 7) {
      return 'Fair';
    } else {
      return 'Variable';
    }
  }

  String _getRegularityInsight(double score, double stdDev) {
    if (score >= 0.8) {
      return 'Your cycles are very consistent! This regularity helps with accurate predictions and fertility awareness.';
    } else if (score >= 0.6) {
      return 'Your cycles show good regularity with minor variations. Keep tracking to maintain this pattern.';
    } else if (score >= 0.4) {
      return 'Your cycles show some irregularity. Stress, lifestyle changes, or health factors might be influencing this.';
    } else {
      return 'Your cycles are quite irregular. Consider discussing this pattern with your healthcare provider.';
    }
  }

  void _showCitationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.menu_book,
              color: AppTheme.primaryPurple,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text('Cycle Regularity Sources'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This analysis is based on:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
              const SizedBox(height: 12),
              _buildCitation(
                '1. Cycle Length Analysis',
                'Statistical analysis of your recorded cycle lengths over time.',
              ),
              _buildCitation(
                '2. Variation Tracking',
                'Standard deviation calculation to measure cycle consistency.',
              ),
              _buildCitation(
                '3. Pattern Recognition',
                'Machine learning models trained on clinical cycle data and research.',
              ),
              _buildCitation(
                '4. Medical Guidelines',
                'Based on ACOG and WHO standards for menstrual health assessment.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppTheme.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitation(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppTheme.accentMint,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.darkGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.mediumGrey,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
