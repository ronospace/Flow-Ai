import 'package:flutter/material.dart';

/// Achievement model for gamification system
class Achievement {
  final String id;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final Color color;
  final int pointsReward;
  final int xpReward;
  final String difficulty; // easy, medium, hard, legendary
  final bool isUnlocked;
  final bool isClaimed;
  final DateTime? unlockedAt;
  final DateTime? claimedAt;
  final double progress;
  final double target;
  final Map<String, dynamic>? metadata;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.pointsReward,
    required this.xpReward,
    required this.difficulty,
    this.isUnlocked = false,
    this.isClaimed = false,
    this.unlockedAt,
    this.claimedAt,
    this.progress = 0.0,
    this.target = 1.0,
    this.metadata,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    IconData? icon,
    Color? color,
    int? pointsReward,
    int? xpReward,
    String? difficulty,
    bool? isUnlocked,
    bool? isClaimed,
    DateTime? unlockedAt,
    DateTime? claimedAt,
    double? progress,
    double? target,
    Map<String, dynamic>? metadata,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      pointsReward: pointsReward ?? this.pointsReward,
      xpReward: xpReward ?? this.xpReward,
      difficulty: difficulty ?? this.difficulty,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isClaimed: isClaimed ?? this.isClaimed,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      claimedAt: claimedAt ?? this.claimedAt,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isCompleted => progress >= target;
  double get progressPercentage => target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

  Color get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      case 'legendary':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon.codePoint,
      'color': color.value,
      'pointsReward': pointsReward,
      'xpReward': xpReward,
      'difficulty': difficulty,
      'isUnlocked': isUnlocked,
      'isClaimed': isClaimed,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'claimedAt': claimedAt?.toIso8601String(),
      'progress': progress,
      'target': target,
      'metadata': metadata,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] as int),
      pointsReward: json['pointsReward'] as int,
      xpReward: json['xpReward'] as int,
      difficulty: json['difficulty'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isClaimed: json['isClaimed'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt'] as String) 
          : null,
      claimedAt: json['claimedAt'] != null 
          ? DateTime.parse(json['claimedAt'] as String) 
          : null,
      progress: json['progress'] as double? ?? 0.0,
      target: json['target'] as double? ?? 1.0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, isUnlocked: $isUnlocked)';
  }
}
