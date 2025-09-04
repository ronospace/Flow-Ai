import 'package:flutter/material.dart';

/// Educational content model for wellness education
class EducationalContent {
  final String id;
  final String title;
  final String description;
  final String content;
  final String category;
  final String type; // article, video, quiz, infographic, audio
  final String difficulty; // beginner, intermediate, advanced
  final List<String> tags;
  final IconData icon;
  final Color primaryColor;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String? audioUrl;
  final int estimatedReadTimeMinutes;
  final int pointsReward;
  final int xpReward;
  final bool isUnlocked;
  final bool hasCompleted;
  final DateTime? completedAt;
  final double progress;
  final List<String> prerequisites;
  final Map<String, dynamic> metadata;
  final DateTime publishedAt;
  final DateTime updatedAt;

  const EducationalContent({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    required this.type,
    required this.difficulty,
    this.tags = const [],
    required this.icon,
    required this.primaryColor,
    this.thumbnailUrl,
    this.videoUrl,
    this.audioUrl,
    this.estimatedReadTimeMinutes = 5,
    this.pointsReward = 10,
    this.xpReward = 50,
    this.isUnlocked = true,
    this.hasCompleted = false,
    this.completedAt,
    this.progress = 0.0,
    this.prerequisites = const [],
    this.metadata = const {},
    required this.publishedAt,
    required this.updatedAt,
  });

  EducationalContent copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? category,
    String? type,
    String? difficulty,
    List<String>? tags,
    IconData? icon,
    Color? primaryColor,
    String? thumbnailUrl,
    String? videoUrl,
    String? audioUrl,
    int? estimatedReadTimeMinutes,
    int? pointsReward,
    int? xpReward,
    bool? isUnlocked,
    bool? hasCompleted,
    DateTime? completedAt,
    double? progress,
    List<String>? prerequisites,
    Map<String, dynamic>? metadata,
    DateTime? publishedAt,
    DateTime? updatedAt,
  }) {
    return EducationalContent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      category: category ?? this.category,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      icon: icon ?? this.icon,
      primaryColor: primaryColor ?? this.primaryColor,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      estimatedReadTimeMinutes: estimatedReadTimeMinutes ?? this.estimatedReadTimeMinutes,
      pointsReward: pointsReward ?? this.pointsReward,
      xpReward: xpReward ?? this.xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      hasCompleted: hasCompleted ?? this.hasCompleted,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      prerequisites: prerequisites ?? this.prerequisites,
      metadata: metadata ?? this.metadata,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;
  bool get hasThumbnail => thumbnailUrl != null && thumbnailUrl!.isNotEmpty;
  
  bool get isInProgress => progress > 0.0 && progress < 1.0;
  bool get isStarted => progress > 0.0;
  
  double get progressPercentage => (progress * 100).clamp(0.0, 100.0);

  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'article':
        return 'Article';
      case 'video':
        return 'Video';
      case 'quiz':
        return 'Quiz';
      case 'infographic':
        return 'Infographic';
      case 'audio':
        return 'Audio';
      default:
        return 'Content';
    }
  }

  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'article':
        return Icons.article;
      case 'video':
        return Icons.play_circle;
      case 'quiz':
        return Icons.quiz;
      case 'infographic':
        return Icons.image;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.menu_book;
    }
  }

  Color get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    if (!isUnlocked) return 'Locked';
    if (hasCompleted) return 'Completed';
    if (isInProgress) return 'In Progress';
    return 'Available';
  }

  Color get statusColor {
    if (!isUnlocked) return Colors.grey;
    if (hasCompleted) return Colors.green;
    if (isInProgress) return Colors.blue;
    return primaryColor;
  }

  String get readTimeText {
    if (estimatedReadTimeMinutes < 1) return '< 1 min';
    if (estimatedReadTimeMinutes == 1) return '1 min read';
    return '$estimatedReadTimeMinutes min read';
  }

  String get rewardsText {
    final rewards = <String>[];
    if (pointsReward > 0) rewards.add('${pointsReward} pts');
    if (xpReward > 0) rewards.add('${xpReward} XP');
    return rewards.join(' • ');
  }

  bool get canAccess {
    if (!isUnlocked) return false;
    // Check if all prerequisites are met
    // This would typically be checked against user's completed content
    return true;
  }

  String get formattedPublishDate {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays > 730 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays > 60 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'type': type,
      'difficulty': difficulty,
      'tags': tags,
      'icon': icon.codePoint,
      'primaryColor': primaryColor.value,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
      'estimatedReadTimeMinutes': estimatedReadTimeMinutes,
      'pointsReward': pointsReward,
      'xpReward': xpReward,
      'isUnlocked': isUnlocked,
      'hasCompleted': hasCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'progress': progress,
      'prerequisites': prerequisites,
      'metadata': metadata,
      'publishedAt': publishedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory EducationalContent.fromJson(Map<String, dynamic> json) {
    return EducationalContent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      type: json['type'] as String,
      difficulty: json['difficulty'] as String,
      tags: List<String>.from(json['tags'] as List? ?? []),
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      primaryColor: Color(json['primaryColor'] as int),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      estimatedReadTimeMinutes: json['estimatedReadTimeMinutes'] as int? ?? 5,
      pointsReward: json['pointsReward'] as int? ?? 10,
      xpReward: json['xpReward'] as int? ?? 50,
      isUnlocked: json['isUnlocked'] as bool? ?? true,
      hasCompleted: json['hasCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      progress: json['progress'] as double? ?? 0.0,
      prerequisites: List<String>.from(json['prerequisites'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EducationalContent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'EducationalContent(id: $id, title: $title, type: $type)';
  }
}
