import 'package:flutter/material.dart';

/// Challenge model for wellness gamification
class Challenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final Color primaryColor;
  final Color accentColor;
  final int pointsReward;
  final int xpReward;
  final String difficulty;
  final String type; // daily, weekly, monthly, one-time
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isCompleted;
  final bool hasJoined;
  final DateTime? joinedAt;
  final DateTime? completedAt;
  final double progress;
  final double target;
  final int participantCount;
  final List<String> requirements;
  final Map<String, dynamic>? metadata;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.primaryColor,
    required this.accentColor,
    required this.pointsReward,
    required this.xpReward,
    required this.difficulty,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.isCompleted = false,
    this.hasJoined = false,
    this.joinedAt,
    this.completedAt,
    this.progress = 0.0,
    this.target = 1.0,
    this.participantCount = 0,
    this.requirements = const [],
    this.metadata,
  });

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    IconData? icon,
    Color? primaryColor,
    Color? accentColor,
    int? pointsReward,
    int? xpReward,
    String? difficulty,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isCompleted,
    bool? hasJoined,
    DateTime? joinedAt,
    DateTime? completedAt,
    double? progress,
    double? target,
    int? participantCount,
    List<String>? requirements,
    Map<String, dynamic>? metadata,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      pointsReward: pointsReward ?? this.pointsReward,
      xpReward: xpReward ?? this.xpReward,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      hasJoined: hasJoined ?? this.hasJoined,
      joinedAt: joinedAt ?? this.joinedAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      participantCount: participantCount ?? this.participantCount,
      requirements: requirements ?? this.requirements,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isStarted => DateTime.now().isAfter(startDate);
  bool get isOngoing => isStarted && !isExpired && isActive;
  
  Duration get timeRemaining => isExpired ? Duration.zero : endDate.difference(DateTime.now());
  Duration get totalDuration => endDate.difference(startDate);
  
  double get progressPercentage => target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

  String get statusText {
    if (isCompleted) return 'Completed';
    if (isExpired) return 'Expired';
    if (!isStarted) return 'Coming Soon';
    if (!hasJoined) return 'Available';
    return 'In Progress';
  }

  Color get statusColor {
    if (isCompleted) return Colors.green;
    if (isExpired) return Colors.grey;
    if (!isStarted) return Colors.blue;
    if (!hasJoined) return primaryColor;
    return Colors.orange;
  }

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

  String get timeRemainingText {
    final remaining = timeRemaining;
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h left';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m left';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m left';
    } else {
      return 'Ended';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon.codePoint,
      'primaryColor': primaryColor.value,
      'accentColor': accentColor.value,
      'pointsReward': pointsReward,
      'xpReward': xpReward,
      'difficulty': difficulty,
      'type': type,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'isCompleted': isCompleted,
      'hasJoined': hasJoined,
      'joinedAt': joinedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'progress': progress,
      'target': target,
      'participantCount': participantCount,
      'requirements': requirements,
      'metadata': metadata,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      primaryColor: Color(json['primaryColor'] as int),
      accentColor: Color(json['accentColor'] as int),
      pointsReward: json['pointsReward'] as int,
      xpReward: json['xpReward'] as int,
      difficulty: json['difficulty'] as String,
      type: json['type'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      isCompleted: json['isCompleted'] as bool? ?? false,
      hasJoined: json['hasJoined'] as bool? ?? false,
      joinedAt: json['joinedAt'] != null 
          ? DateTime.parse(json['joinedAt'] as String) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      progress: json['progress'] as double? ?? 0.0,
      target: json['target'] as double? ?? 1.0,
      participantCount: json['participantCount'] as int? ?? 0,
      requirements: List<String>.from(json['requirements'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Challenge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Challenge(id: $id, title: $title, status: $statusText)';
  }
}
