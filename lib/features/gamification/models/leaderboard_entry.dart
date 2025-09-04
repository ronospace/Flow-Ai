import 'package:flutter/material.dart';

/// Leaderboard entry model for competitive features
class LeaderboardEntry {
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final int rank;
  final int previousRank;
  final int totalPoints;
  final int weeklyPoints;
  final int monthlyPoints;
  final int totalXp;
  final int level;
  final String tier; // bronze, silver, gold, platinum, diamond
  final double completionRate;
  final List<String> recentAchievements;
  final Map<String, int> categoryScores;
  final bool isCurrentUser;
  final bool isFriend;
  final DateTime lastActiveAt;
  final Map<String, dynamic>? metadata;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.rank,
    this.previousRank = 0,
    this.totalPoints = 0,
    this.weeklyPoints = 0,
    this.monthlyPoints = 0,
    this.totalXp = 0,
    this.level = 1,
    this.tier = 'bronze',
    this.completionRate = 0.0,
    this.recentAchievements = const [],
    this.categoryScores = const {},
    this.isCurrentUser = false,
    this.isFriend = false,
    required this.lastActiveAt,
    this.metadata,
  });

  LeaderboardEntry copyWith({
    String? userId,
    String? username,
    String? displayName,
    String? avatarUrl,
    int? rank,
    int? previousRank,
    int? totalPoints,
    int? weeklyPoints,
    int? monthlyPoints,
    int? totalXp,
    int? level,
    String? tier,
    double? completionRate,
    List<String>? recentAchievements,
    Map<String, int>? categoryScores,
    bool? isCurrentUser,
    bool? isFriend,
    DateTime? lastActiveAt,
    Map<String, dynamic>? metadata,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rank: rank ?? this.rank,
      previousRank: previousRank ?? this.previousRank,
      totalPoints: totalPoints ?? this.totalPoints,
      weeklyPoints: weeklyPoints ?? this.weeklyPoints,
      monthlyPoints: monthlyPoints ?? this.monthlyPoints,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      tier: tier ?? this.tier,
      completionRate: completionRate ?? this.completionRate,
      recentAchievements: recentAchievements ?? this.recentAchievements,
      categoryScores: categoryScores ?? this.categoryScores,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      isFriend: isFriend ?? this.isFriend,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      metadata: metadata ?? this.metadata,
    );
  }

  String get effectiveDisplayName => displayName ?? username;

  int get rankChange => previousRank > 0 ? previousRank - rank : 0;

  bool get hasMovedUp => rankChange > 0;
  bool get hasMovedDown => rankChange < 0;
  bool get rankUnchanged => rankChange == 0;

  String get rankChangeText {
    if (rankChange > 0) return '+$rankChange';
    if (rankChange < 0) return '$rankChange';
    return '—';
  }

  Color get tierColor {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      case 'diamond':
        return const Color(0xFFB9F2FF);
      default:
        return Colors.grey;
    }
  }

  Color get rankChangeColor {
    if (hasMovedUp) return Colors.green;
    if (hasMovedDown) return Colors.red;
    return Colors.grey;
  }

  IconData get rankChangeIcon {
    if (hasMovedUp) return Icons.trending_up;
    if (hasMovedDown) return Icons.trending_down;
    return Icons.remove;
  }

  bool get isTopRank => rank <= 3;

  IconData get rankIcon {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.military_tech;
      case 3:
        return Icons.workspace_premium;
      default:
        return Icons.person;
    }
  }

  Color get rankIconColor {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }

  String get activityStatus {
    final now = DateTime.now();
    final difference = now.difference(lastActiveAt);
    
    if (difference.inMinutes < 5) return 'Online';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7}w ago';
    return '${difference.inDays ~/ 30}mo ago';
  }

  double get nextLevelProgress {
    // Assuming levels require exponentially more XP
    final currentLevelXp = level * level * 1000;
    final nextLevelXp = (level + 1) * (level + 1) * 1000;
    final progressXp = totalXp - currentLevelXp;
    final requiredXp = nextLevelXp - currentLevelXp;
    
    return requiredXp > 0 ? (progressXp / requiredXp).clamp(0.0, 1.0) : 0.0;
  }

  String get completionRateText {
    return '${(completionRate * 100).toInt()}%';
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'rank': rank,
      'previousRank': previousRank,
      'totalPoints': totalPoints,
      'weeklyPoints': weeklyPoints,
      'monthlyPoints': monthlyPoints,
      'totalXp': totalXp,
      'level': level,
      'tier': tier,
      'completionRate': completionRate,
      'recentAchievements': recentAchievements,
      'categoryScores': categoryScores,
      'isCurrentUser': isCurrentUser,
      'isFriend': isFriend,
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      rank: json['rank'] as int,
      previousRank: json['previousRank'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      weeklyPoints: json['weeklyPoints'] as int? ?? 0,
      monthlyPoints: json['monthlyPoints'] as int? ?? 0,
      totalXp: json['totalXp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      tier: json['tier'] as String? ?? 'bronze',
      completionRate: json['completionRate'] as double? ?? 0.0,
      recentAchievements: List<String>.from(json['recentAchievements'] as List? ?? []),
      categoryScores: Map<String, int>.from(json['categoryScores'] as Map? ?? {}),
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
      isFriend: json['isFriend'] as bool? ?? false,
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardEntry && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'LeaderboardEntry(userId: $userId, rank: $rank, points: $totalPoints)';
  }
}
