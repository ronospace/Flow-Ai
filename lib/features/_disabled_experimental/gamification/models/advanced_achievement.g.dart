// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdvancedAchievement _$AdvancedAchievementFromJson(Map<String, dynamic> json) =>
    AdvancedAchievement(
      achievementId: json['achievementId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: $enumDecode(_$AchievementCategoryEnumMap, json['category']),
      rarity:
          $enumDecodeNullable(_$AchievementRarityEnumMap, json['rarity']) ??
          AchievementRarity.common,
      icon: json['icon'] as String,
      pointsReward: (json['pointsReward'] as num).toInt(),
      xpReward: (json['xpReward'] as num).toInt(),
      isEarned: json['isEarned'] as bool? ?? false,
      earnedDate: json['earnedDate'] == null
          ? null
          : DateTime.parse(json['earnedDate'] as String),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      maxProgress: (json['maxProgress'] as num?)?.toDouble() ?? 1.0,
      prerequisites:
          (json['prerequisites'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tiers:
          (json['tiers'] as List<dynamic>?)
              ?.map((e) => AchievementTier.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      criteria: json['criteria'] as Map<String, dynamic>? ?? const {},
      metadata: AchievementMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      isSecret: json['isSecret'] as bool? ?? false,
      isTimeLimited: json['isTimeLimited'] as bool? ?? false,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
    );

Map<String, dynamic> _$AdvancedAchievementToJson(
  AdvancedAchievement instance,
) => <String, dynamic>{
  'achievementId': instance.achievementId,
  'title': instance.title,
  'description': instance.description,
  'category': _$AchievementCategoryEnumMap[instance.category]!,
  'rarity': _$AchievementRarityEnumMap[instance.rarity]!,
  'icon': instance.icon,
  'pointsReward': instance.pointsReward,
  'xpReward': instance.xpReward,
  'isEarned': instance.isEarned,
  'earnedDate': instance.earnedDate?.toIso8601String(),
  'progress': instance.progress,
  'maxProgress': instance.maxProgress,
  'prerequisites': instance.prerequisites,
  'tiers': instance.tiers,
  'criteria': instance.criteria,
  'metadata': instance.metadata,
  'isSecret': instance.isSecret,
  'isTimeLimited': instance.isTimeLimited,
  'expiryDate': instance.expiryDate?.toIso8601String(),
};

const _$AchievementCategoryEnumMap = {
  AchievementCategory.tracking: 'tracking',
  AchievementCategory.health: 'health',
  AchievementCategory.social: 'social',
  AchievementCategory.education: 'education',
  AchievementCategory.challenges: 'challenges',
  AchievementCategory.consistency: 'consistency',
  AchievementCategory.milestones: 'milestones',
  AchievementCategory.exploration: 'exploration',
  AchievementCategory.special: 'special',
};

const _$AchievementRarityEnumMap = {
  AchievementRarity.common: 'common',
  AchievementRarity.uncommon: 'uncommon',
  AchievementRarity.rare: 'rare',
  AchievementRarity.epic: 'epic',
  AchievementRarity.legendary: 'legendary',
};

AchievementTier _$AchievementTierFromJson(Map<String, dynamic> json) =>
    AchievementTier(
      tierId: json['tierId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      requiredProgress: (json['requiredProgress'] as num).toDouble(),
      pointsReward: (json['pointsReward'] as num).toInt(),
      xpReward: (json['xpReward'] as num).toInt(),
      badgeIcon: json['badgeIcon'] as String?,
      rewards:
          (json['rewards'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AchievementTierToJson(AchievementTier instance) =>
    <String, dynamic>{
      'tierId': instance.tierId,
      'title': instance.title,
      'description': instance.description,
      'requiredProgress': instance.requiredProgress,
      'pointsReward': instance.pointsReward,
      'xpReward': instance.xpReward,
      'badgeIcon': instance.badgeIcon,
      'rewards': instance.rewards,
    };

AchievementMetadata _$AchievementMetadataFromJson(Map<String, dynamic> json) =>
    AchievementMetadata(
      createdDate: DateTime.parse(json['createdDate'] as String),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      createdBy: json['createdBy'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      averageCompletionTime: (json['averageCompletionTime'] as num?)
          ?.toDouble(),
      totalEarnedCount: (json['totalEarnedCount'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
      localization:
          (json['localization'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      isDeprecated: json['isDeprecated'] as bool? ?? false,
      deprecationReason: json['deprecationReason'] as String?,
    );

Map<String, dynamic> _$AchievementMetadataToJson(
  AchievementMetadata instance,
) => <String, dynamic>{
  'createdDate': instance.createdDate.toIso8601String(),
  'lastUpdated': instance.lastUpdated?.toIso8601String(),
  'createdBy': instance.createdBy,
  'tags': instance.tags,
  'averageCompletionTime': instance.averageCompletionTime,
  'totalEarnedCount': instance.totalEarnedCount,
  'completionRate': instance.completionRate,
  'localization': instance.localization,
  'isDeprecated': instance.isDeprecated,
  'deprecationReason': instance.deprecationReason,
};

AchievementCollection _$AchievementCollectionFromJson(
  Map<String, dynamic> json,
) => AchievementCollection(
  collectionId: json['collectionId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  theme: json['theme'] as String,
  achievementIds: (json['achievementIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  collectionReward: json['collectionReward'] == null
      ? null
      : CollectionReward.fromJson(
          json['collectionReward'] as Map<String, dynamic>,
        ),
  isLimitedTime: json['isLimitedTime'] as bool? ?? false,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
);

Map<String, dynamic> _$AchievementCollectionToJson(
  AchievementCollection instance,
) => <String, dynamic>{
  'collectionId': instance.collectionId,
  'name': instance.name,
  'description': instance.description,
  'theme': instance.theme,
  'achievementIds': instance.achievementIds,
  'collectionReward': instance.collectionReward,
  'isLimitedTime': instance.isLimitedTime,
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
};

CollectionReward _$CollectionRewardFromJson(Map<String, dynamic> json) =>
    CollectionReward(
      rewardId: json['rewardId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$CollectionRewardTypeEnumMap, json['type']),
      pointsReward: (json['pointsReward'] as num?)?.toInt() ?? 0,
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 0,
      badgeId: json['badgeId'] as String?,
      itemId: json['itemId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$CollectionRewardToJson(CollectionReward instance) =>
    <String, dynamic>{
      'rewardId': instance.rewardId,
      'title': instance.title,
      'description': instance.description,
      'type': _$CollectionRewardTypeEnumMap[instance.type]!,
      'pointsReward': instance.pointsReward,
      'xpReward': instance.xpReward,
      'badgeId': instance.badgeId,
      'itemId': instance.itemId,
      'metadata': instance.metadata,
    };

const _$CollectionRewardTypeEnumMap = {
  CollectionRewardType.badge: 'badge',
  CollectionRewardType.title: 'title',
  CollectionRewardType.item: 'item',
  CollectionRewardType.points: 'points',
  CollectionRewardType.feature: 'feature',
};

AchievementStats _$AchievementStatsFromJson(Map<String, dynamic> json) =>
    AchievementStats(
      totalAchievements: (json['totalAchievements'] as num).toInt(),
      earnedAchievements: (json['earnedAchievements'] as num).toInt(),
      commonEarned: (json['commonEarned'] as num?)?.toInt() ?? 0,
      uncommonEarned: (json['uncommonEarned'] as num?)?.toInt() ?? 0,
      rareEarned: (json['rareEarned'] as num?)?.toInt() ?? 0,
      epicEarned: (json['epicEarned'] as num?)?.toInt() ?? 0,
      legendaryEarned: (json['legendaryEarned'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num).toDouble(),
      totalPointsFromAchievements: (json['totalPointsFromAchievements'] as num)
          .toInt(),
      totalXpFromAchievements: (json['totalXpFromAchievements'] as num).toInt(),
      lastAchievementEarned: json['lastAchievementEarned'] == null
          ? null
          : DateTime.parse(json['lastAchievementEarned'] as String),
      rarestAchievementEarned: json['rarestAchievementEarned'] as String?,
    );

Map<String, dynamic> _$AchievementStatsToJson(
  AchievementStats instance,
) => <String, dynamic>{
  'totalAchievements': instance.totalAchievements,
  'earnedAchievements': instance.earnedAchievements,
  'commonEarned': instance.commonEarned,
  'uncommonEarned': instance.uncommonEarned,
  'rareEarned': instance.rareEarned,
  'epicEarned': instance.epicEarned,
  'legendaryEarned': instance.legendaryEarned,
  'completionRate': instance.completionRate,
  'totalPointsFromAchievements': instance.totalPointsFromAchievements,
  'totalXpFromAchievements': instance.totalXpFromAchievements,
  'lastAchievementEarned': instance.lastAchievementEarned?.toIso8601String(),
  'rarestAchievementEarned': instance.rarestAchievementEarned,
};
