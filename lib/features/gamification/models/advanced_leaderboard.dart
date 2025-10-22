import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'advanced_leaderboard.g.dart';

/// Advanced Leaderboard Model
/// Multi-dimensional ranking system with social features and different time periods
@JsonSerializable()
class AdvancedLeaderboard {
  final String leaderboardId;
  final String name;
  final String description;
  final LeaderboardType type;
  final LeaderboardPeriod period;
  final List<LeaderboardEntry> entries;
  final DateTime lastUpdated;
  final int? userRank;
  final LeaderboardMetadata metadata;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  AdvancedLeaderboard({
    required this.leaderboardId,
    required this.name,
    required this.description,
    required this.type,
    required this.period,
    required this.entries,
    required this.lastUpdated,
    this.userRank,
    required this.metadata,
    this.isActive = true,
    this.startDate,
    this.endDate,
  });

  /// Get top performers (top 10)
  List<LeaderboardEntry> get topPerformers => entries.take(10).toList();

  /// Get user's entry if they're on the leaderboard
  LeaderboardEntry? get userEntry => entries.firstWhere(
    (entry) => entry.isCurrentUser,
    orElse: () => LeaderboardEntry.empty(),
  );

  /// Get friends on leaderboard
  List<LeaderboardEntry> get friendEntries => entries.where((entry) => entry.isFriend).toList();

  /// Get entries around user's rank
  List<LeaderboardEntry> getEntriesAroundUser({int range = 3}) {
    if (userRank == null) return [];
    
    final startIndex = (userRank! - range - 1).clamp(0, entries.length);
    final endIndex = (userRank! + range).clamp(0, entries.length);
    
    return entries.sublist(startIndex, endIndex);
  }

  /// Check if leaderboard is time-limited
  bool get isTimeLimited => startDate != null && endDate != null;

  /// Get time remaining if time-limited
  Duration? get timeRemaining {
    if (!isTimeLimited || endDate == null) return null;
    
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return Duration.zero;
    
    return endDate!.difference(now);
  }

  /// Get leaderboard status
  LeaderboardStatus get status {
    if (!isActive) return LeaderboardStatus.inactive;
    
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) {
      return LeaderboardStatus.upcoming;
    }
    if (endDate != null && now.isAfter(endDate!)) {
      return LeaderboardStatus.ended;
    }
    
    return LeaderboardStatus.active;
  }

  factory AdvancedLeaderboard.fromJson(Map<String, dynamic> json) => 
      _$AdvancedLeaderboardFromJson(json);
  Map<String, dynamic> toJson() => _$AdvancedLeaderboardToJson(this);
}

/// Leaderboard Entry
@JsonSerializable()
class LeaderboardEntry {
  final String userId;
  final String username;
  final String? displayName;
  final int rank;
  final int? previousRank;
  final int score;
  final Map<String, int> categoryScores;
  final String? avatarUrl;
  final UserTier tier;
  final int level;
  final bool isCurrentUser;
  final bool isFriend;
  final DateTime lastActiveAt;
  final List<String> badges;
  final String? title;
  final LeaderboardEntryStats stats;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    this.displayName,
    required this.rank,
    this.previousRank,
    required this.score,
    this.categoryScores = const {},
    this.avatarUrl,
    this.tier = UserTier.bronze,
    this.level = 1,
    this.isCurrentUser = false,
    this.isFriend = false,
    required this.lastActiveAt,
    this.badges = const [],
    this.title,
    required this.stats,
  });

  /// Get rank change since last period
  RankChange get rankChange {
    if (previousRank == null) return RankChange.new_;
    
    final change = previousRank! - rank;
    if (change > 0) return RankChange.up;
    if (change < 0) return RankChange.down;
    return RankChange.same;
  }

  /// Get rank change amount
  int get rankChangeAmount {
    if (previousRank == null) return 0;
    return (previousRank! - rank).abs();
  }

  /// Get formatted display name
  String get formattedDisplayName {
    return displayName ?? username;
  }

  /// Check if user is in top tier
  bool get isTopTier => tier == UserTier.diamond || tier == UserTier.platinum;

  /// Get tier progress (0-1)
  double get tierProgress {
    // Calculate progress within current tier
    final tierThresholds = _getTierThresholds();
    final currentThreshold = tierThresholds[tier] ?? 0;
    final nextTier = _getNextTier();
    final nextThreshold = nextTier != null ? tierThresholds[nextTier] ?? currentThreshold : currentThreshold;
    
    if (nextThreshold == currentThreshold) return 1.0;
    
    return ((score - currentThreshold) / (nextThreshold - currentThreshold)).clamp(0.0, 1.0);
  }

  UserTier? _getNextTier() {
    switch (tier) {
      case UserTier.bronze:
        return UserTier.silver;
      case UserTier.silver:
        return UserTier.gold;
      case UserTier.gold:
        return UserTier.platinum;
      case UserTier.platinum:
        return UserTier.diamond;
      case UserTier.diamond:
        return null; // Max tier
    }
  }

  Map<UserTier, int> _getTierThresholds() {
    return {
      UserTier.bronze: 0,
      UserTier.silver: 1000,
      UserTier.gold: 2500,
      UserTier.platinum: 5000,
      UserTier.diamond: 10000,
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => 
      _$LeaderboardEntryFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);

  factory LeaderboardEntry.empty() => LeaderboardEntry(
    userId: '',
    username: '',
    rank: 0,
    score: 0,
    lastActiveAt: DateTime.now(),
    stats: LeaderboardEntryStats.empty(),
  );
}

/// Leaderboard Types
enum LeaderboardType {
  points('Total Points', 'Ranked by total points earned', '🎯'),
  achievements('Achievements', 'Ranked by achievements earned', '🏆'),
  streaks('Streaks', 'Ranked by longest streaks', '🔥'),
  challenges('Challenges', 'Ranked by challenges completed', '💪'),
  consistency('Consistency', 'Ranked by consistency score', '📊'),
  social('Social Impact', 'Ranked by community contributions', '👥'),
  learning('Learning', 'Ranked by educational content completed', '📚'),
  wellness('Wellness Score', 'Ranked by overall wellness metrics', '🌟');

  const LeaderboardType(this.displayName, this.description, this.icon);

  final String displayName;
  final String description;
  final String icon;

  /// Get type color
  Color get color {
    switch (this) {
      case LeaderboardType.points:
        return Colors.blue;
      case LeaderboardType.achievements:
        return Colors.orange;
      case LeaderboardType.streaks:
        return Colors.red;
      case LeaderboardType.challenges:
        return Colors.purple;
      case LeaderboardType.consistency:
        return Colors.green;
      case LeaderboardType.social:
        return Colors.pink;
      case LeaderboardType.learning:
        return Colors.indigo;
      case LeaderboardType.wellness:
        return Colors.teal;
    }
  }
}

/// Leaderboard Periods
enum LeaderboardPeriod {
  daily('Daily', 'Last 24 hours'),
  weekly('Weekly', 'Last 7 days'),
  monthly('Monthly', 'Last 30 days'),
  quarterly('Quarterly', 'Last 3 months'),
  yearly('Yearly', 'Last 12 months'),
  allTime('All Time', 'Since account creation'),
  custom('Custom', 'Custom date range');

  const LeaderboardPeriod(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Get period duration
  Duration? get duration {
    switch (this) {
      case LeaderboardPeriod.daily:
        return const Duration(days: 1);
      case LeaderboardPeriod.weekly:
        return const Duration(days: 7);
      case LeaderboardPeriod.monthly:
        return const Duration(days: 30);
      case LeaderboardPeriod.quarterly:
        return const Duration(days: 90);
      case LeaderboardPeriod.yearly:
        return const Duration(days: 365);
      case LeaderboardPeriod.allTime:
      case LeaderboardPeriod.custom:
        return null;
    }
  }
}

/// User Tiers
enum UserTier {
  bronze('Bronze', 'Starting tier for all users', '🥉'),
  silver('Silver', 'Active and engaged users', '🥈'),
  gold('Gold', 'High-performing users', '🥇'),
  platinum('Platinum', 'Elite users with exceptional performance', '💎'),
  diamond('Diamond', 'The highest tier of achievement', '💠');

  const UserTier(this.displayName, this.description, this.icon);

  final String displayName;
  final String description;
  final String icon;

  /// Get tier color
  Color get color {
    switch (this) {
      case UserTier.bronze:
        return const Color(0xFFCD7F32);
      case UserTier.silver:
        return const Color(0xFFC0C0C0);
      case UserTier.gold:
        return const Color(0xFFFFD700);
      case UserTier.platinum:
        return const Color(0xFFE5E4E2);
      case UserTier.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  /// Get tier benefits
  List<String> get benefits {
    switch (this) {
      case UserTier.bronze:
        return ['Basic app features', 'Standard achievements'];
      case UserTier.silver:
        return ['Exclusive silver badges', '10% bonus XP', 'Priority support'];
      case UserTier.gold:
        return ['Gold exclusive content', '25% bonus XP', 'Special challenges', 'Custom themes'];
      case UserTier.platinum:
        return ['Platinum exclusive features', '50% bonus XP', 'Beta access', 'Platinum badge', 'Expert consultations'];
      case UserTier.diamond:
        return ['All premium features', '100% bonus XP', 'VIP status', 'Exclusive events', 'Personal coaching'];
    }
  }
}

/// Rank Change Direction
enum RankChange {
  up('Up', '⬆️', Colors.green),
  down('Down', '⬇️', Colors.red),
  same('Same', '➡️', Colors.grey),
  new_('New', '🆕', Colors.blue);

  const RankChange(this.displayName, this.icon, this.color);

  final String displayName;
  final String icon;
  final Color color;
}

/// Leaderboard Status
enum LeaderboardStatus {
  upcoming('Upcoming', 'Leaderboard hasn\'t started yet'),
  active('Active', 'Leaderboard is currently running'),
  ended('Ended', 'Leaderboard has finished'),
  inactive('Inactive', 'Leaderboard is disabled');

  const LeaderboardStatus(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Leaderboard Metadata
@JsonSerializable()
class LeaderboardMetadata {
  final int totalParticipants;
  final double averageScore;
  final int highestScore;
  final int lowestScore;
  final String? seasonName;
  final List<LeaderboardReward> rewards;
  final Map<String, dynamic> customFields;
  final DateTime createdAt;

  LeaderboardMetadata({
    required this.totalParticipants,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    this.seasonName,
    this.rewards = const [],
    this.customFields = const {},
    required this.createdAt,
  });

  factory LeaderboardMetadata.fromJson(Map<String, dynamic> json) => 
      _$LeaderboardMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardMetadataToJson(this);
}

/// Leaderboard Reward
@JsonSerializable()
class LeaderboardReward {
  final String rewardId;
  final String title;
  final String description;
  final RankRange rankRange;
  final RewardType type;
  final int pointsReward;
  final int xpReward;
  final String? badgeId;
  final String? itemId;
  final String icon;

  LeaderboardReward({
    required this.rewardId,
    required this.title,
    required this.description,
    required this.rankRange,
    required this.type,
    this.pointsReward = 0,
    this.xpReward = 0,
    this.badgeId,
    this.itemId,
    required this.icon,
  });

  /// Check if rank qualifies for this reward
  bool qualifiesForReward(int rank) => rankRange.contains(rank);

  factory LeaderboardReward.fromJson(Map<String, dynamic> json) => 
      _$LeaderboardRewardFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardRewardToJson(this);
}

/// Rank Range for rewards
@JsonSerializable()
class RankRange {
  final int minRank;
  final int maxRank;

  RankRange({
    required this.minRank,
    required this.maxRank,
  });

  /// Check if rank is in range
  bool contains(int rank) => rank >= minRank && rank <= maxRank;

  /// Get range description
  String get description {
    if (minRank == maxRank) return '#$minRank';
    return '#$minRank - #$maxRank';
  }

  factory RankRange.fromJson(Map<String, dynamic> json) => _$RankRangeFromJson(json);
  Map<String, dynamic> toJson() => _$RankRangeToJson(this);
}

/// Reward Types
enum RewardType {
  badge('Badge', 'Exclusive badge'),
  points('Points', 'Bonus points'),
  title('Title', 'User title'),
  item('Item', 'Virtual item'),
  feature('Feature', 'Special feature access');

  const RewardType(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Leaderboard Entry Stats
@JsonSerializable()
class LeaderboardEntryStats {
  final int totalActiveDays;
  final int currentStreak;
  final int longestStreak;
  final double averageDailyScore;
  final int achievementsEarned;
  final int challengesCompleted;
  final double consistencyScore;
  final Map<String, int> categoryBreakdown;

  LeaderboardEntryStats({
    this.totalActiveDays = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.averageDailyScore = 0.0,
    this.achievementsEarned = 0,
    this.challengesCompleted = 0,
    this.consistencyScore = 0.0,
    this.categoryBreakdown = const {},
  });

  /// Get engagement level based on stats
  EngagementLevel get engagementLevel {
    final score = totalActiveDays + (currentStreak * 2) + achievementsEarned;
    
    if (score >= 100) return EngagementLevel.exceptional;
    if (score >= 50) return EngagementLevel.high;
    if (score >= 25) return EngagementLevel.moderate;
    if (score >= 10) return EngagementLevel.low;
    return EngagementLevel.minimal;
  }

  factory LeaderboardEntryStats.fromJson(Map<String, dynamic> json) => 
      _$LeaderboardEntryStatsFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardEntryStatsToJson(this);

  factory LeaderboardEntryStats.empty() => LeaderboardEntryStats();
}

/// Engagement Levels
enum EngagementLevel {
  minimal('Minimal', '😴', Colors.grey),
  low('Low', '😐', Colors.orange),
  moderate('Moderate', '🙂', Colors.yellow),
  high('High', '😊', Colors.lightGreen),
  exceptional('Exceptional', '🤩', Colors.green);

  const EngagementLevel(this.displayName, this.icon, this.color);

  final String displayName;
  final String icon;
  final Color color;
}

/// Leaderboard Filter
class LeaderboardFilter {
  final List<UserTier>? tiers;
  final bool? friendsOnly;
  final int? minLevel;
  final int? maxLevel;
  final EngagementLevel? minEngagement;
  final String? searchQuery;

  LeaderboardFilter({
    this.tiers,
    this.friendsOnly,
    this.minLevel,
    this.maxLevel,
    this.minEngagement,
    this.searchQuery,
  });

  /// Check if entry matches filter
  bool matches(LeaderboardEntry entry) {
    // Tier filter
    if (tiers != null && !tiers!.contains(entry.tier)) {
      return false;
    }

    // Friends only filter
    if (friendsOnly == true && !entry.isFriend) {
      return false;
    }

    // Level filters
    if (minLevel != null && entry.level < minLevel!) {
      return false;
    }
    if (maxLevel != null && entry.level > maxLevel!) {
      return false;
    }

    // Engagement filter
    if (minEngagement != null && 
        entry.stats.engagementLevel.index < minEngagement!.index) {
      return false;
    }

    // Search query filter
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      if (!entry.formattedDisplayName.toLowerCase().contains(query) &&
          !(entry.title?.toLowerCase().contains(query) ?? false)) {
        return false;
      }
    }

    return true;
  }
}

/// Leaderboard Analytics
@JsonSerializable()
class LeaderboardAnalytics {
  final String leaderboardId;
  final LeaderboardPeriod period;
  final int totalEntries;
  final double participationRate;
  final Map<UserTier, int> tierDistribution;
  final Map<int, int> scoreDistribution; // Score ranges -> count
  final double averageRankChange;
  final int newParticipants;
  final int returningParticipants;
  final Map<String, double> categoryAverages;
  final DateTime generatedAt;

  LeaderboardAnalytics({
    required this.leaderboardId,
    required this.period,
    required this.totalEntries,
    required this.participationRate,
    required this.tierDistribution,
    required this.scoreDistribution,
    required this.averageRankChange,
    required this.newParticipants,
    required this.returningParticipants,
    required this.categoryAverages,
    required this.generatedAt,
  });

  /// Get most common tier
  UserTier get mostCommonTier {
    if (tierDistribution.isEmpty) return UserTier.bronze;
    
    return tierDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get competition level (0-1)
  double get competitionLevel {
    // Higher when scores are closer together
    if (scoreDistribution.isEmpty) return 0.0;
    
    final scores = scoreDistribution.keys.toList()..sort();
    if (scores.length < 2) return 0.0;
    
    final range = scores.last - scores.first;
    final avgGap = range / scores.length;
    
    // Normalize to 0-1 scale (smaller gaps = higher competition)
    return (1000 - avgGap).clamp(0, 1000) / 1000;
  }

  factory LeaderboardAnalytics.fromJson(Map<String, dynamic> json) => 
      _$LeaderboardAnalyticsFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardAnalyticsToJson(this);
}
