import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../core/models/community_models.dart';

/// Community service managing anonymous platform and expert moderation
class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  CommunityService._internal();

  static CommunityService get instance => _instance;

  // Service state
  bool _isInitialized = false;
  AnonymousProfile? _currentProfile;
  final List<CommunityGroup> _availableGroups = [];
  final List<CommunityPost> _posts = [];
  final List<CommunityReply> _replies = [];
  final List<ExpertCredentials> _verifiedExperts = [];
  final List<CommunityAchievement> _achievements = [];
  final ContentFilter _contentFilter = const ContentFilter(
    bannedWords: [
      'spam', 'scam', 'inappropriate', 'hate', 'abuse',
      'violence', 'drug', 'suicide', 'self-harm'
    ],
    flaggedPhrases: [
      'medical advice', 'dangerous behavior', 'illegal activity',
      'personal information', 'contact details'
    ],
    toxicityThreshold: 0.3,
    enableAIModeration: true,
  );

  // Stream controllers for real-time updates
  final StreamController<List<CommunityPost>> _postsController = 
      StreamController<List<CommunityPost>>.broadcast();
  final StreamController<List<CommunityReply>> _repliesController = 
      StreamController<List<CommunityReply>>.broadcast();
  final StreamController<CommunityMetrics> _metricsController = 
      StreamController<CommunityMetrics>.broadcast();

  // Getters for streams
  Stream<List<CommunityPost>> get postsStream => _postsController.stream;
  Stream<List<CommunityReply>> get repliesStream => _repliesController.stream;
  Stream<CommunityMetrics> get metricsStream => _metricsController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('🤝 Initializing Community Service...');
    
    await _loadDefaultGroups();
    await _loadVerifiedExperts();
    await _loadAchievements();
    await _generateSampleContent();
    
    _isInitialized = true;
    debugPrint('✅ Community Service initialized');
  }

  /// Create anonymous profile for community participation
  Future<AnonymousProfile> createAnonymousProfile({
    required String displayName,
    required List<String> interests,
    int experienceLevel = 1,
  }) async {
    final anonymousId = _generateAnonymousId();
    final avatar = _generateRandomAvatar();
    
    final profile = AnonymousProfile(
      anonymousId: anonymousId,
      displayName: displayName,
      avatar: avatar,
      experienceLevel: experienceLevel,
      interests: interests,
      trustScore: {'helpfulness': 0.5, 'reliability': 0.5, 'expertise': 0.5},
      joinDate: DateTime.now(),
    );

    _currentProfile = profile;
    debugPrint('👤 Created anonymous profile: $displayName');
    
    return profile;
  }

  /// Get available community groups
  List<CommunityGroup> getAvailableGroups() {
    return List.unmodifiable(_availableGroups);
  }

  /// Join a community group
  Future<bool> joinGroup(String groupId) async {
    final group = _availableGroups.firstWhere(
      (g) => g.groupId == groupId,
      orElse: () => throw Exception('Group not found'),
    );

    if (group.requiresApproval) {
      debugPrint('⏳ Joining ${group.name} requires approval');
      // In production, this would send approval request
      return false;
    }

    debugPrint('✅ Joined group: ${group.name}');
    return true;
  }

  /// Create a new community post
  Future<CommunityPost> createPost({
    required String groupId,
    required String title,
    required String content,
    required PostType type,
    List<String> tags = const [],
  }) async {
    if (_currentProfile == null) {
      throw Exception('Must create anonymous profile first');
    }

    // Content safety check
    if (!_contentFilter.isContentSafe(content) || !_contentFilter.isContentSafe(title)) {
      throw Exception('Content violates community guidelines');
    }

    final toxicityScore = _contentFilter.calculateToxicityScore(content);
    if (toxicityScore > _contentFilter.toxicityThreshold) {
      throw Exception('Content flagged for manual review');
    }

    final postId = _generatePostId();
    final post = CommunityPost(
      postId: postId,
      authorId: _currentProfile!.anonymousId,
      groupId: groupId,
      title: title,
      content: content,
      type: type,
      tags: tags,
      createdAt: DateTime.now(),
    );

    _posts.add(post);
    _postsController.add(List.unmodifiable(_posts));
    
    // Update user stats
    await _updateUserStats('post_created');
    
    debugPrint('📝 Created post: $title');
    return post;
  }

  /// Reply to a community post
  Future<CommunityReply> replyToPost({
    required String postId,
    required String content,
    String? parentReplyId,
  }) async {
    if (_currentProfile == null) {
      throw Exception('Must create anonymous profile first');
    }

    // Content safety check
    if (!_contentFilter.isContentSafe(content)) {
      throw Exception('Reply violates community guidelines');
    }

    final replyId = _generateReplyId();
    final reply = CommunityReply(
      replyId: replyId,
      postId: postId,
      authorId: _currentProfile!.anonymousId,
      content: content,
      createdAt: DateTime.now(),
      parentReplyId: parentReplyId,
      isExpertReply: _currentProfile!.isExpertVerified,
    );

    _replies.add(reply);
    _repliesController.add(List.unmodifiable(_replies));
    
    // Update post reply count
    final postIndex = _posts.indexWhere((p) => p.postId == postId);
    if (postIndex != -1) {
      // In a real implementation, we'd update the post's reply count
    }
    
    // Update user stats
    await _updateUserStats('reply_created');
    
    debugPrint('💬 Created reply to post: $postId');
    return reply;
  }

  /// Get community statistics
  Future<CommunityStats> getCommunityStats() async {
    return CommunityStats(
      totalMembers: 5000,
      activeMembers: 1200,
      totalPosts: _posts.length,
      totalQuestions: _posts.where((p) => p.type == PostType.question).length,
      expertAnswers: 150,
      storiesShared: _posts.where((p) => p.type == PostType.story).length,
      categoryCounts: {'general': 100, 'symptoms': 80, 'tips': 60},
      lastUpdated: DateTime.now(),
    );
  }

  /// Get discussions
  Future<List<DiscussionPost>> getDiscussions() async {
    return _posts.map((post) => DiscussionPost(
      id: post.postId,
      userId: post.authorId,
      title: post.title,
      content: post.content,
      category: post.tags.isNotEmpty ? post.tags.first : 'general',
      createdAt: post.createdAt,
      likes: post.upvotes,
      replies: _replies.where((r) => r.postId == post.postId).length,
      tags: post.tags,
    )).toList();
  }

  /// Create discussion
  Future<void> createDiscussion({
    required String title,
    required String content,
    required String category,
    List<String>? tags,
    bool isAnonymous = false,
  }) async {
    await createPost(
      groupId: 'general',
      title: title,
      content: content,
      type: PostType.discussion,
      tags: tags ?? [],
    );
  }

  /// Join discussion
  Future<void> joinDiscussion(String discussionId) async {
    debugPrint('Joined discussion: $discussionId');
  }

  /// Like post
  Future<void> likePost(String postId) async {
    debugPrint('Liked post: $postId');
  }

  /// Report post
  Future<void> reportPost(String postId) async {
    debugPrint('Reported post: $postId');
  }

  /// Get expert questions
  Future<List<ExpertQuestion>> getExpertQuestions() async {
    return [
      ExpertQuestion(
        id: 'eq1',
        userId: 'user1',
        title: 'Question about irregular cycles',
        content: 'I have been experiencing irregular cycles...',
        category: 'medical',
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Get experts
  Future<List<CommunityProfile>> getExperts() async {
    return [
      CommunityProfile(
        id: 'expert1',
        userId: 'exp1',
        displayName: 'Dr. Smith',
        bio: 'Gynecologist with 10 years of experience',
        joinDate: DateTime.now(),
        reputationScore: 95,
        badges: ['verified', 'expert'],
      ),
    ];
  }

  /// Ask expert question
  Future<void> askExpertQuestion({
    required String title,
    required String content,
    required String category,
    String? preferredExpertId,
    bool isAnonymous = false,
  }) async {
    debugPrint('Asked expert question: $title');
  }

  /// Answer question
  Future<void> answerQuestion(String questionId, String answer) async {
    debugPrint('Answered question: $questionId');
  }

  /// Upvote answer
  Future<void> upvoteAnswer(String answerId) async {
    debugPrint('Upvoted answer: $answerId');
  }

  /// Bookmark answer
  Future<void> bookmarkAnswer(String answerId) async {
    debugPrint('Bookmarked answer: $answerId');
  }

  /// Get cycle buddies
  Future<List<CycleBuddy>> getCycleBuddies() async {
    return [];
  }

  /// Get pending buddy requests
  Future<List<BuddyRequest>> getPendingBuddyRequests() async {
    return [];
  }

  /// Find cycle buddies
  Future<List<CycleBuddy>> findCycleBuddies() async {
    return [];
  }

  /// Send buddy request
  Future<void> sendBuddyRequest(String userId, String message) async {
    debugPrint('Sent buddy request to: $userId');
  }

  /// Accept buddy request
  Future<void> acceptBuddyRequest(String requestId) async {
    debugPrint('Accepted buddy request: $requestId');
  }

  /// Decline buddy request
  Future<void> declineBuddyRequest(String requestId) async {
    debugPrint('Declined buddy request: $requestId');
  }

  /// Get symptom stories
  Future<List<SymptomStory>> getSymptomStories() async {
    return [];
  }

  /// Get symptom categories
  Future<List<String>> getSymptomCategories() async {
    return ['cramps', 'headache', 'mood swings', 'fatigue'];
  }

  /// Share symptom story
  Future<void> shareSymptomStory(SymptomStory story) async {
    debugPrint('Shared symptom story: ${story.title}');
  }

  /// React to story
  Future<void> reactToStory(String storyId, String reaction) async {
    debugPrint('Reacted to story: $storyId with $reaction');
  }

  /// Follow story
  Future<void> followStory(String storyId) async {
    debugPrint('Following story: $storyId');
  }

  /// Get community achievements
  Future<List<CommunityAchievement>> getCommunityAchievements() async {
    return _achievements;
  }

  /// Get user achievement progress
  Future<Map<String, double>> getUserAchievementProgress() async {
    return {'first_post': 1.0, 'helpful_member': 0.5};
  }

  /// Get achievement leaderboard
  Future<List<LeaderboardEntry>> getAchievementLeaderboard() async {
    return [
      LeaderboardEntry(
        userId: 'user1',
        displayName: 'ActiveUser',
        points: 500,
        rank: 1,
        badges: ['top_contributor'],
      ),
    ];
  }

  /// Claim achievement
  Future<void> claimAchievement(String achievementId) async {
    debugPrint('Claimed achievement: $achievementId');
  }

  /// Share achievement
  Future<void> shareAchievement(String achievementId) async {
    debugPrint('Shared achievement: $achievementId');
  }

  /// Search community
  Future<List<dynamic>> searchCommunity(String query) async {
    return _posts.where((post) => 
      post.title.toLowerCase().contains(query.toLowerCase()) ||
      post.content.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Vote on a post or reply
  Future<void> vote({
    required String targetId,
    required String targetType, // 'post' or 'reply'
    required bool isUpvote,
  }) async {
    if (_currentProfile == null) {
      throw Exception('Must create anonymous profile first');
    }

    // In production, this would update vote counts and prevent duplicate voting
    debugPrint('${isUpvote ? '👍' : '👎'} Voted on $targetType: $targetId');
    
    await _updateUserStats('vote_cast');
  }

  /// Report inappropriate content
  Future<void> reportContent({
    required String targetId,
    required String targetType,
    required String reason,
    String? details,
  }) async {
    final actionId = _generateActionId();
    final action = ModerationAction(
      actionId: actionId,
      targetType: targetType,
      targetId: targetId,
      moderatorId: 'system',
      actionType: ActionType.warning,
      reason: reason,
      details: details,
      createdAt: DateTime.now(),
    );

    // In production, this would be stored and reviewed by moderators
    debugPrint('⚠️ Content reported: $reason');
  }

  /// Get posts for a specific group
  List<CommunityPost> getPostsForGroup(String groupId) {
    return _posts.where((post) => post.groupId == groupId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get replies for a specific post
  List<CommunityReply> getRepliesForPost(String postId) {
    return _replies.where((reply) => reply.postId == postId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Search posts by keyword
  List<CommunityPost> searchPosts(String query) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return _posts.where((post) =>
      post.title.toLowerCase().contains(lowerQuery) ||
      post.content.toLowerCase().contains(lowerQuery) ||
      post.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
    ).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get trending posts (most upvotes in last 24 hours)
  List<CommunityPost> getTrendingPosts() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    
    return _posts.where((post) => post.createdAt.isAfter(yesterday)).toList()
      ..sort((a, b) => (b.upvotes - b.downvotes).compareTo(a.upvotes - a.downvotes))
      ..take(10).toList();
  }

  /// Get expert-verified replies
  List<CommunityReply> getExpertReplies(String postId) {
    return _replies.where((reply) => 
      reply.postId == postId && reply.isExpertReply
    ).toList();
  }

  /// Get community metrics
  CommunityMetrics getCommunityMetrics() {
    final totalMembers = 1250; // In production, this would be from database
    final activeMembers = 875;
    final dailyPosts = _posts.where((p) =>
      p.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 1)))
    ).length;
    final weeklyPosts = _posts.where((p) =>
      p.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).length;
    final monthlyPosts = _posts.where((p) =>
      p.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30)))
    ).length;

    final metrics = CommunityMetrics(
      totalMembers: totalMembers,
      activeMembers: activeMembers,
      dailyPosts: dailyPosts,
      weeklyPosts: weeklyPosts,
      monthlyPosts: monthlyPosts,
      averageResponseTime: 2.5, // hours
      helpfulnessRating: 4.2,
      topicDistribution: {
        'Period Questions': 35,
        'PMS Support': 25,
        'Health Tips': 20,
        'Cycle Tracking': 15,
        'General Discussion': 5,
      },
    );

    _metricsController.add(metrics);
    return metrics;
  }

  /// Get user achievements
  List<CommunityAchievement> getUserAchievements() {
    if (_currentProfile == null) return [];
    
    // Check for unlocked achievements
    final unlockedAchievements = <CommunityAchievement>[];
    
    for (final achievement in _achievements) {
      if (_checkAchievementUnlocked(achievement)) {
        unlockedAchievements.add(achievement.copyWith(unlockedAt: DateTime.now()));
      }
    }
    
    return unlockedAchievements;
  }

  /// Apply to become a verified expert
  Future<bool> applyForExpertVerification({
    required String profession,
    required List<String> certifications,
    required List<String> specialties,
    required String institution,
    required int yearsOfExperience,
  }) async {
    if (_currentProfile == null) {
      throw Exception('Must create anonymous profile first');
    }

    final credentials = ExpertCredentials(
      expertId: _currentProfile!.anonymousId,
      profession: profession,
      certifications: certifications,
      specialties: specialties,
      institution: institution,
      yearsOfExperience: yearsOfExperience,
      isVerified: false, // Requires manual verification
      verificationDate: DateTime.now(),
      verificationLevel: 'pending',
    );

    // In production, this would submit for manual review
    debugPrint('📋 Expert verification application submitted');
    return true;
  }

  /// Get daily discussion prompts
  List<String> getDailyPrompts() {
    return [
      "What's one thing you wish you knew about your cycle when you were younger?",
      "How do you manage PMS symptoms naturally?",
      "What's your favorite self-care routine during your period?",
      "Share a period myth you believed until recently",
      "What period product changed your life?",
      "How do you track your cycle and why?",
      "What's the best advice you'd give to someone just starting their period journey?",
    ];
  }

  /// Get cycle buddy suggestions (similar cycle patterns)
  List<AnonymousProfile> getCycleBuddySuggestions() {
    // In production, this would match users with similar cycle patterns
    return [
      AnonymousProfile(
        anonymousId: 'buddy1',
        displayName: 'CycleWarrior22',
        avatar: '🌸',
        experienceLevel: 3,
        interests: ['fitness', 'nutrition', 'mindfulness'],
        trustScore: {'helpfulness': 0.9, 'reliability': 0.8, 'expertise': 0.7},
        joinDate: DateTime.now().subtract(const Duration(days: 90)),
        helpfulVotes: 45,
        totalPosts: 23,
      ),
      AnonymousProfile(
        anonymousId: 'buddy2',
        displayName: 'WellnessJourney',
        avatar: '🦋',
        experienceLevel: 4,
        interests: ['yoga', 'meditation', 'natural remedies'],
        trustScore: {'helpfulness': 0.8, 'reliability': 0.9, 'expertise': 0.8},
        joinDate: DateTime.now().subtract(const Duration(days: 120)),
        helpfulVotes: 67,
        totalPosts: 31,
      ),
    ];
  }

  // Private helper methods

  Future<void> _loadDefaultGroups() async {
    _availableGroups.addAll([
      CommunityGroup(
        groupId: 'period_questions',
        name: 'Period Questions',
        description: 'Safe space to ask any questions about menstruation',
        category: 'Support',
        tags: ['questions', 'period', 'help'],
        memberCount: 1250,
        isPrivate: false,
        requiresApproval: false,
        moderatorIds: ['mod1', 'mod2'],
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        settings: {'allow_anonymous': true, 'expert_moderation': true},
      ),
      CommunityGroup(
        groupId: 'pms_support',
        name: 'PMS Support Circle',
        description: 'Support and tips for managing PMS symptoms',
        category: 'Health',
        tags: ['pms', 'symptoms', 'support'],
        memberCount: 890,
        isPrivate: false,
        requiresApproval: false,
        moderatorIds: ['mod1', 'expert1'],
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        settings: {'allow_anonymous': true, 'expert_moderation': true},
      ),
      CommunityGroup(
        groupId: 'cycle_tracking',
        name: 'Cycle Tracking Tips',
        description: 'Share experiences and tips about tracking your cycle',
        category: 'Education',
        tags: ['tracking', 'apps', 'methods'],
        memberCount: 567,
        isPrivate: false,
        requiresApproval: false,
        moderatorIds: ['mod2'],
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        settings: {'allow_anonymous': true, 'expert_moderation': false},
      ),
      CommunityGroup(
        groupId: 'teen_support',
        name: 'Teen Period Support',
        description: 'Safe space for teens to learn and ask questions',
        category: 'Teen Support',
        tags: ['teens', 'first_period', 'education'],
        memberCount: 423,
        isPrivate: true,
        requiresApproval: true,
        moderatorIds: ['mod1', 'expert2'],
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
        settings: {'allow_anonymous': true, 'expert_moderation': true, 'age_verification': true},
      ),
      CommunityGroup(
        groupId: 'expert_qa',
        name: 'Ask the Experts',
        description: 'Get answers from verified healthcare professionals',
        category: 'Expert Q&A',
        tags: ['experts', 'medical', 'professional'],
        memberCount: 2100,
        isPrivate: false,
        requiresApproval: false,
        moderatorIds: ['expert1', 'expert2', 'expert3'],
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        settings: {'allow_anonymous': true, 'expert_only_replies': true},
      ),
    ]);
  }

  Future<void> _loadVerifiedExperts() async {
    _verifiedExperts.addAll([
      ExpertCredentials(
        expertId: 'expert1',
        profession: 'Gynecologist',
        certifications: ['MD', 'Board Certified Gynecology'],
        specialties: ['Reproductive Health', 'Menstrual Disorders'],
        institution: 'Women\'s Health Center',
        yearsOfExperience: 15,
        isVerified: true,
        verificationDate: DateTime.now().subtract(const Duration(days: 90)),
        verificationLevel: 'premium',
      ),
      ExpertCredentials(
        expertId: 'expert2',
        profession: 'Nurse Practitioner',
        certifications: ['MSN', 'Women\'s Health NP'],
        specialties: ['Adolescent Health', 'Period Education'],
        institution: 'Teen Health Clinic',
        yearsOfExperience: 8,
        isVerified: true,
        verificationDate: DateTime.now().subtract(const Duration(days: 60)),
        verificationLevel: 'advanced',
      ),
      ExpertCredentials(
        expertId: 'expert3',
        profession: 'Nutritionist',
        certifications: ['RD', 'Certified Sports Nutritionist'],
        specialties: ['Cycle Nutrition', 'PMS Management'],
        institution: 'Wellness Nutrition Center',
        yearsOfExperience: 6,
        isVerified: true,
        verificationDate: DateTime.now().subtract(const Duration(days: 30)),
        verificationLevel: 'basic',
      ),
    ]);
  }

  Future<void> _loadAchievements() async {
    _achievements.addAll([
      CommunityAchievement(
        achievementId: 'first_post',
        name: 'First Steps',
        description: 'Create your first community post',
        icon: '🌱',
        category: 'Participation',
        pointsRequired: 1,
      ),
      CommunityAchievement(
        achievementId: 'helpful_member',
        name: 'Helpful Member',
        description: 'Receive 10 helpful votes',
        icon: '🤝',
        category: 'Helpfulness',
        pointsRequired: 10,
      ),
      CommunityAchievement(
        achievementId: 'cycle_expert',
        name: 'Cycle Expert',
        description: 'Share knowledge in 25 posts',
        icon: '🎓',
        category: 'Expertise',
        pointsRequired: 25,
      ),
      CommunityAchievement(
        achievementId: 'community_champion',
        name: 'Community Champion',
        description: 'Active member for 6 months',
        icon: '👑',
        category: 'Loyalty',
        pointsRequired: 180, // days
        isRare: true,
      ),
    ]);
  }

  Future<void> _generateSampleContent() async {
    // Generate sample posts for demonstration
    final samplePosts = [
      CommunityPost(
        postId: 'post1',
        authorId: 'user1',
        groupId: 'period_questions',
        title: 'Is it normal to have irregular cycles?',
        content: 'I\'ve been tracking my cycle for 6 months and it varies between 26-32 days. Is this normal?',
        type: PostType.question,
        tags: ['irregular', 'cycle_length', 'normal'],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        upvotes: 12,
        downvotes: 1,
        replyCount: 7,
      ),
      CommunityPost(
        postId: 'post2',
        authorId: 'user2',
        groupId: 'pms_support',
        title: 'Natural remedies for cramps that actually work',
        content: 'I wanted to share some natural remedies that have helped me with menstrual cramps...',
        type: PostType.tip,
        tags: ['cramps', 'natural_remedies', 'pain_relief'],
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        upvotes: 45,
        downvotes: 3,
        replyCount: 23,
        isHelpful: true,
      ),
    ];

    _posts.addAll(samplePosts);
    
    // Generate sample replies
    final sampleReplies = [
      CommunityReply(
        replyId: 'reply1',
        postId: 'post1',
        authorId: 'expert1',
        content: 'Cycle variation of 6 days is completely normal. This falls within the typical range...',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        upvotes: 8,
        isExpertReply: true,
      ),
      CommunityReply(
        replyId: 'reply2',
        postId: 'post2',
        authorId: 'user3',
        content: 'Thank you for sharing! I\'ve tried the heating pad suggestion and it really helps.',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        upvotes: 3,
      ),
    ];

    _replies.addAll(sampleReplies);
  }

  String _generateAnonymousId() {
    return 'anon_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _generatePostId() {
    return 'post_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _generateReplyId() {
    return 'reply_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _generateActionId() {
    return 'action_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _generateRandomAvatar() {
    final avatars = ['🌸', '🦋', '🌺', '🌷', '🌻', '🌼', '💖', '✨', '🌙', '⭐'];
    return avatars[Random().nextInt(avatars.length)];
  }

  bool _checkAchievementUnlocked(CommunityAchievement achievement) {
    if (_currentProfile == null) return false;

    switch (achievement.achievementId) {
      case 'first_post':
        return _currentProfile!.totalPosts >= 1;
      case 'helpful_member':
        return _currentProfile!.helpfulVotes >= 10;
      case 'cycle_expert':
        return _currentProfile!.totalPosts >= 25;
      case 'community_champion':
        final daysSinceJoin = DateTime.now().difference(_currentProfile!.joinDate).inDays;
        return daysSinceJoin >= 180;
      default:
        return false;
    }
  }

  Future<void> _updateUserStats(String action) async {
    if (_currentProfile == null) return;

    switch (action) {
      case 'post_created':
        // Update total posts count
        _currentProfile = AnonymousProfile(
          anonymousId: _currentProfile!.anonymousId,
          displayName: _currentProfile!.displayName,
          avatar: _currentProfile!.avatar,
          experienceLevel: _currentProfile!.experienceLevel,
          interests: _currentProfile!.interests,
          trustScore: _currentProfile!.trustScore,
          joinDate: _currentProfile!.joinDate,
          isExpertVerified: _currentProfile!.isExpertVerified,
          profession: _currentProfile!.profession,
          specialties: _currentProfile!.specialties,
          helpfulVotes: _currentProfile!.helpfulVotes,
          totalPosts: _currentProfile!.totalPosts + 1,
        );
        break;
      case 'reply_created':
        // Could update reply count if we tracked it
        break;
      case 'vote_cast':
        // Could update voting activity if we tracked it
        break;
    }
  }

  void dispose() {
    _postsController.close();
    _repliesController.close();
    _metricsController.close();
  }
}

// Extension methods for easier model manipulation
extension CommunityAchievementExtensions on CommunityAchievement {
  CommunityAchievement copyWith({
    DateTime? unlockedAt,
  }) {
    return CommunityAchievement(
      achievementId: achievementId,
      name: name,
      description: description,
      icon: icon,
      category: category,
      pointsRequired: pointsRequired,
      isRare: isRare,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
