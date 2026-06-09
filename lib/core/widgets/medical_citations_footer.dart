import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'medical_sources_dialog.dart';
import 'source_action_button.dart';

/// Medical Citations Footer Widget
/// Shows on all screens displaying medical information
/// Keeps medical citations easy to find and understand
class MedicalCitationsFooter extends StatelessWidget {
  final bool showInlineCitations;

  const MedicalCitationsFooter({super.key, this.showInlineCitations = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlue.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.secondaryBlue.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_information,
                size: 20,
                color: AppTheme.secondaryBlue,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Medical Sources Available',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'All health information in this app is based on medical research and clinical guidelines from reputable sources including ACOG, NIH, WHO, and peer-reviewed journals.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SourceActionButton.sources(
            color: AppTheme.secondaryBlue,
            icon: Icons.library_books_rounded,
            onPressed: () => showMedicalSourcesDialog(context),
          ),
        ],
      ),
    );
  }
}
