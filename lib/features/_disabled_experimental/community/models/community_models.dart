
/// Anonymous user profile for community interactions
class AnonymousProfile {
  final String anonymousId;
  final String displayName;
  final String avatar;
  final int experienceLevel; // 1-5 (beginner to expert)
  final List<String> interests;
  final Map<String, double> trustScore;
  final DateTime joinDate;
  final bool isExpertVerified;
  final String? profession; // For verified experts only
  final List<String> specialties; // For experts
  final int helpfulVotes;
  final int totalPosts;

  const AnonymousProfile({
    required this.anonymousId,
    required this.displayName,
    required this.avatar,
    required this.experienceLevel,
    required this.interests,
    required this.trustScore,
    required this.joinDate,
    this.isExpertVerified = false,
    this.profession,
    this.specialties = const [],
    this.helpfulVotes = 0,
    this.totalPosts = 0,
  });

  factory AnonymousProfile.fromJson(Map<String, dynamic> json) {
    return AnonymousProfile(
      anonymousId: json['anonymous_id'] as String,
      displayName: json['display_name'] as String,
      avatar: json['avatar'] as String,
      experienceLevel: json['experience_level'] as int,
      interests: List<String>.from(json['interests'] as List),
      trustScore: Map<String, double>.from(json['trust_score'] as Map),
      joinDate: DateTime.parse(json['join_date'] as String),
      isExpertVerified: json['is_expert_verified'] as bool? ?? false,
      profession: json['profession'] as String?,
      specialties: List<String>.from(json['specialties'] as List? ?? []),
      helpfulVotes: json['helpful_votes'] as int? ?? 0,
      totalPosts: json['total_posts'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anonymous_id': anonymousId,
      'display_name': displayName,
      'avatar': avatar,
      'experience_level': experienceLevel,
      'interests': interests,
      'trust_score': trustScore,
      'join_date': joinDate.toIso8601String(),
      'is_expert_verified': isExpertVerified,
      'profession': profession,
      'specialties': specialties,
      'helpful_votes': helpfulVotes,
      'total_posts': totalPosts,
    };
  }

  double get overallTrustScore {
    if (trustScore.isEmpty) return 0.5;
    return trustScore.values.reduce((a, b) => a + b) / trustScore.length;
  }

  String get trustLevel {
    final score = overallTrustScore;
    if (score >= 0.9) return 'Trusted Helper';
    if (score >= 0.8) return 'Reliable Member';
    if (score >= 0.6) return 'Contributing Member';
    if (score >= 0.4) return 'New Member';
    return 'Learning Member';
  }
}

/// Community discussion group
class CommunityGroup {
  final String groupId;
  final String name;
  final String description;
  final String category;
  final List<String> tags;
  final int memberCount;
  final bool isPrivate;
  final bool requiresApproval;
  final List<String> moderatorIds;
  final DateTime createdAt;
  final Map<String, dynamic> settings;

  const CommunityGroup({
    required this.groupId,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
    required this.memberCount,
    required this.isPrivate,
    required this.requiresApproval,
    required this.moderatorIds,
    required this.createdAt,
    required this.settings,
  });

  factory CommunityGroup.fromJson(Map<String, dynamic> json) {
    return CommunityGroup(
      groupId: json['group_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] as List),
      memberCount: json['member_count'] as int,
      isPrivate: json['is_private'] as bool,
      requiresApproval: json['requires_approval'] as bool,
      moderatorIds: List<String>.from(json['moderator_ids'] as List),
      createdAt: DateTime.parse(json['created_at'] as String),
      settings: Map<String, dynamic>.from(json['settings'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'name': name,
      'description': description,
      'category': category,
      'tags': tags,
      'member_count': memberCount,
      'is_private': isPrivate,
      'requires_approval': requiresApproval,
      'moderator_ids': moderatorIds,
      'created_at': createdAt.toIso8601String(),
      'settings': settings,
    };
  }
}

/// Community post/discussion
class CommunityPost {
  final String postId;
  final String authorId;
  final String groupId;
  final String title;
  final String content;
  final PostType type;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int upvotes;
  final int downvotes;
  final int replyCount;
  final bool isAnonymous;
  final bool isModerated;
  final bool isHelpful;
  final List<String> attachments;
  final Map<String, dynamic> metadata;

  const CommunityPost({
    required this.postId,
    required this.authorId,
    required this.groupId,
    required this.title,
    required this.content,
    required this.type,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.replyCount = 0,
    this.isAnonymous = true,
    this.isModerated = false,
    this.isHelpful = false,
    this.attachments = const [],
    this.metadata = const {},
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      postId: json['post_id'] as String,
      authorId: json['author_id'] as String,
      groupId: json['group_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: PostType.values[json['type'] as int],
      tags: List<String>.from(json['tags'] as List),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      replyCount: json['reply_count'] as int? ?? 0,
      isAnonymous: json['is_anonymous'] as bool? ?? true,
      isModerated: json['is_moderated'] as bool? ?? false,
      isHelpful: json['is_helpful'] as bool? ?? false,
      attachments: List<String>.from(json['attachments'] as List? ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'author_id': authorId,
      'group_id': groupId,
      'title': title,
      'content': content,
      'type': type.index,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'upvotes': upvotes,
      'downvotes': downvotes,
      'reply_count': replyCount,
      'is_anonymous': isAnonymous,
      'is_moderated': isModerated,

      'is_helpful': isHelpful,
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  double get helpfulnessScore {
    final total = upvotes + downvotes;
    if (total == 0) return 0.5;
    return upvotes / total;
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Reply to a community post
class CommunityReply {
  final String replyId;
  final String postId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int upvotes;
  final int downvotes;
  final bool isAnonymous;
  final bool isModerated;
  final bool isExpertReply;
  final String? parentReplyId; // For nested replies

  const CommunityReply({
    required this.replyId,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.isAnonymous = true,
    this.isModerated = false,
    this.isExpertReply = false,
    this.parentReplyId,
  });

  factory CommunityReply.fromJson(Map<String, dynamic> json) {
    return CommunityReply(
      replyId: json['reply_id'] as String,
      postId: json['post_id'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      isAnonymous: json['is_anonymous'] as bool? ?? true,
      isModerated: json['is_moderated'] as bool? ?? false,
      isExpertReply: json['is_expert_reply'] as bool? ?? false,
      parentReplyId: json['parent_reply_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reply_id': replyId,
      'post_id': postId,
      'author_id': authorId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'upvotes': upvotes,
      'downvotes': downvotes,
      'is_anonymous': isAnonymous,
      'is_moderated': isModerated,
      'is_expert_reply': isExpertReply,
      'parent_reply_id': parentReplyId,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Expert verification and credentials
class ExpertCredentials {
  final String expertId;
  final String profession;
  final List<String> certifications;
  final List<String> specialties;
  final String institution;
  final int yearsOfExperience;
  final bool isVerified;
  final DateTime verificationDate;
  final String verificationLevel; // basic, advanced, premium

  const ExpertCredentials({
    required this.expertId,
    required this.profession,
    required this.certifications,
    required this.specialties,
    required this.institution,
    required this.yearsOfExperience,
    required this.isVerified,
    required this.verificationDate,
    required this.verificationLevel,
  });

  factory ExpertCredentials.fromJson(Map<String, dynamic> json) {
    return ExpertCredentials(
      expertId: json['expert_id'] as String,
      profession: json['profession'] as String,
      certifications: List<String>.from(json['certifications'] as List),
      specialties: List<String>.from(json['specialties'] as List),
      institution: json['institution'] as String,
      yearsOfExperience: json['years_of_experience'] as int,
      isVerified: json['is_verified'] as bool,
      verificationDate: DateTime.parse(json['verification_date'] as String),
      verificationLevel: json['verification_level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expert_id': expertId,
      'profession': profession,
      'certifications': certifications,
      'specialties': specialties,
      'institution': institution,
      'years_of_experience': yearsOfExperience,
      'is_verified': isVerified,
      'verification_date': verificationDate.toIso8601String(),
      'verification_level': verificationLevel,
    };
  }
}

/// Moderation action/report
class ModerationAction {
  final String actionId;
  final String targetType; // post, reply, user
  final String targetId;
  final String moderatorId;
  final ActionType actionType;
  final String reason;
  final String? details;
  final DateTime createdAt;
  final bool isResolved;

  const ModerationAction({
    required this.actionId,
    required this.targetType,
    required this.targetId,
    required this.moderatorId,
    required this.actionType,
    required this.reason,
    this.details,
    required this.createdAt,
    this.isResolved = false,
  });

  factory ModerationAction.fromJson(Map<String, dynamic> json) {
    return ModerationAction(
      actionId: json['action_id'] as String,
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as String,
      moderatorId: json['moderator_id'] as String,
      actionType: ActionType.values[json['action_type'] as int],
      reason: json['reason'] as String,
      details: json['details'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isResolved: json['is_resolved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action_id': actionId,
      'target_type': targetType,
      'target_id': targetId,
      'moderator_id': moderatorId,
      'action_type': actionType.index,
      'reason': reason,
      'details': details,
      'created_at': createdAt.toIso8601String(),
      'is_resolved': isResolved,
    };
  }
}

/// Community achievement/badge
class CommunityAchievement {
  final String achievementId;
  final String name;
  final String description;
  final String icon;
  final String category;
  final int pointsRequired;
  final bool isRare;
  final DateTime? unlockedAt;

  const CommunityAchievement({
    required this.achievementId,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.pointsRequired,
    this.isRare = false,
    this.unlockedAt,
  });

  factory CommunityAchievement.fromJson(Map<String, dynamic> json) {
    return CommunityAchievement(
      achievementId: json['achievement_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: json['category'] as String,
      pointsRequired: json['points_required'] as int,
      isRare: json['is_rare'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null ? DateTime.parse(json['unlocked_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievement_id': achievementId,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category,
      'points_required': pointsRequired,
      'is_rare': isRare,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }

  bool get isUnlocked => unlockedAt != null;
}

/// Enums for community features
enum PostType {
  question,
  discussion,
  experience,
  support,
  tip,
  study,
}

enum ActionType {
  warning,
  hide,
  remove,
  ban,
  promote,
  feature,
}

/// Content safety and filtering
class ContentFilter {
  final List<String> bannedWords;
  final List<String> flaggedPhrases;
  final double toxicityThreshold;
  final bool enableAIModeration;

  const ContentFilter({
    required this.bannedWords,
    required this.flaggedPhrases,
    required this.toxicityThreshold,
    required this.enableAIModeration,
  });

  bool isContentSafe(String content) {
    final lowerContent = content.toLowerCase();
    
    // Check for banned words
    for (final word in bannedWords) {
      if (lowerContent.contains(word.toLowerCase())) {
        return false;
      }
    }
    
    // Check for flagged phrases
    for (final phrase in flaggedPhrases) {
      if (lowerContent.contains(phrase.toLowerCase())) {
        return false;
      }
    }
    
    return true;
  }

  double calculateToxicityScore(String content) {
    // Simplified toxicity calculation
    // In production, this would use ML models
    int toxicityIndicators = 0;
    final words = content.toLowerCase().split(' ');
    
    for (final word in words) {
      if (bannedWords.contains(word)) {
        toxicityIndicators += 3;
      }
    }
    
    for (final phrase in flaggedPhrases) {
      if (content.toLowerCase().contains(phrase)) {
        toxicityIndicators += 2;
      }
    }
    
    return (toxicityIndicators / words.length).clamp(0.0, 1.0);
  }
}

/// Community engagement metrics
class CommunityMetrics {
  final int totalMembers;
  final int activeMembers;
  final int dailyPosts;
  final int weeklyPosts;
  final int monthlyPosts;
  final double averageResponseTime;
  final double helpfulnessRating;
  final Map<String, int> topicDistribution;

  const CommunityMetrics({
    required this.totalMembers,
    required this.activeMembers,
    required this.dailyPosts,
    required this.weeklyPosts,
    required this.monthlyPosts,
    required this.averageResponseTime,
    required this.helpfulnessRating,
    required this.topicDistribution,
  });

  double get engagementRate {
    if (totalMembers == 0) return 0.0;
    return activeMembers / totalMembers;
  }

  double get postsPerActiveMember {
    if (activeMembers == 0) return 0.0;
    return monthlyPosts / activeMembers;
  }
}
