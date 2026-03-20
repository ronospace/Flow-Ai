import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/settings/widgets/medical_citations_section.dart';

/// Medical Citations Footer Widget
/// Shows on all screens displaying medical information
/// Required by App Store Guideline 1.4.1 - Medical Citations must be easy to find
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 600),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppBar(
                            title: const Text('Medical Sources & Citations'),
                            automaticallyImplyLeading: false,
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          const Expanded(child: MedicalCitationsSection()),
                        ],
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.library_books, size: 18),
              label: const Text('View sources'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
