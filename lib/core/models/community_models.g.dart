// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityProfile _$CommunityProfileFromJson(Map<String, dynamic> json) =>
    CommunityProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      joinDate: DateTime.parse(json['joinDate'] as String),
      reputationScore: json['reputationScore'] as int? ?? 0,
      badges: (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$CommunityProfileToJson(CommunityProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'displayName': instance.displayName,
      'bio': instance.bio,
      'avatarUrl': instance.avatarUrl,
      'joinDate': instance.joinDate.toIso8601String(),
      'reputationScore': instance.reputationScore,
      'badges': instance.badges,
      'preferences': instance.preferences,
    };

SymptomStory _$SymptomStoryFromJson(Map<String, dynamic> json) =>
    SymptomStory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      symptoms: (json['symptoms'] as List<dynamic>).map((e) => e as String).toList(),
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      reactions: json['reactions'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SymptomStoryToJson(SymptomStory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'content': instance.content,
      'symptoms': instance.symptoms,
      'category': instance.category,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'likes': instance.likes,
      'comments': instance.comments,
      'isAnonymous': instance.isAnonymous,
      'tags': instance.tags,
      'reactions': instance.reactions,
    };

CommunityAchievement _$CommunityAchievementFromJson(Map<String, dynamic> json) =>
    CommunityAchievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      category: json['category'] as String,
      pointsRequired: json['pointsRequired'] as int,
      rarity: json['rarity'] as String? ?? 'common',
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] == null ? null : DateTime.parse(json['unlockedAt'] as String),
      criteria: json['criteria'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$CommunityAchievementToJson(CommunityAchievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconName': instance.iconName,
      'category': instance.category,
      'pointsRequired': instance.pointsRequired,
      'rarity': instance.rarity,
      'isUnlocked': instance.isUnlocked,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
      'criteria': instance.criteria,
    };

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) =>
    LeaderboardEntry(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      points: json['points'] as int,
      rank: json['rank'] as int,
      badges: (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      stats: json['stats'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$LeaderboardEntryToJson(LeaderboardEntry instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'points': instance.points,
      'rank': instance.rank,
      'badges': instance.badges,
      'stats': instance.stats,
    };

CycleBuddy _$CycleBuddyFromJson(Map<String, dynamic> json) =>
    CycleBuddy(
      id: json['id'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      cycleDayDifference: json['cycleDayDifference'] as int,
      compatibilityScore: (json['compatibilityScore'] as num).toDouble(),
      commonSymptoms: (json['commonSymptoms'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      lastActive: json['lastActive'] == null ? null : DateTime.parse(json['lastActive'] as String),
      status: json['status'] as String? ?? 'active',
    );

Map<String, dynamic> _$CycleBuddyToJson(CycleBuddy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'cycleDayDifference': instance.cycleDayDifference,
      'compatibilityScore': instance.compatibilityScore,
      'commonSymptoms': instance.commonSymptoms,
      'lastActive': instance.lastActive?.toIso8601String(),
      'status': instance.status,
    };

BuddyRequest _$BuddyRequestFromJson(Map<String, dynamic> json) =>
    BuddyRequest(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String? ?? 'pending',
      respondedAt: json['respondedAt'] == null ? null : DateTime.parse(json['respondedAt'] as String),
    );

Map<String, dynamic> _$BuddyRequestToJson(BuddyRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fromUserId': instance.fromUserId,
      'toUserId': instance.toUserId,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': instance.status,
      'respondedAt': instance.respondedAt?.toIso8601String(),
    };

ExpertQuestion _$ExpertQuestionFromJson(Map<String, dynamic> json) =>
    ExpertQuestion(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      status: $enumDecodeNullable(_$QuestionStatusEnumMap, json['status']) ?? QuestionStatus.open,
      createdAt: DateTime.parse(json['createdAt'] as String),
      preferredExpertId: json['preferredExpertId'] as String?,
      answers: (json['answers'] as List<dynamic>?)?.map((e) => ExpertAnswer.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      upvotes: json['upvotes'] as int? ?? 0,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );

Map<String, dynamic> _$ExpertQuestionToJson(ExpertQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'status': _$QuestionStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'preferredExpertId': instance.preferredExpertId,
      'answers': instance.answers.map((e) => e.toJson()).toList(),
      'upvotes': instance.upvotes,
      'isBookmarked': instance.isBookmarked,
      'tags': instance.tags,
    };

const _$QuestionStatusEnumMap = {
  QuestionStatus.open: 'open',
  QuestionStatus.answered: 'answered',
  QuestionStatus.closed: 'closed',
  QuestionStatus.featured: 'featured',
};

ExpertAnswer _$ExpertAnswerFromJson(Map<String, dynamic> json) =>
    ExpertAnswer(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      expertId: json['expertId'] as String,
      expertName: json['expertName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      upvotes: json['upvotes'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      attachments: (json['attachments'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );

Map<String, dynamic> _$ExpertAnswerToJson(ExpertAnswer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'questionId': instance.questionId,
      'expertId': instance.expertId,
      'expertName': instance.expertName,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'upvotes': instance.upvotes,
      'isVerified': instance.isVerified,
      'attachments': instance.attachments,
    };

DiscussionPost _$DiscussionPostFromJson(Map<String, dynamic> json) =>
    DiscussionPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
      likes: json['likes'] as int? ?? 0,
      replies: json['replies'] as int? ?? 0,
      isPinned: json['isPinned'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      reactions: json['reactions'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DiscussionPostToJson(DiscussionPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'likes': instance.likes,
      'replies': instance.replies,
      'isPinned': instance.isPinned,
      'isLocked': instance.isLocked,
      'tags': instance.tags,
      'reactions': instance.reactions,
    };

CommunityStats _$CommunityStatsFromJson(Map<String, dynamic> json) =>
    CommunityStats(
      totalMembers: json['totalMembers'] as int,
      activeMembers: json['activeMembers'] as int,
      totalPosts: json['totalPosts'] as int,
      totalQuestions: json['totalQuestions'] as int,
      expertAnswers: json['expertAnswers'] as int,
      storiesShared: json['storiesShared'] as int,
      categoryCounts: Map<String, int>.from(json['categoryCounts'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$CommunityStatsToJson(CommunityStats instance) =>
    <String, dynamic>{
      'totalMembers': instance.totalMembers,
      'activeMembers': instance.activeMembers,
      'totalPosts': instance.totalPosts,
      'totalQuestions': instance.totalQuestions,
      'expertAnswers': instance.expertAnswers,
      'storiesShared': instance.storiesShared,
      'categoryCounts': instance.categoryCounts,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

T? $enumDecodeNullable<T>(Map<T, Object> enumValues, Object? source) {
  if (source == null) {
    return null;
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => throw ArgumentError(
        '`$source` is not one of the supported values: ${enumValues.values.join(', ')}'
      ))
      .key;
}
