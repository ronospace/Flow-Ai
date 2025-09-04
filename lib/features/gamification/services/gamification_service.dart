import 'dart:math';
import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/challenge.dart';
import '../models/streak_data.dart';
import '../models/leaderboard_entry.dart';
import '../models/reward.dart';
import '../models/educational_content.dart';

/// Service for managing gamification features
class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  // Mock user data
  int _userPoints = 1250;
  int _userXp = 3450;
  int _userLevel = 5;
  String _userTier = 'gold';

  // Getters
  int get userPoints => _userPoints;
  int get userXp => _userXp;
  int get userLevel => _userLevel;
  String get userTier => _userTier;

  /// Load user achievements
  Future<List<Achievement>> loadUserAchievements() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    return [
      Achievement(
        id: '1',
        title: 'First Steps',
        description: 'Complete your first symptom tracking',
        category: 'tracking',
        icon: Icons.track_changes,
        color: Colors.green,
        pointsReward: 50,
        xpReward: 100,
        difficulty: 'easy',
        isUnlocked: true,
        isClaimed: true,
        progress: 1.0,
        target: 1.0,
        unlockedAt: DateTime.now().subtract(const Duration(days: 10)),
        claimedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Achievement(
        id: '2',
        title: 'Week Warrior',
        description: 'Track symptoms for 7 consecutive days',
        category: 'consistency',
        icon: Icons.calendar_view_week,
        color: Colors.blue,
        pointsReward: 200,
        xpReward: 300,
        difficulty: 'medium',
        isUnlocked: true,
        isClaimed: false,
        progress: 5.0,
        target: 7.0,
        unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Achievement(
        id: '3',
        title: 'Mood Master',
        description: 'Log your mood 30 times',
        category: 'mood',
        icon: Icons.sentiment_satisfied,
        color: Colors.orange,
        pointsReward: 150,
        xpReward: 250,
        difficulty: 'medium',
        isUnlocked: false,
        progress: 18.0,
        target: 30.0,
      ),
      Achievement(
        id: '4',
        title: 'Community Helper',
        description: 'Help 10 community members',
        category: 'community',
        icon: Icons.help_outline,
        color: Colors.purple,
        pointsReward: 300,
        xpReward: 500,
        difficulty: 'hard',
        isUnlocked: false,
        progress: 3.0,
        target: 10.0,
      ),
    ];
  }

  /// Load available challenges
  Future<List<Challenge>> loadChallenges() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final now = DateTime.now();
    
    return [
      Challenge(
        id: '1',
        title: 'Hydration Hero',
        description: 'Drink 8 glasses of water daily for a week',
        category: 'wellness',
        icon: Icons.local_drink,
        primaryColor: Colors.blue,
        accentColor: Colors.lightBlue,
        pointsReward: 100,
        xpReward: 200,
        difficulty: 'easy',
        type: 'weekly',
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 5)),
        hasJoined: true,
        joinedAt: now.subtract(const Duration(days: 1)),
        progress: 3.0,
        target: 7.0,
        participantCount: 1247,
        requirements: ['Track water intake daily'],
      ),
      Challenge(
        id: '2',
        title: 'Mindful Mornings',
        description: 'Start each day with 5 minutes of meditation',
        category: 'mindfulness',
        icon: Icons.self_improvement,
        primaryColor: Colors.green,
        accentColor: Colors.lightGreen,
        pointsReward: 150,
        xpReward: 300,
        difficulty: 'medium',
        type: 'daily',
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        hasJoined: false,
        progress: 0.0,
        target: 30.0,
        participantCount: 856,
        requirements: ['Log meditation sessions', 'Minimum 5 minutes per day'],
      ),
      Challenge(
        id: '3',
        title: 'Step Up Challenge',
        description: 'Walk 10,000 steps daily for two weeks',
        category: 'fitness',
        icon: Icons.directions_walk,
        primaryColor: Colors.orange,
        accentColor: Colors.deepOrange,
        pointsReward: 250,
        xpReward: 500,
        difficulty: 'hard',
        type: 'weekly',
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 15)),
        hasJoined: false,
        progress: 0.0,
        target: 14.0,
        participantCount: 432,
        requirements: ['Connect fitness tracker', 'Track daily steps'],
      ),
    ];
  }

  /// Load streak data
  Future<List<StreakData>> loadUserStreaks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final now = DateTime.now();
    
    return [
      StreakData(
        id: '1',
        userId: 'user123',
        type: 'tracking',
        currentStreak: 12,
        longestStreak: 28,
        lastActivityDate: now.subtract(const Duration(hours: 6)),
        streakStartDate: now.subtract(const Duration(days: 12)),
        isActive: true,
        activityDates: List.generate(
          12, 
          (i) => now.subtract(Duration(days: i)),
        ),
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      StreakData(
        id: '2',
        userId: 'user123',
        type: 'mood',
        currentStreak: 5,
        longestStreak: 15,
        lastActivityDate: now.subtract(const Duration(days: 1)),
        streakStartDate: now.subtract(const Duration(days: 5)),
        isActive: true,
        activityDates: List.generate(
          5, 
          (i) => now.subtract(Duration(days: i + 1)),
        ),
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Load leaderboard
  Future<List<LeaderboardEntry>> loadLeaderboard({
    String period = 'weekly',
    int limit = 50,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    
    final now = DateTime.now();
    final names = ['Alice', 'Bob', 'Carol', 'David', 'Eve', 'Frank', 'Grace', 'Henry', 'Ivy', 'Jack'];
    final tiers = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
    
    return List.generate(limit, (index) {
      final isCurrentUser = index == 4; // User is ranked 5th
      final points = 2000 - (index * 15) + Random().nextInt(50);
      final previousRank = index + Random().nextInt(3) - 1;
      
      return LeaderboardEntry(
        userId: 'user${index + 1}',
        username: isCurrentUser ? 'You' : names[index % names.length],
        displayName: isCurrentUser ? 'You' : '${names[index % names.length]} ${index + 1}',
        rank: index + 1,
        previousRank: previousRank > 0 ? previousRank : index + 1,
        totalPoints: points,
        weeklyPoints: points ~/ 4,
        monthlyPoints: points ~/ 2,
        totalXp: points * 2,
        level: (points / 500).floor() + 1,
        tier: tiers[min((points / 400).floor(), tiers.length - 1)],
        completionRate: 0.6 + (Random().nextDouble() * 0.4),
        recentAchievements: ['achievement_${index + 1}'],
        categoryScores: {
          'tracking': points ~/ 3,
          'mood': points ~/ 4,
          'wellness': points ~/ 5,
        },
        isCurrentUser: isCurrentUser,
        isFriend: Random().nextBool(),
        lastActiveAt: now.subtract(Duration(hours: Random().nextInt(48))),
      );
    });
  }

  /// Load available rewards
  Future<List<Reward>> loadRewards() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final now = DateTime.now();
    
    return [
      Reward(
        id: '1',
        title: '10% Premium Discount',
        description: 'Get 10% off your next premium subscription',
        category: 'premium',
        type: 'discount',
        icon: Icons.local_offer,
        primaryColor: Colors.purple,
        accentColor: Colors.deepPurple,
        pointsCost: 500,
        discountValue: 0.1,
        discountCode: 'WELLNESS10',
        isLimited: true,
        limitedQuantity: 100,
        remainingQuantity: 23,
        expiresAt: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Reward(
        id: '2',
        title: 'Wellness Sticker Pack',
        description: 'Cute stickers for your tracking journal',
        category: 'virtual',
        type: 'virtual',
        icon: Icons.emoji_emotions,
        primaryColor: Colors.pink,
        accentColor: Colors.pinkAccent,
        pointsCost: 150,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Reward(
        id: '3',
        title: 'Free Consultation',
        description: '30-minute wellness consultation with our experts',
        category: 'service',
        type: 'premium_feature',
        icon: Icons.medical_services,
        primaryColor: Colors.green,
        accentColor: Colors.lightGreen,
        pointsCost: 1000,
        isPremium: true,
        requirements: ['Complete health assessment', 'Premium subscriber'],
        isLimited: true,
        limitedQuantity: 50,
        remainingQuantity: 12,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  /// Load educational content
  Future<List<EducationalContent>> loadEducationalContent() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final now = DateTime.now();
    
    return [
      EducationalContent(
        id: '1',
        title: 'Understanding Your Cycle',
        description: 'Learn about the phases of your menstrual cycle and what to expect',
        content: 'Detailed content about menstrual cycle phases...',
        category: 'cycle_education',
        type: 'article',
        difficulty: 'beginner',
        tags: ['cycle', 'health', 'education'],
        icon: Icons.article,
        primaryColor: Colors.blue,
        thumbnailUrl: 'https://example.com/cycle-thumbnail.jpg',
        estimatedReadTimeMinutes: 8,
        pointsReward: 25,
        xpReward: 50,
        hasCompleted: true,
        completedAt: now.subtract(const Duration(days: 3)),
        progress: 1.0,
        publishedAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      EducationalContent(
        id: '2',
        title: 'Nutrition for Hormonal Health',
        description: 'Discover foods that support hormonal balance',
        content: 'Video content about nutrition and hormones...',
        category: 'nutrition',
        type: 'video',
        difficulty: 'intermediate',
        tags: ['nutrition', 'hormones', 'wellness'],
        icon: Icons.play_circle,
        primaryColor: Colors.green,
        videoUrl: 'https://example.com/nutrition-video.mp4',
        thumbnailUrl: 'https://example.com/nutrition-thumbnail.jpg',
        estimatedReadTimeMinutes: 15,
        pointsReward: 50,
        xpReward: 100,
        isInProgress: true,
        progress: 0.6,
        publishedAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      EducationalContent(
        id: '3',
        title: 'Stress Management Quiz',
        description: 'Test your knowledge about stress and its effects',
        content: 'Interactive quiz about stress management...',
        category: 'mental_health',
        type: 'quiz',
        difficulty: 'beginner',
        tags: ['stress', 'mental-health', 'quiz'],
        icon: Icons.quiz,
        primaryColor: Colors.orange,
        estimatedReadTimeMinutes: 10,
        pointsReward: 75,
        xpReward: 150,
        progress: 0.0,
        publishedAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Award points to user
  Future<bool> awardPoints(int points, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _userPoints += points;
    _checkLevelUp();
    return true;
  }

  /// Award XP to user
  Future<bool> awardXP(int xp, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _userXp += xp;
    _checkLevelUp();
    return true;
  }

  /// Check if user leveled up
  void _checkLevelUp() {
    final newLevel = (_userXp / 1000).floor() + 1;
    if (newLevel > _userLevel) {
      _userLevel = newLevel;
      // Update tier based on level
      if (_userLevel >= 20) {
        _userTier = 'diamond';
      } else if (_userLevel >= 15) {
        _userTier = 'platinum';
      } else if (_userLevel >= 10) {
        _userTier = 'gold';
      } else if (_userLevel >= 5) {
        _userTier = 'silver';
      } else {
        _userTier = 'bronze';
      }
    }
  }

  /// Join a challenge
  Future<bool> joinChallenge(String challengeId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In real implementation, this would update the challenge on the backend
    return true;
  }

  /// Update challenge progress
  Future<bool> updateChallengeProgress(String challengeId, double progress) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In real implementation, this would update progress on the backend
    return true;
  }

  /// Claim achievement
  Future<bool> claimAchievement(String achievementId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Award points and XP for the achievement
    await awardPoints(100, reason: 'Achievement claimed: $achievementId');
    await awardXP(200, reason: 'Achievement claimed: $achievementId');
    return true;
  }

  /// Redeem reward
  Future<bool> redeemReward(String rewardId, int pointsCost) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_userPoints >= pointsCost) {
      _userPoints -= pointsCost;
      return true;
    }
    return false;
  }

  /// Update streak
  Future<StreakData?> updateStreak(String type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In real implementation, this would update the streak on the backend
    // For now, return a mock updated streak
    final now = DateTime.now();
    return StreakData(
      id: '1',
      userId: 'user123',
      type: type,
      currentStreak: 13,
      longestStreak: 28,
      lastActivityDate: now,
      streakStartDate: now.subtract(const Duration(days: 13)),
      isActive: true,
      activityDates: List.generate(
        13, 
        (i) => now.subtract(Duration(days: i)),
      ),
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now,
    );
  }

  /// Complete educational content
  Future<bool> completeEducationalContent(String contentId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Award points and XP for completion
    await awardPoints(25, reason: 'Completed educational content: $contentId');
    await awardXP(50, reason: 'Completed educational content: $contentId');
    return true;
  }
}
