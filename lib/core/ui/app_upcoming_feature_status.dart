import 'package:flutter/material.dart';

import 'app_geometry.dart';

enum AppFeatureAvailability { active, comingSoon }

class AppUpcomingFeatureStatus extends StatelessWidget {
  const AppUpcomingFeatureStatus({
    super.key,
    required this.releaseLabel,
    required this.availability,
    this.compact = false,
    this.color,
  });

  final String releaseLabel;
  final AppFeatureAvailability availability;
  final bool compact;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final statusColor = color ?? scheme.primary;
    final badgeHorizontal = compact ? 6.0 : 8.0;
    final badgeVertical = compact ? 2.0 : 4.0;
    final statusIconSize = compact ? 12.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: badgeHorizontal,
            vertical: badgeVertical,
          ),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(
              compact ? 6 : AppGeometry.radiusSm,
            ),
          ),
          child: Text(
            releaseLabel,
            maxLines: 1,
            softWrap: false,
            style: compact
                ? TextStyle(
                    color: statusColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  )
                : theme.textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
          ),
        ),
        if (!compact && availability == AppFeatureAvailability.comingSoon) ...[
          SizedBox(height: compact ? 6 : 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: statusIconSize,
                color: statusColor,
              ),
              SizedBox(width: compact ? 4 : 6),
              Text(
                'Coming Soon',
                maxLines: 1,
                softWrap: false,
                style:
                    (compact
                            ? theme.textTheme.labelSmall
                            : theme.textTheme.labelMedium)
                        ?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
