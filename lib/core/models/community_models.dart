import 'package:json_annotation/json_annotation.dart';

part 'community_models.g.dart';

/// Community user profile
@JsonSerializable()
class CommunityProfile {
  final String id;
  final String userId;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final DateTime joinDate;
  final int reputationScore;
  final List<String> badges;
  final Map<String, dynamic> preferences;

  const CommunityProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    required this.joinDate,
    this.reputationScore = 0,
    this.badges = const [],
    this.preferences = const {},
  });

  factory CommunityProfile.fromJson(Map<String, dynamic> json) =>
      _$CommunityProfileFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityProfileToJson(this);
}

/// Symptom story shared by users
@JsonSerializable()
class SymptomStory {
  final String id;
  final String userId;
  final String title;
  final String content;
  final List<String> symptoms;
  final String category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likes;
  final int comments;
  final bool isAnonymous;
  final List<String> tags;
  final Map<String, dynamic> reactions;

  const SymptomStory({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.symptoms,
    required this.category,
    required this.createdAt,
    this.updatedAt,
    this.likes = 0,
    this.comments = 0,
    this.isAnonymous = false,
    this.tags = const [],
    this.reactions = const {},
  });

  factory SymptomStory.fromJson(Map<String, dynamic> json) =>
      _$SymptomStoryFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomStoryToJson(this);
}

/// Community achievements system
@JsonSerializable()
class CommunityAchievement {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String category;
  final int pointsRequired;
  final String rarity;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final Map<String, dynamic> criteria;

  const CommunityAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.category,
    required this.pointsRequired,
    this.rarity = 'common',
    this.isUnlocked = false,
    this.unlockedAt,
    this.criteria = const {},
  });

  factory CommunityAchievement.fromJson(Map<String, dynamic> json) =>
      _$CommunityAchievementFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityAchievementToJson(this);
}

/// Leaderboard entry
@JsonSerializable()
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int points;
  final int rank;
  final List<String> badges;
  final Map<String, dynamic> stats;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.points,
    required this.rank,
    this.badges = const [],
    this.stats = const {},
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);
}

/// Cycle buddy system
@JsonSerializable()
class CycleBuddy {
  final String id;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int cycleDayDifference;
  final double compatibilityScore;
  final List<String> commonSymptoms;
  final DateTime? lastActive;
  final String status;

  const CycleBuddy({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.cycleDayDifference,
    required this.compatibilityScore,
    this.commonSymptoms = const [],
    this.lastActive,
    this.status = 'active',
  });

  factory CycleBuddy.fromJson(Map<String, dynamic> json) =>
      _$CycleBuddyFromJson(json);

  Map<String, dynamic> toJson() => _$CycleBuddyToJson(this);
}

/// Buddy request
@JsonSerializable()
class BuddyRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String message;
  final DateTime createdAt;
  final String status;
  final DateTime? respondedAt;

  const BuddyRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.message,
    required this.createdAt,
    this.status = 'pending',
    this.respondedAt,
  });

  factory BuddyRequest.fromJson(Map<String, dynamic> json) =>
      _$BuddyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BuddyRequestToJson(this);
}

// ExpertQuestion and ExpertAnswer models have been moved to separate dedicated files
// for better organization and to avoid conflicts


/// Question status enum
enum QuestionStatus {
  open,
  answered,
  closed,
  featured
}

/// Discussion post
@JsonSerializable()
class DiscussionPost {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likes;
  final int replies;
  final bool isPinned;
  final bool isLocked;
  final List<String> tags;
  final Map<String, dynamic> reactions;
  final int participantCount;
  final bool hasJoined;
  final int likeCount;
  final bool hasLiked;

  const DiscussionPost({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.updatedAt,
    this.likes = 0,
    this.replies = 0,
    this.isPinned = false,
    this.isLocked = false,
    this.tags = const [],
    this.reactions = const {},
    this.participantCount = 0,
    this.hasJoined = false,
    this.likeCount = 0,
    this.hasLiked = false,
  });

  factory DiscussionPost.fromJson(Map<String, dynamic> json) =>
      _$DiscussionPostFromJson(json);

  Map<String, dynamic> toJson() => _$DiscussionPostToJson(this);
  
  /// Create a copy with updated values
  DiscussionPost copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likes,
    int? replies,
    bool? isPinned,
    bool? isLocked,
    List<String>? tags,
    Map<String, dynamic>? reactions,
    int? participantCount,
    bool? hasJoined,
    int? likeCount,
    bool? hasLiked,
  }) {
    return DiscussionPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      replies: replies ?? this.replies,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      tags: tags ?? this.tags,
      reactions: reactions ?? this.reactions,
      participantCount: participantCount ?? this.participantCount,
      hasJoined: hasJoined ?? this.hasJoined,
      likeCount: likeCount ?? this.likeCount,
      hasLiked: hasLiked ?? this.hasLiked,
    );
  }
}

/// Community statistics
@JsonSerializable()
class CommunityStats {
  final int totalMembers;
  final int activeMembers;
  final int totalPosts;
  final int totalQuestions;
  final int expertAnswers;
  final int storiesShared;
  final Map<String, int> categoryCounts;
  final DateTime lastUpdated;

  const CommunityStats({
    required this.totalMembers,
    required this.activeMembers,
    required this.totalPosts,
    required this.totalQuestions,
    required this.expertAnswers,
    required this.storiesShared,
    required this.categoryCounts,
    required this.lastUpdated,
  });

  factory CommunityStats.fromJson(Map<String, dynamic> json) =>
      _$CommunityStatsFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityStatsToJson(this);
  
  /// Helper method to increment discussion count
  void incrementDiscussions() {
    // This would be implemented to update stats
  }
}

/// Discussion model (alias for DiscussionPost for compatibility)
typedef Discussion = DiscussionPost;

/// Expert model for expert Q&A
@JsonSerializable()
class Expert {
  final String id;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String specialization;
  final List<String> qualifications;
  final double rating;
  final int totalAnswers;
  final bool isVerified;
  final String bio;
  final DateTime joinDate;

  const Expert({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.specialization,
    this.qualifications = const [],
    this.rating = 0.0,
    this.totalAnswers = 0,
    this.isVerified = false,
    this.bio = '',
    required this.joinDate,
  });

  factory Expert.fromJson(Map<String, dynamic> json) =>
      _$ExpertFromJson(json);

  Map<String, dynamic> toJson() => _$ExpertToJson(this);
}

/// Expert Question model
@JsonSerializable()
class ExpertQuestion {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String category;
  final QuestionStatus status;
  final DateTime createdAt;
  final String? preferredExpertId;
  final List<ExpertAnswer> answers;
  final int upvotes;
  final bool isBookmarked;
  final List<String> tags;
  
  const ExpertQuestion({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    this.status = QuestionStatus.open,
    required this.createdAt,
    this.preferredExpertId,
    this.answers = const [],
    this.upvotes = 0,
    this.isBookmarked = false,
    this.tags = const [],
  });

  factory ExpertQuestion.fromJson(Map<String, dynamic> json) =>
      _$ExpertQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$ExpertQuestionToJson(this);

  /// Create a copy with updated values
  ExpertQuestion copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? category,
    QuestionStatus? status,
    DateTime? createdAt,
    String? preferredExpertId,
    List<ExpertAnswer>? answers,
    int? upvotes,
    bool? isBookmarked,
    List<String>? tags,
    int? answerCount,
  }) {
    return ExpertQuestion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      preferredExpertId: preferredExpertId ?? this.preferredExpertId,
      answers: answers ?? this.answers,
      upvotes: upvotes ?? this.upvotes,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      tags: tags ?? this.tags,
    );
  }
  
  int get answerCount => answers.length;
}

/// Expert Answer model
@JsonSerializable()
class ExpertAnswer {
  final String id;
  final String questionId;
  final String expertId;
  final String expertName;
  final String content;
  final DateTime createdAt;
  final int upvotes;
  final bool isVerified;
  final List<String> attachments;
  
  const ExpertAnswer({
    required this.id,
    required this.questionId,
    required this.expertId,
    required this.expertName,
    required this.content,
    required this.createdAt,
    this.upvotes = 0,
    this.isVerified = false,
    this.attachments = const [],
  });

  factory ExpertAnswer.fromJson(Map<String, dynamic> json) =>
      _$ExpertAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$ExpertAnswerToJson(this);
}
