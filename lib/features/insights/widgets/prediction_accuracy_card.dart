import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class PredictionAccuracyCard extends StatelessWidget {
  final double accuracy;
  final int totalPredictions;
  final int correctPredictions;

  const PredictionAccuracyCard({
    super.key,
    required this.accuracy,
    required this.totalPredictions,
    required this.correctPredictions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  color: AppTheme.secondaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.track_changes,
                  color: AppTheme.secondaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Prediction Accuracy',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Circular Progress with percentage
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: accuracy,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.lightGrey,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getAccuracyColor(accuracy),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(accuracy * 100).round()}%',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getAccuracyColor(accuracy),
                      ),
                    ),
                    Text(
                      'accurate',
                      style: TextStyle(
                        color: AppTheme.mediumGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat(
                context,
                'Total',
                totalPredictions.toString(),
                Icons.all_inclusive,
                AppTheme.primaryPurple,
              ),
              _buildStat(
                context,
                'Correct',
                correctPredictions.toString(),
                Icons.check_circle,
                AppTheme.successGreen,
              ),
              _buildStat(
                context,
                'Missed',
                (totalPredictions - correctPredictions).toString(),
                Icons.cancel,
                AppTheme.accentCoral,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Accuracy description
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getAccuracyColor(accuracy).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getAccuracyTitle(accuracy),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getAccuracyColor(accuracy),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getAccuracyDescription(accuracy),
                  style: TextStyle(
                    color: AppTheme.mediumGrey,
                    fontSize: 12,
                    height: 1.4,
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
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.mediumGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.9) {
      return AppTheme.successGreen;
    } else if (accuracy >= 0.8) {
      return AppTheme.accentMint;
    } else if (accuracy >= 0.7) {
      return AppTheme.primaryPurple;
    } else if (accuracy >= 0.6) {
      return AppTheme.secondaryBlue;
    } else {
      return AppTheme.accentCoral;
    }
  }

  String _getAccuracyTitle(double accuracy) {
    if (accuracy >= 0.9) {
      return 'Excellent Accuracy';
    } else if (accuracy >= 0.8) {
      return 'Great Accuracy';
    } else if (accuracy >= 0.7) {
      return 'Good Accuracy';
    } else if (accuracy >= 0.6) {
      return 'Fair Accuracy';
    } else {
      return 'Needs Improvement';
    }
  }

  String _getAccuracyDescription(double accuracy) {
    if (accuracy >= 0.9) {
      return 'Outstanding! Your cycle predictions are highly accurate. Keep tracking consistently.';
    } else if (accuracy >= 0.8) {
      return 'Great job! Your predictions are very reliable. Minor variations are normal.';
    } else if (accuracy >= 0.7) {
      return 'Good progress! Continue tracking to improve prediction accuracy over time.';
    } else if (accuracy >= 0.6) {
      return 'Fair accuracy. More data points will help improve future predictions.';
    } else {
      return 'Keep tracking daily! More data is needed for accurate predictions.';
    }
  }
}
