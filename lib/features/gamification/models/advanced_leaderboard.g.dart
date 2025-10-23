// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_leaderboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdvancedLeaderboard _$AdvancedLeaderboardFromJson(Map<String, dynamic> json) =>
    AdvancedLeaderboard(
      leaderboardId: json['leaderboardId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$LeaderboardTypeEnumMap, json['type']),
      period: $enumDecode(_$LeaderboardPeriodEnumMap, json['period']),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      userRank: (json['userRank'] as num?)?.toInt(),
      metadata: LeaderboardMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      isActive: json['isActive'] as bool? ?? true,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$AdvancedLeaderboardToJson(
  AdvancedLeaderboard instance,
) => <String, dynamic>{
  'leaderboardId': instance.leaderboardId,
  'name': instance.name,
  'description': instance.description,
  'type': _$LeaderboardTypeEnumMap[instance.type]!,
  'period': _$LeaderboardPeriodEnumMap[instance.period]!,
  'entries': instance.entries,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'userRank': instance.userRank,
  'metadata': instance.metadata,
  'isActive': instance.isActive,
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
};

const _$LeaderboardTypeEnumMap = {
  LeaderboardType.points: 'points',
  LeaderboardType.achievements: 'achievements',
  LeaderboardType.streaks: 'streaks',
  LeaderboardType.challenges: 'challenges',
  LeaderboardType.consistency: 'consistency',
  LeaderboardType.social: 'social',
  LeaderboardType.learning: 'learning',
  LeaderboardType.wellness: 'wellness',
};

const _$LeaderboardPeriodEnumMap = {
  LeaderboardPeriod.daily: 'daily',
  LeaderboardPeriod.weekly: 'weekly',
  LeaderboardPeriod.monthly: 'monthly',
  LeaderboardPeriod.quarterly: 'quarterly',
  LeaderboardPeriod.yearly: 'yearly',
  LeaderboardPeriod.allTime: 'allTime',
  LeaderboardPeriod.custom: 'custom',
};

LeaderboardEntry _$LeaderboardEntryFromJson(
  Map<String, dynamic> json,
) => LeaderboardEntry(
  userId: json['userId'] as String,
  username: json['username'] as String,
  displayName: json['displayName'] as String?,
  rank: (json['rank'] as num).toInt(),
  previousRank: (json['previousRank'] as num?)?.toInt(),
  score: (json['score'] as num).toInt(),
  categoryScores:
      (json['categoryScores'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  avatarUrl: json['avatarUrl'] as String?,
  tier: $enumDecodeNullable(_$UserTierEnumMap, json['tier']) ?? UserTier.bronze,
  level: (json['level'] as num?)?.toInt() ?? 1,
  isCurrentUser: json['isCurrentUser'] as bool? ?? false,
  isFriend: json['isFriend'] as bool? ?? false,
  lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
  badges:
      (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  title: json['title'] as String?,
  stats: LeaderboardEntryStats.fromJson(json['stats'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LeaderboardEntryToJson(LeaderboardEntry instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'displayName': instance.displayName,
      'rank': instance.rank,
      'previousRank': instance.previousRank,
      'score': instance.score,
      'categoryScores': instance.categoryScores,
      'avatarUrl': instance.avatarUrl,
      'tier': _$UserTierEnumMap[instance.tier]!,
      'level': instance.level,
      'isCurrentUser': instance.isCurrentUser,
      'isFriend': instance.isFriend,
      'lastActiveAt': instance.lastActiveAt.toIso8601String(),
      'badges': instance.badges,
      'title': instance.title,
      'stats': instance.stats,
    };

const _$UserTierEnumMap = {
  UserTier.bronze: 'bronze',
  UserTier.silver: 'silver',
  UserTier.gold: 'gold',
  UserTier.platinum: 'platinum',
  UserTier.diamond: 'diamond',
};

LeaderboardMetadata _$LeaderboardMetadataFromJson(Map<String, dynamic> json) =>
    LeaderboardMetadata(
      totalParticipants: (json['totalParticipants'] as num).toInt(),
      averageScore: (json['averageScore'] as num).toDouble(),
      highestScore: (json['highestScore'] as num).toInt(),
      lowestScore: (json['lowestScore'] as num).toInt(),
      seasonName: json['seasonName'] as String?,
      rewards:
          (json['rewards'] as List<dynamic>?)
              ?.map(
                (e) => LeaderboardReward.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      customFields: json['customFields'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$LeaderboardMetadataToJson(
  LeaderboardMetadata instance,
) => <String, dynamic>{
  'totalParticipants': instance.totalParticipants,
  'averageScore': instance.averageScore,
  'highestScore': instance.highestScore,
  'lowestScore': instance.lowestScore,
  'seasonName': instance.seasonName,
  'rewards': instance.rewards,
  'customFields': instance.customFields,
  'createdAt': instance.createdAt.toIso8601String(),
};

LeaderboardReward _$LeaderboardRewardFromJson(Map<String, dynamic> json) =>
    LeaderboardReward(
      rewardId: json['rewardId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      rankRange: RankRange.fromJson(json['rankRange'] as Map<String, dynamic>),
      type: $enumDecode(_$RewardTypeEnumMap, json['type']),
      pointsReward: (json['pointsReward'] as num?)?.toInt() ?? 0,
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 0,
      badgeId: json['badgeId'] as String?,
      itemId: json['itemId'] as String?,
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$LeaderboardRewardToJson(LeaderboardReward instance) =>
    <String, dynamic>{
      'rewardId': instance.rewardId,
      'title': instance.title,
      'description': instance.description,
      'rankRange': instance.rankRange,
      'type': _$RewardTypeEnumMap[instance.type]!,
      'pointsReward': instance.pointsReward,
      'xpReward': instance.xpReward,
      'badgeId': instance.badgeId,
      'itemId': instance.itemId,
      'icon': instance.icon,
    };

const _$RewardTypeEnumMap = {
  RewardType.badge: 'badge',
  RewardType.points: 'points',
  RewardType.title: 'title',
  RewardType.item: 'item',
  RewardType.feature: 'feature',
};

RankRange _$RankRangeFromJson(Map<String, dynamic> json) => RankRange(
  minRank: (json['minRank'] as num).toInt(),
  maxRank: (json['maxRank'] as num).toInt(),
);

Map<String, dynamic> _$RankRangeToJson(RankRange instance) => <String, dynamic>{
  'minRank': instance.minRank,
  'maxRank': instance.maxRank,
};

LeaderboardEntryStats _$LeaderboardEntryStatsFromJson(
  Map<String, dynamic> json,
) => LeaderboardEntryStats(
  totalActiveDays: (json['totalActiveDays'] as num?)?.toInt() ?? 0,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
  averageDailyScore: (json['averageDailyScore'] as num?)?.toDouble() ?? 0.0,
  achievementsEarned: (json['achievementsEarned'] as num?)?.toInt() ?? 0,
  challengesCompleted: (json['challengesCompleted'] as num?)?.toInt() ?? 0,
  consistencyScore: (json['consistencyScore'] as num?)?.toDouble() ?? 0.0,
  categoryBreakdown:
      (json['categoryBreakdown'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$LeaderboardEntryStatsToJson(
  LeaderboardEntryStats instance,
) => <String, dynamic>{
  'totalActiveDays': instance.totalActiveDays,
  'currentStreak': instance.currentStreak,
  'longestStreak': instance.longestStreak,
  'averageDailyScore': instance.averageDailyScore,
  'achievementsEarned': instance.achievementsEarned,
  'challengesCompleted': instance.challengesCompleted,
  'consistencyScore': instance.consistencyScore,
  'categoryBreakdown': instance.categoryBreakdown,
};

LeaderboardAnalytics _$LeaderboardAnalyticsFromJson(
  Map<String, dynamic> json,
) => LeaderboardAnalytics(
  leaderboardId: json['leaderboardId'] as String,
  period: $enumDecode(_$LeaderboardPeriodEnumMap, json['period']),
  totalEntries: (json['totalEntries'] as num).toInt(),
  participationRate: (json['participationRate'] as num).toDouble(),
  tierDistribution: (json['tierDistribution'] as Map<String, dynamic>).map(
    (k, e) => MapEntry($enumDecode(_$UserTierEnumMap, k), (e as num).toInt()),
  ),
  scoreDistribution: (json['scoreDistribution'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
  ),
  averageRankChange: (json['averageRankChange'] as num).toDouble(),
  newParticipants: (json['newParticipants'] as num).toInt(),
  returningParticipants: (json['returningParticipants'] as num).toInt(),
  categoryAverages: (json['categoryAverages'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  generatedAt: DateTime.parse(json['generatedAt'] as String),
);

Map<String, dynamic> _$LeaderboardAnalyticsToJson(
  LeaderboardAnalytics instance,
) => <String, dynamic>{
  'leaderboardId': instance.leaderboardId,
  'period': _$LeaderboardPeriodEnumMap[instance.period]!,
  'totalEntries': instance.totalEntries,
  'participationRate': instance.participationRate,
  'tierDistribution': instance.tierDistribution.map(
    (k, e) => MapEntry(_$UserTierEnumMap[k]!, e),
  ),
  'scoreDistribution': instance.scoreDistribution.map(
    (k, e) => MapEntry(k.toString(), e),
  ),
  'averageRankChange': instance.averageRankChange,
  'newParticipants': instance.newParticipants,
  'returningParticipants': instance.returningParticipants,
  'categoryAverages': instance.categoryAverages,
  'generatedAt': instance.generatedAt.toIso8601String(),
};
