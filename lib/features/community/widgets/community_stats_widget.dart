import 'package:flutter/material.dart';
import '../../../core/models/community_models.dart';

class CommunityStatsWidget extends StatelessWidget {
  final CommunityStats stats;
  final VoidCallback? onRefresh;

  const CommunityStatsWidget({
    Key? key,
    required this.stats,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  'Community Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow('Active Members', stats.activeMembersCount.toString()),
            _buildStatRow('Total Discussions', stats.totalDiscussionsCount.toString()),
            _buildStatRow('Expert Questions', stats.totalQuestionsCount.toString()),
            _buildStatRow('Cycle Buddies', stats.totalBuddiesCount.toString()),
            _buildStatRow('Shared Stories', stats.totalStoriesCount.toString()),
            if (stats.weeklyGrowthRate > 0)
              _buildGrowthIndicator(stats.weeklyGrowthRate),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthIndicator(double growthRate) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_up, color: Colors.green, size: 16),
          const SizedBox(width: 4),
          Text(
            '${growthRate.toStringAsFixed(1)}% growth this week',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
