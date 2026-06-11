import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/settings/widgets/medical_citations_section.dart';
import '../theme/app_theme.dart';
import '../constants/app_layout.dart';

Future<void> showMedicalSourcesDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    useSafeArea: true,
    builder: (_) => const MedicalSourcesDialog(),
  );
}

const double _medicalSourcesDialogHorizontalInset = 20.0;
const double _medicalSourcesDialogTopInset = 32.0;
const double _medicalSourcesDialogBottomNavGap = 0.0;
const ValueKey<String> _medicalSourcesDialogShellKey = ValueKey<String>(
  'medical-sources-dialog-shell',
);

class MedicalSourcesDialog extends StatelessWidget {
  const MedicalSourcesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);

    final bottomInset =
        AppLayout.bottomNavigationHeight + _medicalSourcesDialogBottomNavGap;
    final width = math.min(
      720.0,
      math.max(
        0.0,
        media.size.width - (_medicalSourcesDialogHorizontalInset * 2),
      ),
    );
    final height = math.min(
      760.0,
      math.max(
        0.0,
        media.size.height -
            media.padding.vertical -
            _medicalSourcesDialogTopInset -
            bottomInset,
      ),
    );

    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(
        _medicalSourcesDialogHorizontalInset,
        _medicalSourcesDialogTopInset,
        _medicalSourcesDialogHorizontalInset,
        bottomInset,
      ),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        key: _medicalSourcesDialogShellKey,
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
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
