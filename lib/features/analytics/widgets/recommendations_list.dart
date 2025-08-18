import 'package:flutter/material.dart';
import '../../../core/services/analytics_service.dart';

class RecommendationsList extends StatelessWidget {
  final List<PersonalizedRecommendation> recommendations;
  final Function(PersonalizedRecommendation)? onRecommendationTap;

  const RecommendationsList({
    super.key,
    required this.recommendations,
    this.onRecommendationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (recommendations.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recommendations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final recommendation = recommendations[index];
        return _buildRecommendationCard(recommendation, theme);
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Recommendations Yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep tracking your health data to get personalized insights and recommendations.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    PersonalizedRecommendation recommendation,
    ThemeData theme,
  ) {
    final priorityColor = _getPriorityColor(recommendation.priority, theme);
    final categoryIcon = _getCategoryIcon(recommendation.category);
    
    return InkWell(
      onTap: () => onRecommendationTap?.call(recommendation),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: priorityColor.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    categoryIcon,
                    color: priorityColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _buildPriorityChip(recommendation.priority, priorityColor, theme),
                          const SizedBox(width: 8),
                          _buildCategoryChip(recommendation.category, theme),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              recommendation.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            
            // Action items preview
            if (recommendation.actionItems.isNotEmpty) ...[
              Text(
                'Quick Actions:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 6),
              ...recommendation.actionItems.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              if (recommendation.actionItems.length > 2)
                Text(
                  '+${recommendation.actionItems.length - 2} more actions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: priorityColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(
    RecommendationPriority priority,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getPriorityLabel(priority),
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(RecommendationCategory category, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getCategoryLabel(category),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getPriorityColor(RecommendationPriority priority, ThemeData theme) {
    switch (priority) {
      case RecommendationPriority.urgent:
        return Colors.red;
      case RecommendationPriority.high:
        return Colors.orange;
      case RecommendationPriority.medium:
        return Colors.blue;
      case RecommendationPriority.low:
        return theme.colorScheme.primary;
    }
  }

  IconData _getCategoryIcon(RecommendationCategory category) {
    switch (category) {
      case RecommendationCategory.cycle:
        return Icons.favorite;
      case RecommendationCategory.health:
        return Icons.local_hospital;
      case RecommendationCategory.mood:
        return Icons.mood;
      case RecommendationCategory.sleep:
        return Icons.bed;
      case RecommendationCategory.nutrition:
        return Icons.restaurant;
      case RecommendationCategory.exercise:
        return Icons.fitness_center;
    }
  }

  String _getPriorityLabel(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.urgent:
        return 'URGENT';
      case RecommendationPriority.high:
        return 'HIGH';
      case RecommendationPriority.medium:
        return 'MEDIUM';
      case RecommendationPriority.low:
        return 'LOW';
    }
  }

  String _getCategoryLabel(RecommendationCategory category) {
    switch (category) {
      case RecommendationCategory.cycle:
        return 'Cycle';
      case RecommendationCategory.health:
        return 'Health';
      case RecommendationCategory.mood:
        return 'Mood';
      case RecommendationCategory.sleep:
        return 'Sleep';
      case RecommendationCategory.nutrition:
        return 'Nutrition';
      case RecommendationCategory.exercise:
        return 'Exercise';
    }
  }
}
