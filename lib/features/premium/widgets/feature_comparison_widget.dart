import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/subscription.dart';
import '../models/premium_feature.dart';

/// Feature Comparison Widget
/// Shows a comparison table of features across subscription tiers
class FeatureComparisonWidget extends StatelessWidget {
  const FeatureComparisonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPurple.withValues(alpha: 0.1),
                  AppTheme.secondaryBlue.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildTierHeader('Basic', AppTheme.mediumGrey),
                ),
                Expanded(
                  child: _buildTierHeader('Premium', AppTheme.primaryPurple),
                ),
                Expanded(
                  child: _buildTierHeader('Ultimate', AppTheme.accentMint),
                ),
              ],
            ),
          ),
          
          // Feature rows
          _buildFeatureRow(
            'Period Tracking',
            basic: true,
            premium: true,
            ultimate: true,
          ),
          _buildFeatureRow(
            'Basic Predictions',
            basic: true,
            premium: true,
            ultimate: true,
          ),
          _buildFeatureRow(
            'Limited Data Exports',
            basic: true,
            premium: false,
            ultimate: false,
            basicNote: '3/month',
          ),
          _buildFeatureRow(
            'Unlimited Exports',
            basic: false,
            premium: true,
            ultimate: true,
          ),
          _buildFeatureRow(
            'Custom Reports',
            basic: false,
            premium: true,
            ultimate: true,
          ),
          _buildFeatureRow(
            'Advanced AI Predictions',
            basic: false,
            premium: true,
            ultimate: true,
            premiumNote: '95% accuracy',
          ),
          _buildFeatureRow(
            'Healthcare Integration',
            basic: false,
            premium: true,
            ultimate: true,
          ),
          _buildFeatureRow(
            'Priority Support',
            basic: false,
            premium: true,
            ultimate: true,
          ),
          _buildFeatureRow(
            'Biometric Data Sync',
            basic: false,
            premium: true,
            ultimate: true,
          ),
          _buildFeatureRow(
            'Multi-User Profiles',
            basic: false,
            premium: false,
            ultimate: true,
            ultimateNote: 'Up to 5',
          ),
          _buildFeatureRow(
            'Advanced Analytics',
            basic: false,
            premium: false,
            ultimate: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTierHeader(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureRow(
    String feature, {
    required bool basic,
    required bool premium,
    required bool ultimate,
    String? basicNote,
    String? premiumNote,
    String? ultimateNote,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: AppTheme.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: _buildFeatureIndicator(basic, basicNote),
          ),
          Expanded(
            child: _buildFeatureIndicator(premium, premiumNote),
          ),
          Expanded(
            child: _buildFeatureIndicator(ultimate, ultimateNote),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIndicator(bool available, String? note) {
    return Center(
      child: Column(
        children: [
          Icon(
            available ? Icons.check_circle : Icons.remove_circle_outline,
            size: 18,
            color: available ? AppTheme.successGreen : AppTheme.mediumGrey,
          ),
          if (note != null) ...[
            const SizedBox(height: 2),
            Text(
              note,
              style: TextStyle(
                fontSize: 9,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
