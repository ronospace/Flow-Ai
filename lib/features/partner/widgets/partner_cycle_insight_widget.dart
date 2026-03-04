import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/partner_models.dart';

class PartnerCycleInsightWidget extends StatelessWidget {
  final Partnership partnership;

  const PartnerCycleInsightWidget({super.key, required this.partnership});

  @override
  Widget build(BuildContext context) {
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
                Icon(Icons.insights, color: AppTheme.primaryRose),
                const SizedBox(width: 12),
                Text(
                  'Cycle Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Partner cycle insights coming soon',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
