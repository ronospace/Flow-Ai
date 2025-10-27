import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/ai_insights.dart';
import '../../../core/models/medical_citation.dart';

class AIInsightCard extends StatelessWidget {
  final AIInsight insight;

  const AIInsightCard({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getInsightTypeColor().withValues(alpha: 0.3),
        ),
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
          // Medical Disclaimer Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.warningOrange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppTheme.warningOrange,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.medicalDisclaimerShort,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.warningOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Header with type icon and confidence
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getInsightTypeColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getInsightTypeIcon(),
                  color: _getInsightTypeColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insight.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(insight.confidence * 100).round()}%',
                  style: TextStyle(
                    color: _getConfidenceColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            insight.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          
          // Recommendations
          if (insight.recommendations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Recommendations:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getInsightTypeColor(),
              ),
            ),
            const SizedBox(height: 8),
            ...insight.recommendations.map((recommendation) => 
              Padding(padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, right: 8),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _getInsightTypeColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Actionable indicator
          if (insight.actionable)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryRose.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryRose.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: AppTheme.primaryRose,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Actionable Insight',
                    style: TextStyle(
                      color: AppTheme.primaryRose,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
          // Medical Citations Section
          if (insight.allCitations.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.secondaryBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.medical_information,
                        size: 16,
                        color: AppTheme.secondaryBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Medical Sources',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This information is based on medical research and clinical guidelines:',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...insight.allCitations.map((citation) => 
                    _buildCitationItem(context, citation),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Color _getInsightTypeColor() {
    switch (insight.type) {
      case InsightType.cycleRegularity:
        return AppTheme.accentMint;
      case InsightType.symptomPattern:
        return AppTheme.secondaryBlue;
      case InsightType.healthTrend:
        return AppTheme.primaryPurple;
      case InsightType.fertilityWindow:
        return AppTheme.primaryRose;
      case InsightType.moodPattern:
        return AppTheme.primaryPurple;
      case InsightType.energyPattern:
        return AppTheme.accentMint;
      case InsightType.cyclePattern:
        return AppTheme.secondaryBlue;
      case InsightType.predictionAccuracy:
        return AppTheme.primaryRose;
      case InsightType.phaseAnalysis:
        return AppTheme.primaryPurple;
      case InsightType.correlationInsight:
        return AppTheme.accentMint;
      case InsightType.healthRecommendation:
        return AppTheme.successGreen;
      case InsightType.nutritionGuidance:
        return AppTheme.warningOrange;
      case InsightType.sleepOptimization:
        return AppTheme.secondaryBlue;
    }
  }

  IconData _getInsightTypeIcon() {
    switch (insight.type) {
      case InsightType.cycleRegularity:
        return Icons.timer;
      case InsightType.symptomPattern:
        return Icons.analytics;
      case InsightType.healthTrend:
        return Icons.trending_up;
      case InsightType.fertilityWindow:
        return Icons.favorite;
      case InsightType.moodPattern:
        return Icons.mood;
      case InsightType.energyPattern:
        return Icons.battery_charging_full;
      case InsightType.cyclePattern:
        return Icons.refresh;
      case InsightType.predictionAccuracy:
        return Icons.gps_fixed;
      case InsightType.phaseAnalysis:
        return Icons.nightlight_round;
      case InsightType.correlationInsight:
        return Icons.link;
      case InsightType.healthRecommendation:
        return Icons.health_and_safety;
      case InsightType.nutritionGuidance:
        return Icons.restaurant;
      case InsightType.sleepOptimization:
        return Icons.bedtime;
    }
  }

  Color _getConfidenceColor() {
    if (insight.confidence >= 0.8) {
      return AppTheme.successGreen;
    } else if (insight.confidence >= 0.6) {
      return AppTheme.primaryPurple;
    } else {
      return AppTheme.mediumGrey;
    }
  }
  
  Widget _buildCitationItem(BuildContext context, MedicalCitation citation) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Citation source and year
          Row(
            children: [
              Expanded(
                child: Text(
                  citation.source,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryBlue,
                  ),
                ),
              ),
              if (citation.year != null)
                Text(
                  citation.year!,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // Citation title
          Text(
            citation.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          // View source button
          InkWell(
            onTap: () => _launchCitationUrl(citation.url),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.open_in_new,
                  size: 12,
                  color: AppTheme.secondaryBlue,
                ),
                const SizedBox(width: 4),
                Text(
                  'View Source',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryBlue,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _launchCitationUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
