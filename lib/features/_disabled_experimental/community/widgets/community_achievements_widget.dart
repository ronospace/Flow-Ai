import 'package:flutter/material.dart';
import '../../../core/models/community_models.dart';

class CommunityAchievementsWidget extends StatelessWidget {
  final List<CommunityAchievement> achievements;
  final Function(CommunityAchievement)? onClaimReward;
  final VoidCallback? onViewAll;

  const CommunityAchievementsWidget({
    super.key,
    required this.achievements,
    this.onClaimReward,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final unlockedAchievements = achievements.where((a) => a.isUnlocked).take(3).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Achievements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (unlockedAchievements.isEmpty)
              const Center(
                child: Text(
                  'No achievements yet. Keep participating!',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...unlockedAchievements.map((achievement) => 
                _buildAchievementTile(context, achievement)
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementTile(BuildContext context, CommunityAchievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement.isUnlocked 
          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: achievement.isUnlocked 
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: achievement.isUnlocked 
                ? Theme.of(context).primaryColor
                : Colors.grey,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getAchievementIcon(achievement.iconName),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: achievement.isUnlocked 
                      ? null 
                      : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: achievement.isUnlocked 
                      ? Colors.grey[600]
                      : Colors.grey,
                  ),
                ),
                if (achievement.progress < achievement.targetCount)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: LinearProgressIndicator(
                      value: achievement.progress / achievement.targetCount,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (achievement.isUnlocked && !achievement.isRewardClaimed && onClaimReward != null)
            ElevatedButton(
              onPressed: () => onClaimReward!(achievement),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 32),
              ),
              child: const Text('Claim', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  IconData _getAchievementIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'community':
        return Icons.people;
      case 'discussion':
        return Icons.forum;
      case 'expert':
        return Icons.school;
      case 'buddy':
        return Icons.favorite;
      case 'story':
        return Icons.book;
      case 'first_post':
        return Icons.edit;
      case 'helpful':
        return Icons.thumb_up;
      case 'explorer':
        return Icons.explore;
      default:
        return Icons.star;
    }
  }
}
