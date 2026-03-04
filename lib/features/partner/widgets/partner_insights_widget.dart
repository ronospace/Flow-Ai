import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/partner_insight.dart';

class PartnerInsightsWidget extends StatelessWidget {
  final List<PartnerInsight> insights;
  final Function(PartnerInsight)? onInsightTap;

  const PartnerInsightsWidget({
    super.key,
    required this.insights,
    this.onInsightTap,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.lightGrey, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppTheme.warningOrange),
                const SizedBox(width: 12),
                Text(
                  'Partner Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights
                .take(3)
                .map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        insight.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        insight.content,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => onInsightTap?.call(insight),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
