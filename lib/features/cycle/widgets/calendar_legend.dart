import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryRose,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Cycle Phases',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Legend items in a grid
          IntrinsicHeight(
            child: Row(
              children: [
                Flexible(
                  child: _buildLegendItem(
                    context,
                    'Menstrual',
                    AppTheme.primaryRose,
                    '🩸',
                  ),
                ),
                Flexible(
                  child: _buildLegendItem(
                    context,
                    'Follicular',
                    AppTheme.accentMint,
                    '🌱',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              children: [
                Flexible(
                  child: _buildLegendItem(
                    context,
                    'Ovulation',
                    AppTheme.secondaryBlue,
                    '🥚',
                  ),
                ),
                Flexible(
                  child: _buildLegendItem(
                    context,
                    'Luteal',
                    AppTheme.primaryPurple,
                    '🌙',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Additional info with improved flow intensity indicators
          Row(
            children: [
              _buildFlowIntensityIndicator('Light Flow', '💧', 8),
              const Spacer(),
              _buildFlowIntensityIndicator('Heavy Flow', '🔴', 12),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Status indicators
          Row(
            children: [
              _buildIndicator(context, AppTheme.accentMint.withValues(alpha: 0.8), 'Today'),
              const Spacer(),
              _buildIndicator(
                context,
                Colors.transparent,
                'AI Predicted',
                hasBorder: true,
                borderColor: AppTheme.secondaryBlue,
                hasRobotIcon: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    String emoji,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.6)],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: 100 + label.hashCode % 300));
  }

  Widget _buildIndicator(
    BuildContext context,
    Color color,
    String label, {
    bool hasBorder = false,
    Color? borderColor,
    bool hasRobotIcon = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: hasBorder && borderColor != null
                ? Border.all(color: borderColor, width: 2)
                : null,
          ),
          child: hasRobotIcon
              ? const Center(
                  child: Text(
                    '🤖',
                    style: TextStyle(fontSize: 8),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFlowIntensityIndicator(String label, String emoji, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppTheme.primaryRose.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryRose.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: size),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ),
      ],
    );
  }
}
