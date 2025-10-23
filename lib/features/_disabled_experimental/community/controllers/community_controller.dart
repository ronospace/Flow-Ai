import 'package:flutter/foundation.dart';
import '../../../core/models/community_models.dart';
import '../services/community_service.dart';

/// 🌍 Community Controller - Central Management for Community Features
/// Features: Discussion management, expert Q&A, cycle buddy matching,
/// symptom story sharing, achievement system, and community analytics
class CommunityController extends ChangeNotifier {
  final CommunityService _communityService;

  CommunityController({
    required CommunityService communityService,
  }) : _communityService = communityService;

  // Loading states
  bool _isLoading = false;
  bool _isLoadingDiscussions = false;
  bool _isLoadingExperts = false;
  bool _isLoadingBuddies = false;
  bool _isLoadingStories = false;
  bool _isLoadingAchievements = false;

  // Error states
  String? _error;
  final Map<String, String> _errors = {};

  // Community data
  CommunityStats? _communityStats;
  List<Discussion> _discussions = [];
  List<ExpertQuestion> _expertQuestions = [];
  List<Expert> _experts = [];
  List<CycleBuddy> _cycleBuddies = [];
  List<BuddyRequest> _pendingBuddyRequests = [];
  List<SymptomStory> _symptomStories = [];
  List<String> _symptomCategories = [];
  List<CommunityAchievement> _communityAchievements = [];
  Map<String, double> _userAchievementProgress = {};
  List<LeaderboardEntry> _achievementLeaderboard = [];

  // Filters and sorting
  String _discussionFilter = 'all';
  String _discussionSort = 'recent';
  String _expertFilter = 'all';
  String _symptomFilter = 'all';

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingDiscussions => _isLoadingDiscussions;
  bool get isLoadingExperts => _isLoadingExperts;
  bool get isLoadingBuddies => _isLoadingBuddies;
  bool get isLoadingStories => _isLoadingStories;
  bool get isLoadingAchievements => _isLoadingAchievements;

  String? get error => _error;
  Map<String, String> get errors => Map.unmodifiable(_errors);

  CommunityStats? get communityStats => _communityStats;
  List<Discussion> get discussions => List.unmodifiable(_discussions);
  List<ExpertQuestion> get expertQuestions => List.unmodifiable(_expertQuestions);
  List<Expert> get experts => List.unmodifiable(_experts);
  List<CycleBuddy> get cycleBuddies => List.unmodifiable(_cycleBuddies);
  List<BuddyRequest> get pendingBuddyRequests => List.unmodifiable(_pendingBuddyRequests);
  List<SymptomStory> get symptomStories => List.unmodifiable(_symptomStories);
  List<String> get symptomCategories => List.unmodifiable(_symptomCategories);
  List<CommunityAchievement> get communityAchievements => List.unmodifiable(_communityAchievements);
  Map<String, double> get userAchievementProgress => Map.unmodifiable(_userAchievementProgress);
  List<LeaderboardEntry> get achievementLeaderboard => List.unmodifiable(_achievementLeaderboard);

  String get discussionFilter => _discussionFilter;
  String get discussionSort => _discussionSort;
  String get expertFilter => _expertFilter;
  String get symptomFilter => _symptomFilter;

  /// Load all community data
  Future<void> loadCommunityData() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadCommunityStats(),
        _loadDiscussions(),
        _loadExpertQuestions(),
        _loadExperts(),
        _loadCycleBuddies(),
        _loadSymptomStories(),
        _loadAchievements(),
      ]);
    } catch (e) {
      _error = 'Failed to load community data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MARK: - Community Stats
  Future<void> _loadCommunityStats() async {
    try {
      _communityStats = await _communityService.getCommunityStats();
    } catch (e) {
      _errors['stats'] = 'Failed to load community stats';
    }
  }

  // MARK: - Discussions
  Future<void> _loadDiscussions() async {
    _isLoadingDiscussions = true;
    notifyListeners();

    try {
      _discussions = await _communityService.getDiscussions(
        filter: _discussionFilter,
        sort: _discussionSort,
      );
      _errors.remove('discussions');
    } catch (e) {
      _errors['discussions'] = 'Failed to load discussions';
    } finally {
      _isLoadingDiscussions = false;
      notifyListeners();
    }
  }

  Future<void> createDiscussion({
    required String title,
    required String content,
    required String category,
    List<String>? tags,
    bool isAnonymous = false,
  }) async {
    try {
      final discussion = await _communityService.createDiscussion(
        title: title,
        content: content,
        category: category,
        tags: tags,
        isAnonymous: isAnonymous,
      );
      
      _discussions.insert(0, discussion);
      _communityStats?.incrementDiscussions();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to create discussion: ${e.toString()}');
    }
  }

  Future<void> joinDiscussion(String discussionId) async {
    try {
      await _communityService.joinDiscussion(discussionId);
      
      final index = _discussions.indexWhere((d) => d.id == discussionId);
      if (index != -1) {
        _discussions[index] = _discussions[index].copyWith(
          participantCount: _discussions[index].participantCount + 1,
          hasJoined: true,
        );
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to join discussion: ${e.toString()}');
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _communityService.likePost(postId);
      // Update local state
      _updatePostLike(postId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to like post: ${e.toString()}');
    }
  }

  Future<void> reportPost(String postId, String reason) async {
    try {
      await _communityService.reportPost(postId, reason);
    } catch (e) {
      throw Exception('Failed to report post: ${e.toString()}');
    }
  }

  void _updatePostLike(String postId) {
    // Update discussion likes
    for (int i = 0; i < _discussions.length; i++) {
      if (_discussions[i].id == postId) {
        _discussions[i] = _discussions[i].copyWith(
          likeCount: _discussions[i].likeCount + 1,
          hasLiked: true,
        );
        return;
      }
    }
  }

  // MARK: - Expert Q&A
  Future<void> _loadExpertQuestions() async {
    _isLoadingExperts = true;
    notifyListeners();

    try {
      _expertQuestions = await _communityService.getExpertQuestions(
        filter: _expertFilter,
      );
      _errors.remove('experts');
    } catch (e) {
      _errors['experts'] = 'Failed to load expert questions';
    } finally {
      _isLoadingExperts = false;
      notifyListeners();
    }
  }

  Future<void> _loadExperts() async {
    try {
      _experts = await _communityService.getExperts();
    } catch (e) {
      _errors['experts'] = 'Failed to load experts';
    }
  }

  Future<void> askExpertQuestion({
    required String title,
    required String content,
    required String category,
    String? preferredExpertId,
    bool isAnonymous = false,
  }) async {
    try {
      final question = await _communityService.askExpertQuestion(
        title: title,
        content: content,
        category: category,
        preferredExpertId: preferredExpertId,
        isAnonymous: isAnonymous,
      );
      
      _expertQuestions.insert(0, question);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to ask expert question: ${e.toString()}');
    }
  }

  Future<void> answerQuestion(String questionId, String answer) async {
    try {
      await _communityService.answerQuestion(questionId, answer);
      
      final index = _expertQuestions.indexWhere((q) => q.id == questionId);
      if (index != -1) {
        _expertQuestions[index] = _expertQuestions[index].copyWith(
          answerCount: _expertQuestions[index].answerCount + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to answer question: ${e.toString()}');
    }
  }

  Future<void> upvoteAnswer(String answerId) async {
    try {
      await _communityService.upvoteAnswer(answerId);
      // Update local state if needed
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to upvote answer: ${e.toString()}');
    }
  }

  Future<void> bookmarkAnswer(String answerId) async {
    try {
      await _communityService.bookmarkAnswer(answerId);
      // Update local state if needed
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to bookmark answer: ${e.toString()}');
    }
  }

  // MARK: - Cycle Buddies
  Future<void> _loadCycleBuddies() async {
    _isLoadingBuddies = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _communityService.getCycleBuddies(),
        _communityService.getPendingBuddyRequests(),
      ]);
      
      _cycleBuddies = results[0] as List<CycleBuddy>;
      _pendingBuddyRequests = results[1] as List<BuddyRequest>;
      _errors.remove('buddies');
    } catch (e) {
      _errors['buddies'] = 'Failed to load cycle buddies';
    } finally {
      _isLoadingBuddies = false;
      notifyListeners();
    }
  }

  Future<List<CycleBuddy>> findCycleBuddies({
    int? maxAgeDifference,
    List<String>? commonInterests,
    bool? similarCycleLength,
    String? location,
  }) async {
    try {
      return await _communityService.findCycleBuddies(
        maxAgeDifference: maxAgeDifference,
        commonInterests: commonInterests,
        similarCycleLength: similarCycleLength,
        location: location,
      );
    } catch (e) {
      throw Exception('Failed to find cycle buddies: ${e.toString()}');
    }
  }

  Future<void> sendBuddyRequest(String userId, String message) async {
    try {
      final request = await _communityService.sendBuddyRequest(userId, message);
      // Could add to pending requests if needed
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to send buddy request: ${e.toString()}');
    }
  }

  Future<void> acceptBuddyRequest(String requestId) async {
    try {
      final buddy = await _communityService.acceptBuddyRequest(requestId);
      
      _cycleBuddies.add(buddy);
      _pendingBuddyRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to accept buddy request: ${e.toString()}');
    }
  }

  Future<void> declineBuddyRequest(String requestId) async {
    try {
      await _communityService.declineBuddyRequest(requestId);
      
      _pendingBuddyRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to decline buddy request: ${e.toString()}');
    }
  }

  // MARK: - Symptom Stories
  Future<void> _loadSymptomStories() async {
    _isLoadingStories = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _communityService.getSymptomStories(filter: _symptomFilter),
        _communityService.getSymptomCategories(),
      ]);
      
      _symptomStories = results[0] as List<SymptomStory>;
      _symptomCategories = results[1] as List<String>;
      _errors.remove('stories');
    } catch (e) {
      _errors['stories'] = 'Failed to load symptom stories';
    } finally {
      _isLoadingStories = false;
      notifyListeners();
    }
  }

  Future<void> shareSymptomStory({
    required String title,
    required String content,
    required String category,
    required List<String> symptoms,
    List<String>? treatments,
    int? severity,
    bool isAnonymous = true,
  }) async {
    try {
      final story = await _communityService.shareSymptomStory(
        title: title,
        content: content,
        category: category,
        symptoms: symptoms,
        treatments: treatments,
        severity: severity,
        isAnonymous: isAnonymous,
      );
      
      _symptomStories.insert(0, story);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to share symptom story: ${e.toString()}');
    }
  }

  Future<void> reactToStory(String storyId, String reaction) async {
    try {
      await _communityService.reactToStory(storyId, reaction);
      
      final index = _symptomStories.indexWhere((s) => s.id == storyId);
      if (index != -1) {
        _symptomStories[index] = _symptomStories[index].copyWith(
          reactionCount: _symptomStories[index].reactionCount + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to react to story: ${e.toString()}');
    }
  }

  Future<void> followStory(String storyId) async {
    try {
      await _communityService.followStory(storyId);
      
      final index = _symptomStories.indexWhere((s) => s.id == storyId);
      if (index != -1) {
        _symptomStories[index] = _symptomStories[index].copyWith(
          isFollowing: true,
        );
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to follow story: ${e.toString()}');
    }
  }

  // MARK: - Achievements
  Future<void> _loadAchievements() async {
    _isLoadingAchievements = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _communityService.getCommunityAchievements(),
        _communityService.getUserAchievementProgress(),
        _communityService.getAchievementLeaderboard(),
      ]);
      
      _communityAchievements = results[0] as List<CommunityAchievement>;
      _userAchievementProgress = results[1] as Map<String, double>;
      _achievementLeaderboard = results[2] as List<LeaderboardEntry>;
      _errors.remove('achievements');
    } catch (e) {
      _errors['achievements'] = 'Failed to load achievements';
    } finally {
      _isLoadingAchievements = false;
      notifyListeners();
    }
  }

  Future<void> claimAchievement(String achievementId) async {
    try {
      await _communityService.claimAchievement(achievementId);
      
      final index = _communityAchievements.indexWhere((a) => a.id == achievementId);
      if (index != -1) {
        _communityAchievements[index] = _communityAchievements[index].copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to claim achievement: ${e.toString()}');
    }
  }

  Future<void> shareAchievement(String achievementId) async {
    try {
      await _communityService.shareAchievement(achievementId);
    } catch (e) {
      throw Exception('Failed to share achievement: ${e.toString()}');
    }
  }

  // MARK: - Filters and Sorting
  void setDiscussionFilter(String filter) {
    if (_discussionFilter != filter) {
      _discussionFilter = filter;
      _loadDiscussions();
    }
  }

  void setDiscussionSort(String sort) {
    if (_discussionSort != sort) {
      _discussionSort = sort;
      _loadDiscussions();
    }
  }

  void setExpertFilter(String filter) {
    if (_expertFilter != filter) {
      _expertFilter = filter;
      _loadExpertQuestions();
    }
  }

  void setSymptomFilter(String filter) {
    if (_symptomFilter != filter) {
      _symptomFilter = filter;
      _loadSymptomStories();
    }
  }

  // MARK: - Search
  Future<List<dynamic>> searchCommunity(String query) async {
    try {
      return await _communityService.searchCommunity(query);
    } catch (e) {
      throw Exception('Failed to search community: ${e.toString()}');
    }
  }

  // MARK: - Refresh
  Future<void> refresh() async {
    await loadCommunityData();
  }

  Future<void> refreshDiscussions() async {
    await _loadDiscussions();
  }

  Future<void> refreshExperts() async {
    await Future.wait([
      _loadExpertQuestions(),
      _loadExperts(),
    ]);
  }

  Future<void> refreshBuddies() async {
    await _loadCycleBuddies();
  }

  Future<void> refreshStories() async {
    await _loadSymptomStories();
  }

  Future<void> refreshAchievements() async {
    await _loadAchievements();
  }

  // Clear errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearErrors() {
    _errors.clear();
    notifyListeners();
  }
}
