import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/settings/widgets/medical_citations_section.dart';

/// Medical Disclaimer Banner
/// Always-visible disclaimer on screens with medical content
/// Required by App Store Guideline 1.4.1 - Medical information transparency
class MedicalDisclaimerBanner extends StatelessWidget {
  const MedicalDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.warningOrange.withValues(alpha: 0.08),
            AppTheme.warningOrange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.warningOrange.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.warningOrange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Health Information Disclaimer',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warningOrange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This app provides health information for awareness only. Not medical advice. Consult a healthcare provider for medical concerns.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
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
                                title: const Text(
                                  'Medical Sources & Citations',
                                ),
                                automaticallyImplyLeading: false,
                                actions: [
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
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
                  child: Text(
                    'View medical sources and citations →',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryBlue,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
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
