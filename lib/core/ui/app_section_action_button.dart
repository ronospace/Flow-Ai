import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_geometry.dart';

/// Shared primary action used inside Flow Ai section content carriers.
///
/// Feature screens own the action semantics. This widget owns consistent
/// geometry, visual weight, interaction surface, and responsive width.
class AppSectionActionButton extends StatelessWidget {
  const AppSectionActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.accentColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(46),
          backgroundColor: accentColor,
          foregroundColor: AppTheme.onBrightAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppGeometry.radiusSm),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
