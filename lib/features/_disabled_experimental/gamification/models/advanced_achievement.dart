import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'advanced_achievement.g.dart';

/// Advanced Achievement Model
/// Represents complex achievements with multiple tiers, dependencies, and rewards
@JsonSerializable()
class AdvancedAchievement {
  final String achievementId;
  final String title;
  final String description;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final String icon;
  final int pointsReward;
  final int xpReward;
  final bool isEarned;
  final DateTime? earnedDate;
  final double progress;
  final double maxProgress;
  final List<String> prerequisites;
  final List<AchievementTier> tiers;
  final Map<String, dynamic> criteria;
  final AchievementMetadata metadata;
  final bool isSecret;
  final bool isTimeLimited;
  final DateTime? expiryDate;

  AdvancedAchievement({
    required this.achievementId,
    required this.title,
    required this.description,
    required this.category,
    this.rarity = AchievementRarity.common,
    required this.icon,
    required this.pointsReward,
    required this.xpReward,
    this.isEarned = false,
    this.earnedDate,
    this.progress = 0.0,
    this.maxProgress = 1.0,
    this.prerequisites = const [],
    this.tiers = const [],
    this.criteria = const {},
    required this.metadata,
    this.isSecret = false,
    this.isTimeLimited = false,
    this.expiryDate,
  });

  // Computed properties
  bool get isCompleted => progress >= maxProgress;
  double get progressPercentage => maxProgress > 0 ? (progress / maxProgress * 100).clamp(0, 100) : 0;
  bool get isExpired => isTimeLimited && expiryDate != null && DateTime.now().isAfter(expiryDate!);
  bool get canBeEarned => !isExpired && !isEarned && _prerequisitesMet();
  
  /// Get current tier based on progress
  AchievementTier? get currentTier {
    if (tiers.isEmpty) return null;
    
    for (final tier in tiers.reversed) {
      if (progress >= tier.requiredProgress) {
        return tier;
      }
    }
    return tiers.first;
  }

  /// Get next tier to unlock
  AchievementTier? get nextTier {
    if (tiers.isEmpty) return null;
    
    for (final tier in tiers) {
      if (progress < tier.requiredProgress) {
        return tier;
      }
    }
    return null;
  }

  /// Get progress to next tier
  double get progressToNextTier {
    final next = nextTier;
    if (next == null) return 0.0;
    
    final current = currentTier;
    if (current == null) return next.requiredProgress - progress;
    
    return next.requiredProgress - progress;
  }

  /// Get achievement difficulty
  AchievementDifficulty get difficulty {
    if (maxProgress >= 1000 || tiers.length >= 5) return AchievementDifficulty.legendary;
    if (maxProgress >= 100 || tiers.length >= 3) return AchievementDifficulty.epic;
    if (maxProgress >= 50 || rarity == AchievementRarity.rare) return AchievementDifficulty.hard;
    if (maxProgress >= 10 || rarity == AchievementRarity.uncommon) return AchievementDifficulty.medium;
    return AchievementDifficulty.easy;
  }

  /// Get estimated time to completion
  Duration? get estimatedTimeToComplete {
    if (metadata.averageCompletionTime != null && progress < maxProgress) {
      final remaining = maxProgress - progress;
      final rate = maxProgress / metadata.averageCompletionTime!.inHours;
      return Duration(hours: (remaining / rate).round());
    }
    return null;
  }

  /// Mark achievement as earned
  void markAsEarned(DateTime earnedDate) {
    if (!isEarned) {
      // Achievement earning logic would be handled by the service
    }
  }

  /// Update progress
  void updateProgress(double newProgress) {
    // Progress update logic would be handled by the service
  }

  bool _prerequisitesMet() {
    // In real implementation, this would check if all prerequisite achievements are earned
    return true; // Simplified for now
  }

  factory AdvancedAchievement.fromJson(Map<String, dynamic> json) => 
      _$AdvancedAchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AdvancedAchievementToJson(this);

  AdvancedAchievement copyWith({
    String? achievementId,
    String? title,
    String? description,
    AchievementCategory? category,
    AchievementRarity? rarity,
    String? icon,
    int? pointsReward,
    int? xpReward,
    bool? isEarned,
    DateTime? earnedDate,
    double? progress,
    double? maxProgress,
    List<String>? prerequisites,
    List<AchievementTier>? tiers,
    Map<String, dynamic>? criteria,
    AchievementMetadata? metadata,
    bool? isSecret,
    bool? isTimeLimited,
    DateTime? expiryDate,
  }) {
    return AdvancedAchievement(
      achievementId: achievementId ?? this.achievementId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      icon: icon ?? this.icon,
      pointsReward: pointsReward ?? this.pointsReward,
      xpReward: xpReward ?? this.xpReward,
      isEarned: isEarned ?? this.isEarned,
      earnedDate: earnedDate ?? this.earnedDate,
      progress: progress ?? this.progress,
      maxProgress: maxProgress ?? this.maxProgress,
      prerequisites: prerequisites ?? this.prerequisites,
      tiers: tiers ?? this.tiers,
      criteria: criteria ?? this.criteria,
      metadata: metadata ?? this.metadata,
      isSecret: isSecret ?? this.isSecret,
      isTimeLimited: isTimeLimited ?? this.isTimeLimited,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}

/// Achievement Categories
enum AchievementCategory {
  tracking('Tracking', 'Cycle and symptom tracking achievements', '📊'),
  health('Health', 'Health and wellness milestones', '💪'),
  social('Social', 'Community and social interaction', '👥'),
  education('Education', 'Learning and knowledge achievements', '📚'),
  challenges('Challenges', 'Challenge completion milestones', '🏆'),
  consistency('Consistency', 'Consistency and streak achievements', '🔥'),
  milestones('Milestones', 'Major milestone achievements', '🎯'),
  exploration('Exploration', 'Feature exploration and discovery', '🔍'),
  special('Special', 'Special event and seasonal achievements', '⭐');

  const AchievementCategory(this.displayName, this.description, this.icon);

  final String displayName;
  final String description;
  final String icon;

  /// Get category color
  Color get color {
    switch (this) {
      case AchievementCategory.tracking:
        return Colors.blue;
      case AchievementCategory.health:
        return Colors.green;
      case AchievementCategory.social:
        return Colors.purple;
      case AchievementCategory.education:
        return Colors.orange;
      case AchievementCategory.challenges:
        return Colors.red;
      case AchievementCategory.consistency:
        return Colors.amber;
      case AchievementCategory.milestones:
        return Colors.indigo;
      case AchievementCategory.exploration:
        return Colors.teal;
      case AchievementCategory.special:
        return Colors.pink;
    }
  }
}

/// Achievement Rarity
enum AchievementRarity {
  common('Common', 'Easy to earn achievements', 0.8, Colors.grey),
  uncommon('Uncommon', 'Moderately difficult achievements', 0.6, Colors.green),
  rare('Rare', 'Challenging achievements', 0.3, Colors.blue),
  epic('Epic', 'Very challenging achievements', 0.1, Colors.purple),
  legendary('Legendary', 'Extremely rare achievements', 0.05, Colors.orange);

  const AchievementRarity(this.displayName, this.description, this.dropRate, this.color);

  final String displayName;
  final String description;
  final double dropRate; // Approximate percentage of users who earn this
  final Color color;

  /// Get rarity multiplier for points/XP
  double get multiplier {
    switch (this) {
      case AchievementRarity.common:
        return 1.0;
      case AchievementRarity.uncommon:
        return 1.5;
      case AchievementRarity.rare:
        return 2.0;
      case AchievementRarity.epic:
        return 3.0;
      case AchievementRarity.legendary:
        return 5.0;
    }
  }
}

/// Achievement Difficulty
enum AchievementDifficulty {
  easy('Easy', 'Can be completed quickly', '⭐'),
  medium('Medium', 'Requires some effort', '⭐⭐'),
  hard('Hard', 'Challenging to complete', '⭐⭐⭐'),
  epic('Epic', 'Very challenging', '⭐⭐⭐⭐'),
  legendary('Legendary', 'Extremely difficult', '⭐⭐⭐⭐⭐');

  const AchievementDifficulty(this.displayName, this.description, this.stars);

  final String displayName;
  final String description;
  final String stars;

  /// Get difficulty color
  Color get color {
    switch (this) {
      case AchievementDifficulty.easy:
        return Colors.green;
      case AchievementDifficulty.medium:
        return Colors.yellow;
      case AchievementDifficulty.hard:
        return Colors.orange;
      case AchievementDifficulty.epic:
        return Colors.red;
      case AchievementDifficulty.legendary:
        return Colors.purple;
    }
  }
}

/// Achievement Tier
@JsonSerializable()
class AchievementTier {
  final String tierId;
  final String title;
  final String description;
  final double requiredProgress;
  final int pointsReward;
  final int xpReward;
  final String? badgeIcon;
  final List<String> rewards;

  AchievementTier({
    required this.tierId,
    required this.title,
    required this.description,
    required this.requiredProgress,
    required this.pointsReward,
    required this.xpReward,
    this.badgeIcon,
    this.rewards = const [],
  });

  /// Check if tier is unlocked
  bool isUnlocked(double currentProgress) => currentProgress >= requiredProgress;

  factory AchievementTier.fromJson(Map<String, dynamic> json) => _$AchievementTierFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementTierToJson(this);
}

/// Achievement Metadata
@JsonSerializable()
class AchievementMetadata {
  final DateTime createdDate;
  final DateTime? lastUpdated;
  final String createdBy;
  final List<String> tags;
  final double? averageCompletionTime; // in hours
  final int totalEarnedCount;
  final double completionRate; // percentage of users who completed it
  final Map<String, String> localization;
  final bool isDeprecated;
  final String? deprecationReason;

  AchievementMetadata({
    required this.createdDate,
    this.lastUpdated,
    required this.createdBy,
    this.tags = const [],
    this.averageCompletionTime,
    this.totalEarnedCount = 0,
    this.completionRate = 0.0,
    this.localization = const {},
    this.isDeprecated = false,
    this.deprecationReason,
  });

  factory AchievementMetadata.fromJson(Map<String, dynamic> json) => 
      _$AchievementMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementMetadataToJson(this);
}

/// Achievement Collection
@JsonSerializable()
class AchievementCollection {
  final String collectionId;
  final String name;
  final String description;
  final String theme;
  final List<String> achievementIds;
  final CollectionReward? collectionReward;
  final bool isLimitedTime;
  final DateTime? startDate;
  final DateTime? endDate;

  AchievementCollection({
    required this.collectionId,
    required this.name,
    required this.description,
    required this.theme,
    required this.achievementIds,
    this.collectionReward,
    this.isLimitedTime = false,
    this.startDate,
    this.endDate,
  });

  /// Check if collection is complete
  bool isComplete(List<String> earnedAchievementIds) {
    return achievementIds.every((id) => earnedAchievementIds.contains(id));
  }

  /// Get completion progress
  double getProgress(List<String> earnedAchievementIds) {
    if (achievementIds.isEmpty) return 0.0;
    
    final earned = achievementIds.where((id) => earnedAchievementIds.contains(id)).length;
    return earned / achievementIds.length;
  }

  /// Check if collection is active
  bool get isActive {
    if (!isLimitedTime) return true;
    
    final now = DateTime.now();
    return (startDate == null || now.isAfter(startDate!)) &&
           (endDate == null || now.isBefore(endDate!));
  }

  factory AchievementCollection.fromJson(Map<String, dynamic> json) => 
      _$AchievementCollectionFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementCollectionToJson(this);
}

/// Collection Reward
@JsonSerializable()
class CollectionReward {
  final String rewardId;
  final String title;
  final String description;
  final CollectionRewardType type;
  final int pointsReward;
  final int xpReward;
  final String? badgeId;
  final String? itemId;
  final Map<String, dynamic> metadata;

  CollectionReward({
    required this.rewardId,
    required this.title,
    required this.description,
    required this.type,
    this.pointsReward = 0,
    this.xpReward = 0,
    this.badgeId,
    this.itemId,
    this.metadata = const {},
  });

  factory CollectionReward.fromJson(Map<String, dynamic> json) => 
      _$CollectionRewardFromJson(json);
  Map<String, dynamic> toJson() => _$CollectionRewardToJson(this);
}

/// Collection Reward Types
enum CollectionRewardType {
  badge('Badge', 'Exclusive badge reward'),
  title('Title', 'User title/rank reward'),
  item('Item', 'Virtual item reward'),
  points('Points', 'Extra points reward'),
  feature('Feature', 'Unlock special features');

  const CollectionRewardType(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Achievement Statistics
@JsonSerializable()
class AchievementStats {
  final int totalAchievements;
  final int earnedAchievements;
  final int commonEarned;
  final int uncommonEarned;
  final int rareEarned;
  final int epicEarned;
  final int legendaryEarned;
  final double completionRate;
  final int totalPointsFromAchievements;
  final int totalXpFromAchievements;
  final DateTime? lastAchievementEarned;
  final String? rarestAchievementEarned;

  AchievementStats({
    required this.totalAchievements,
    required this.earnedAchievements,
    this.commonEarned = 0,
    this.uncommonEarned = 0,
    this.rareEarned = 0,
    this.epicEarned = 0,
    this.legendaryEarned = 0,
    required this.completionRate,
    required this.totalPointsFromAchievements,
    required this.totalXpFromAchievements,
    this.lastAchievementEarned,
    this.rarestAchievementEarned,
  });

  /// Get rarity distribution
  Map<AchievementRarity, int> get rarityDistribution {
    return {
      AchievementRarity.common: commonEarned,
      AchievementRarity.uncommon: uncommonEarned,
      AchievementRarity.rare: rareEarned,
      AchievementRarity.epic: epicEarned,
      AchievementRarity.legendary: legendaryEarned,
    };
  }

  /// Get achievement hunter level
  AchievementHunterLevel get hunterLevel {
    if (legendaryEarned >= 3) return AchievementHunterLevel.grandmaster;
    if (epicEarned >= 5) return AchievementHunterLevel.master;
    if (rareEarned >= 10) return AchievementHunterLevel.expert;
    if (uncommonEarned >= 20) return AchievementHunterLevel.veteran;
    if (earnedAchievements >= 10) return AchievementHunterLevel.seasoned;
    return AchievementHunterLevel.novice;
  }

  factory AchievementStats.fromJson(Map<String, dynamic> json) => 
      _$AchievementStatsFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementStatsToJson(this);
}

/// Achievement Hunter Level
enum AchievementHunterLevel {
  novice('Novice Hunter', '🥉'),
  seasoned('Seasoned Hunter', '🥈'),
  veteran('Veteran Hunter', '🥇'),
  expert('Expert Hunter', '🏆'),
  master('Master Hunter', '👑'),
  grandmaster('Grandmaster Hunter', '💎');

  const AchievementHunterLevel(this.displayName, this.icon);

  final String displayName;
  final String icon;
}
