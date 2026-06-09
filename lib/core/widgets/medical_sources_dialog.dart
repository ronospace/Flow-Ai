import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/settings/widgets/medical_citations_section.dart';
import '../theme/app_theme.dart';

Future<void> showMedicalSourcesDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    useSafeArea: true,
    builder: (_) => const MedicalSourcesDialog(),
  );
}

class MedicalSourcesDialog extends StatelessWidget {
  const MedicalSourcesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);

    final width = math.min(720.0, math.max(0.0, media.size.width - 32.0));
    final height = math.min(
      760.0,
      math.max(0.0, media.size.height - media.padding.vertical - 32.0),
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Medical Sources',
                        softWrap: true,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor),
            const Expanded(child: MedicalCitationsSection()),
          ],
        ),
      ),
    );
  }
}
