import 'package:flutter/foundation.dart';
import '../models/achievement.dart';
import '../models/challenge.dart';
import '../models/streak_data.dart';
import '../models/leaderboard_entry.dart';
import '../models/reward.dart';
import '../models/educational_content.dart';
import '../services/gamification_service.dart';

/// 🏆 Gamification Controller - Central Management for Achievement and Engagement Systems
/// Features: Daily check-in streaks, health achievement badges, wellness challenges,
/// community leaderboards, educational elements, and viral growth mechanics
class GamificationController extends ChangeNotifier {
  final GamificationService _gamificationService;

  GamificationController({
    required GamificationService gamificationService,
  }) : _gamificationService = gamificationService;

  // Loading states
  bool _isLoading = false;
  bool _isLoadingStreaks = false;
  bool _isLoadingAchievements = false;
  bool _isLoadingChallenges = false;
  bool _isLoadingLeaderboard = false;
  bool _isLoadingRewards = false;

  // Error states
  String? _error;
  Map<String, String> _errors = {};

  // User progress data
  int _userLevel = 1;
  int _currentXP = 0;
  int _nextLevelXP = 100;
  int _totalPoints = 0;
  double _weeklyProgress = 0.0;

  // Streak data
  int _currentStreak = 0;
  int _longestStreak = 0;
  List<StreakData> _streakHistory = [];
  bool _canCheckInToday = true;
  DateTime? _lastCheckInDate;

  // Achievement data
  List<Achievement> _achievements = [];
  int _unlockedAchievements = 0;
  List<Achievement> _recentlyUnlocked = [];

  // Challenge data
  List<Challenge> _activeChallenges = [];
  List<Challenge> _completedChallenges = [];
  List<Challenge> _featuredChallenges = [];

  // Leaderboard data
  List<LeaderboardEntry> _friendsLeaderboard = [];
  List<LeaderboardEntry> _globalLeaderboard = [];
  int _leaderboardRank = 0;

  // Reward data
  List<Reward> _availableRewards = [];
  List<Reward> _featuredRewards = [];
  List<Reward> _purchasedRewards = [];

  // Educational content
  EducationalTip? _dailyHealthTip;
  List<EducationalArticle> _educationalArticles = [];
  List<HealthQuiz> _healthQuizzes = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingStreaks => _isLoadingStreaks;
  bool get isLoadingAchievements => _isLoadingAchievements;
  bool get isLoadingChallenges => _isLoadingChallenges;
  bool get isLoadingLeaderboard => _isLoadingLeaderboard;
  bool get isLoadingRewards => _isLoadingRewards;

  String? get error => _error;
  Map<String, String> get errors => Map.unmodifiable(_errors);

  int get userLevel => _userLevel;
  int get currentXP => _currentXP;
  int get nextLevelXP => _nextLevelXP;
  int get totalPoints => _totalPoints;
  double get weeklyProgress => _weeklyProgress;

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  List<StreakData> get streakHistory => List.unmodifiable(_streakHistory);
  bool get canCheckInToday => _canCheckInToday;
  DateTime? get lastCheckInDate => _lastCheckInDate;

  List<Achievement> get achievements => List.unmodifiable(_achievements);
  int get unlockedAchievements => _unlockedAchievements;
  List<Achievement> get recentlyUnlocked => List.unmodifiable(_recentlyUnlocked);

  List<Challenge> get activeChallenges => List.unmodifiable(_activeChallenges);
  List<Challenge> get completedChallenges => List.unmodifiable(_completedChallenges);
  List<Challenge> get featuredChallenges => List.unmodifiable(_featuredChallenges);

  List<LeaderboardEntry> get friendsLeaderboard => List.unmodifiable(_friendsLeaderboard);
  List<LeaderboardEntry> get globalLeaderboard => List.unmodifiable(_globalLeaderboard);
  int get leaderboardRank => _leaderboardRank;

  List<Reward> get availableRewards => List.unmodifiable(_availableRewards);
  List<Reward> get featuredRewards => List.unmodifiable(_featuredRewards);
  List<Reward> get purchasedRewards => List.unmodifiable(_purchasedRewards);

  EducationalTip? get dailyHealthTip => _dailyHealthTip;
  List<EducationalArticle> get educationalArticles => List.unmodifiable(_educationalArticles);
  List<HealthQuiz> get healthQuizzes => List.unmodifiable(_healthQuizzes);

  /// Load all gamification data
  Future<void> loadGamificationData() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadUserProgress(),
        _loadStreakData(),
        _loadAchievements(),
        _loadChallenges(),
        _loadLeaderboard(),
        _loadRewards(),
        _loadEducationalContent(),
      ]);
    } catch (e) {
      _error = 'Failed to load gamification data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MARK: - User Progress
  Future<void> _loadUserProgress() async {
    try {
      final progress = await _gamificationService.getUserProgress();
      _userLevel = progress.level;
      _currentXP = progress.currentXP;
      _nextLevelXP = progress.nextLevelXP;
      _totalPoints = progress.totalPoints;
      _weeklyProgress = progress.weeklyProgress;
      _errors.remove('progress');
    } catch (e) {
      _errors['progress'] = 'Failed to load user progress';
    }
  }

  // MARK: - Streak System
  Future<void> _loadStreakData() async {
    _isLoadingStreaks = true;
    notifyListeners();

    try {
      final streakData = await _gamificationService.getStreakData();
      _currentStreak = streakData.currentStreak;
      _longestStreak = streakData.longestStreak;
      _streakHistory = streakData.history;
      _lastCheckInDate = streakData.lastCheckIn;
      _canCheckInToday = _canPerformCheckInToday();
      _errors.remove('streaks');
    } catch (e) {
      _errors['streaks'] = 'Failed to load streak data';
    } finally {
      _isLoadingStreaks = false;
      notifyListeners();
    }
  }

  bool _canPerformCheckInToday() {
    if (_lastCheckInDate == null) return true;
    
    final today = DateTime.now();
    final lastCheckIn = _lastCheckInDate!;
    
    return today.year != lastCheckIn.year ||
           today.month != lastCheckIn.month ||
           today.day != lastCheckIn.day;
  }

  Future<void> performDailyCheckIn() async {
    if (!_canCheckInToday) return;

    try {
      final result = await _gamificationService.performDailyCheckIn();
      
      _currentStreak = result.newStreak;
      _lastCheckInDate = result.checkInDate;
      _canCheckInToday = false;
      _totalPoints += result.pointsEarned;
      _currentXP += result.xpEarned;
      
      // Check for level up
      if (_currentXP >= _nextLevelXP) {
        await _handleLevelUp();
      }
      
      // Check for new achievements
      await _checkForNewAchievements();
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to perform daily check-in: ${e.toString()}');
    }
  }

  // MARK: - Achievements
  Future<void> _loadAchievements() async {
    _isLoadingAchievements = true;
    notifyListeners();

    try {
      _achievements = await _gamificationService.getAchievements();
      _unlockedAchievements = _achievements.where((a) => a.isUnlocked).length;
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
      final result = await _gamificationService.claimAchievement(achievementId);
      
      final index = _achievements.indexWhere((a) => a.id == achievementId);
      if (index != -1) {
        _achievements[index] = _achievements[index].copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        _unlockedAchievements++;
        _totalPoints += result.pointsEarned;
      }
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to claim achievement: ${e.toString()}');
    }
  }

  Future<void> shareAchievement(String achievementId) async {
    try {
      await _gamificationService.shareAchievement(achievementId);
    } catch (e) {
      throw Exception('Failed to share achievement: ${e.toString()}');
    }
  }

  Future<void> _checkForNewAchievements() async {
    try {
      final newAchievements = await _gamificationService.checkForNewAchievements();
      
      for (final achievement in newAchievements) {
        final index = _achievements.indexWhere((a) => a.id == achievement.id);
        if (index != -1) {
          _achievements[index] = achievement;
          _recentlyUnlocked.add(achievement);
          _unlockedAchievements++;
        }
      }
      
      if (newAchievements.isNotEmpty) {
        _showAchievementNotifications(newAchievements);
      }
    } catch (e) {
      // Silently handle achievement check failures
    }
  }

  void _showAchievementNotifications(List<Achievement> achievements) {
    // This would trigger UI notifications for new achievements
    // Implementation depends on your notification system
  }

  // MARK: - Challenges
  Future<void> _loadChallenges() async {
    _isLoadingChallenges = true;
    notifyListeners();

    try {
      final challengeData = await Future.wait([
        _gamificationService.getActiveChallenges(),
        _gamificationService.getCompletedChallenges(),
        _gamificationService.getFeaturedChallenges(),
      ]);
      
      _activeChallenges = challengeData[0] as List<Challenge>;
      _completedChallenges = challengeData[1] as List<Challenge>;
      _featuredChallenges = challengeData[2] as List<Challenge>;
      _errors.remove('challenges');
    } catch (e) {
      _errors['challenges'] = 'Failed to load challenges';
    } finally {
      _isLoadingChallenges = false;
      notifyListeners();
    }
  }

  Future<void> joinChallenge(String challengeId) async {
    try {
      await _gamificationService.joinChallenge(challengeId);
      
      // Move challenge from featured to active
      final challengeIndex = _featuredChallenges.indexWhere((c) => c.id == challengeId);
      if (challengeIndex != -1) {
        final challenge = _featuredChallenges.removeAt(challengeIndex);
        _activeChallenges.add(challenge.copyWith(isJoined: true));
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to join challenge: ${e.toString()}');
    }
  }

  Future<void> completeChallenge(String challengeId) async {
    try {
      final result = await _gamificationService.completeChallenge(challengeId);
      
      // Move challenge from active to completed
      final challengeIndex = _activeChallenges.indexWhere((c) => c.id == challengeId);
      if (challengeIndex != -1) {
        final challenge = _activeChallenges.removeAt(challengeIndex);
        _completedChallenges.add(challenge.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        ));
        
        _totalPoints += result.pointsEarned;
        _currentXP += result.xpEarned;
        
        // Check for level up
        if (_currentXP >= _nextLevelXP) {
          await _handleLevelUp();
        }
        
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to complete challenge: ${e.toString()}');
    }
  }

  // MARK: - Leaderboard
  Future<void> _loadLeaderboard() async {
    _isLoadingLeaderboard = true;
    notifyListeners();

    try {
      final leaderboardData = await Future.wait([
        _gamificationService.getFriendsLeaderboard(),
        _gamificationService.getGlobalLeaderboard(),
        _gamificationService.getUserRank(),
      ]);
      
      _friendsLeaderboard = leaderboardData[0] as List<LeaderboardEntry>;
      _globalLeaderboard = leaderboardData[1] as List<LeaderboardEntry>;
      _leaderboardRank = leaderboardData[2] as int;
      _errors.remove('leaderboard');
    } catch (e) {
      _errors['leaderboard'] = 'Failed to load leaderboard';
    } finally {
      _isLoadingLeaderboard = false;
      notifyListeners();
    }
  }

  // MARK: - Rewards
  Future<void> _loadRewards() async {
    _isLoadingRewards = true;
    notifyListeners();

    try {
      final rewardData = await Future.wait([
        _gamificationService.getAvailableRewards(),
        _gamificationService.getFeaturedRewards(),
        _gamificationService.getPurchasedRewards(),
      ]);
      
      _availableRewards = rewardData[0] as List<Reward>;
      _featuredRewards = rewardData[1] as List<Reward>;
      _purchasedRewards = rewardData[2] as List<Reward>;
      _errors.remove('rewards');
    } catch (e) {
      _errors['rewards'] = 'Failed to load rewards';
    } finally {
      _isLoadingRewards = false;
      notifyListeners();
    }
  }

  Future<void> purchaseReward(String rewardId) async {
    try {
      final reward = _availableRewards.firstWhere((r) => r.id == rewardId);
      
      if (_totalPoints < reward.cost) {
        throw Exception('Insufficient points to purchase this reward');
      }
      
      await _gamificationService.purchaseReward(rewardId);
      
      _totalPoints -= reward.cost;
      _purchasedRewards.add(reward.copyWith(
        isPurchased: true,
        purchasedAt: DateTime.now(),
      ));
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to purchase reward: ${e.toString()}');
    }
  }

  // MARK: - Educational Content
  Future<void> _loadEducationalContent() async {
    try {
      final contentData = await Future.wait([
        _gamificationService.getDailyHealthTip(),
        _gamificationService.getEducationalArticles(),
        _gamificationService.getHealthQuizzes(),
      ]);
      
      _dailyHealthTip = contentData[0] as EducationalTip?;
      _educationalArticles = contentData[1] as List<EducationalArticle>;
      _healthQuizzes = contentData[2] as List<HealthQuiz>;
      _errors.remove('education');
    } catch (e) {
      _errors['education'] = 'Failed to load educational content';
    }
  }

  Future<void> completeQuiz(String quizId, Map<String, dynamic> answers) async {
    try {
      final result = await _gamificationService.completeQuiz(quizId, answers);
      
      final quizIndex = _healthQuizzes.indexWhere((q) => q.id == quizId);
      if (quizIndex != -1) {
        _healthQuizzes[quizIndex] = _healthQuizzes[quizIndex].copyWith(
          isCompleted: true,
          score: result.score,
          completedAt: DateTime.now(),
        );
        
        _totalPoints += result.pointsEarned;
        _currentXP += result.xpEarned;
        
        // Check for level up
        if (_currentXP >= _nextLevelXP) {
          await _handleLevelUp();
        }
        
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to complete quiz: ${e.toString()}');
    }
  }

  Future<void> markArticleAsRead(String articleId) async {
    try {
      final result = await _gamificationService.markArticleAsRead(articleId);
      
      final articleIndex = _educationalArticles.indexWhere((a) => a.id == articleId);
      if (articleIndex != -1) {
        _educationalArticles[articleIndex] = _educationalArticles[articleIndex].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        
        _totalPoints += result.pointsEarned;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to mark article as read: ${e.toString()}');
    }
  }

  // MARK: - Level System
  Future<void> _handleLevelUp() async {
    try {
      final newLevel = await _gamificationService.handleLevelUp(_currentXP);
      
      if (newLevel > _userLevel) {
        _userLevel = newLevel;
        _nextLevelXP = _calculateNextLevelXP(newLevel);
        
        // Show level up celebration
        _showLevelUpCelebration(newLevel);
        
        // Check for level-based achievements
        await _checkForNewAchievements();
      }
    } catch (e) {
      // Handle level up failure
    }
  }

  int _calculateNextLevelXP(int level) {
    // Example: exponential growth
    return (level * 100 * (1.2 * level)).round();
  }

  void _showLevelUpCelebration(int newLevel) {
    // This would trigger UI celebration for level up
    // Implementation depends on your notification system
  }

  // MARK: - Social Features
  Future<void> shareInviteLink() async {
    try {
      await _gamificationService.shareInviteLink();
    } catch (e) {
      throw Exception('Failed to share invite link: ${e.toString()}');
    }
  }

  // MARK: - Refresh Methods
  Future<void> refresh() async {
    await loadGamificationData();
  }

  Future<void> refreshStreaks() async {
    await _loadStreakData();
  }

  Future<void> refreshAchievements() async {
    await _loadAchievements();
  }

  Future<void> refreshChallenges() async {
    await _loadChallenges();
  }

  Future<void> refreshLeaderboard() async {
    await _loadLeaderboard();
  }

  Future<void> refreshRewards() async {
    await _loadRewards();
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

  // Clear recently unlocked achievements (after showing them)
  void clearRecentlyUnlocked() {
    _recentlyUnlocked.clear();
    notifyListeners();
  }
}
