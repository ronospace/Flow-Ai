import 'package:flutter/material.dart';
import '../models/streak_data.dart';

class StreakWidget extends StatelessWidget {
  final StreakData streak;
  final VoidCallback? onTap;

  const StreakWidget({
    super.key,
    required this.streak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getStreakColor().withValues(alpha: 0.1),
                _getStreakColor().withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Streak Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getStreakColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getStreakIcon(),
                        color: _getStreakColor(),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Streak Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStreakTitle(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            streak.streakStatusMessage,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Current Streak Display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getStreakColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${streak.currentStreak}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'days',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.1),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Longest',
                        '${streak.longestStreak} days',
                        Icons.trending_up,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'This Week',
                        '${streak.thisWeekActivities.length}/7',
                        Icons.calendar_view_week,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'This Month',
                        '${streak.thisMonthActivities.length}',
                        Icons.calendar_month,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Weekly Activity Grid
                _buildWeeklyGrid(),
                
                const SizedBox(height: 16),
                
                // Next Milestone
                if (streak.nextMilestone != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Next milestone: ${streak.nextMilestone} days',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        Text(
                          '${streak.nextMilestone! - streak.currentStreak} to go',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGrid() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Week',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final date = startOfWeek.add(Duration(days: index));
            final hasActivity = streak.activityDates.any((activityDate) =>
                activityDate.year == date.year &&
                activityDate.month == date.month &&
                activityDate.day == date.day);
            
            final isToday = date.year == now.year &&
                           date.month == now.month &&
                           date.day == now.day;
            
            final isFuture = date.isAfter(now);
            
            return Column(
              children: [
                Text(
                  ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isFuture 
                        ? Colors.grey[200]
                        : hasActivity 
                            ? _getStreakColor()
                            : Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                    border: isToday 
                        ? Border.all(color: _getStreakColor(), width: 2)
                        : null,
                  ),
                  child: Center(
                    child: hasActivity && !isFuture
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isFuture 
                                  ? Colors.grey[400]
                                  : hasActivity
                                      ? Colors.white
                                      : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Color _getStreakColor() {
    if (streak.currentStreak >= 30) return Colors.purple;
    if (streak.currentStreak >= 14) return Colors.orange;
    if (streak.currentStreak >= 7) return Colors.blue;
    if (streak.currentStreak >= 3) return Colors.green;
    return Colors.grey;
  }

  IconData _getStreakIcon() {
    switch (streak.type.toLowerCase()) {
      case 'tracking':
        return Icons.track_changes;
      case 'mood':
        return Icons.sentiment_satisfied;
      case 'exercise':
        return Icons.fitness_center;
      case 'water':
        return Icons.local_drink;
      case 'sleep':
        return Icons.bedtime;
      default:
        return Icons.local_fire_department;
    }
  }

  String _getStreakTitle() {
    switch (streak.type.toLowerCase()) {
      case 'tracking':
        return 'Tracking Streak';
      case 'mood':
        return 'Mood Logging';
      case 'exercise':
        return 'Exercise Streak';
      case 'water':
        return 'Hydration Streak';
      case 'sleep':
        return 'Sleep Tracking';
      default:
        return 'Activity Streak';
    }
  }
}

class CompactStreakWidget extends StatelessWidget {
  final StreakData streak;
  final VoidCallback? onTap;

  const CompactStreakWidget({
    super.key,
    required this.streak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getStreakColor().withValues(alpha: 0.1),
                _getStreakColor().withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Column(
            children: [
              // Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getStreakColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStreakIcon(),
                  color: _getStreakColor(),
                  size: 16,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Current Streak
              Text(
                '${streak.currentStreak}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getStreakColor(),
                ),
              ),
              Text(
                'days',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Type
              Text(
                _getStreakTitle(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStreakColor() {
    if (streak.currentStreak >= 30) return Colors.purple;
    if (streak.currentStreak >= 14) return Colors.orange;
    if (streak.currentStreak >= 7) return Colors.blue;
    if (streak.currentStreak >= 3) return Colors.green;
    return Colors.grey;
  }

  IconData _getStreakIcon() {
    switch (streak.type.toLowerCase()) {
      case 'tracking':
        return Icons.track_changes;
      case 'mood':
        return Icons.sentiment_satisfied;
      case 'exercise':
        return Icons.fitness_center;
      case 'water':
        return Icons.local_drink;
      case 'sleep':
        return Icons.bedtime;
      default:
        return Icons.local_fire_department;
    }
  }

  String _getStreakTitle() {
    switch (streak.type.toLowerCase()) {
      case 'tracking':
        return 'Tracking';
      case 'mood':
        return 'Mood';
      case 'exercise':
        return 'Exercise';
      case 'water':
        return 'Water';
      case 'sleep':
        return 'Sleep';
      default:
        return 'Activity';
    }
  }
}
