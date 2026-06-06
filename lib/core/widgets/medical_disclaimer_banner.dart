import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/settings/widgets/medical_citations_section.dart';

/// Medical Disclaimer Banner
/// Always-visible disclaimer on screens with medical content
/// Keeps health information transparency visible and understandable
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
            AppTheme.warningOrange.withValues(alpha: 0.03),
            AppTheme.warningOrange.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.warningOrange.withValues(alpha: 0.2),
          width: 1,
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
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
                                  leading: IconButton(
                                    icon: const Icon(Icons.arrow_back_ios_new),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  title: const Text(
                                    'Medical Sources & Citations',
                                  ),
                                  automaticallyImplyLeading: false,
                                ),
                                const Expanded(
                                  child: MedicalCitationsSection(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryBlue.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppTheme.secondaryBlue.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Text(
                        'View sources',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondaryBlue,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
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
