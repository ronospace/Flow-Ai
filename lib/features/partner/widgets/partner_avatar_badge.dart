import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PartnerAvatarBadge extends StatelessWidget {
  final String name;
  final bool isPrimary;

  const PartnerAvatarBadge({
    super.key,
    required this.name,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPrimary
              ? [AppTheme.primaryRose, AppTheme.primaryPurple]
              : [AppTheme.secondaryBlue, AppTheme.accentMint],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).cardColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
