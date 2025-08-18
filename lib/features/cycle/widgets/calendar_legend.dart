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
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                  color: AppTheme.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Legend items in a grid
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  context,
                  'Menstrual',
                  AppTheme.primaryRose,
                  '🩸',
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  context,
                  'Follicular',
                  AppTheme.accentMint,
                  '🌱',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  context,
                  'Ovulation',
                  AppTheme.secondaryBlue,
                  '🥚',
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  context,
                  'Luteal',
                  AppTheme.primaryPurple,
                  '🌙',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Additional info
          Row(
            children: [
              _buildIndicator(AppTheme.accentMint.withValues(alpha: 0.8), 'Today'),
              const Spacer(),
              _buildIndicator(
                Colors.transparent,
                'Predicted',
                hasBorder: true,
                borderColor: AppTheme.secondaryBlue,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Fertile Window indicator
          Row(
            children: [
              _buildIndicator(
                AppTheme.accentMint.withValues(alpha: 0.6),
                'Fertile Window',
              ),
              const Spacer(),
              _buildIndicator(
                AppTheme.secondaryBlue.withValues(alpha: 0.6),
                'Ovulation',
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
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.mediumGrey,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: 100 + label.hashCode % 300));
  }

  Widget _buildIndicator(
    Color color,
    String label, {
    bool hasBorder = false,
    Color? borderColor,
  }) {
    return Row(
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
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.mediumGrey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
