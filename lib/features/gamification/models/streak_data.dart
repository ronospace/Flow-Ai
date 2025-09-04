/// Streak tracking model for daily engagement
class StreakData {
  final String id;
  final String userId;
  final String type; // tracking, mood, exercise, water, sleep, etc.
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final DateTime streakStartDate;
  final DateTime? streakEndDate;
  final bool isActive;
  final List<DateTime> activityDates;
  final Map<String, dynamic> streakMilestones;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StreakData({
    required this.id,
    required this.userId,
    required this.type,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    required this.streakStartDate,
    this.streakEndDate,
    this.isActive = true,
    this.activityDates = const [],
    this.streakMilestones = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  StreakData copyWith({
    String? id,
    String? userId,
    String? type,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    DateTime? streakStartDate,
    DateTime? streakEndDate,
    bool? isActive,
    List<DateTime>? activityDates,
    Map<String, dynamic>? streakMilestones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StreakData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      streakEndDate: streakEndDate ?? this.streakEndDate,
      isActive: isActive ?? this.isActive,
      activityDates: activityDates ?? this.activityDates,
      streakMilestones: streakMilestones ?? this.streakMilestones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasStreakToday {
    if (lastActivityDate == null) return false;
    final today = DateTime.now();
    final lastActivity = lastActivityDate!;
    
    return today.year == lastActivity.year &&
           today.month == lastActivity.month &&
           today.day == lastActivity.day;
  }

  bool get canExtendStreak {
    if (lastActivityDate == null) return true;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final lastActivity = lastActivityDate!;
    
    // Can extend if last activity was yesterday or today
    return (lastActivity.year == yesterday.year &&
            lastActivity.month == yesterday.month &&
            lastActivity.day == yesterday.day) ||
           hasStreakToday;
  }

  bool get isStreakBroken {
    if (lastActivityDate == null) return currentStreak > 0;
    final today = DateTime.now();
    final daysSinceLastActivity = today.difference(lastActivityDate!).inDays;
    
    return daysSinceLastActivity > 1;
  }

  int get daysSinceLastActivity {
    if (lastActivityDate == null) return 0;
    return DateTime.now().difference(lastActivityDate!).inDays;
  }

  Duration get streakDuration {
    if (streakEndDate != null) {
      return streakEndDate!.difference(streakStartDate);
    }
    return DateTime.now().difference(streakStartDate);
  }

  String get streakStatusMessage {
    if (!isActive) return 'Streak ended';
    if (isStreakBroken) return 'Streak broken';
    if (hasStreakToday) return 'Today\'s streak active!';
    if (canExtendStreak) return 'Ready to extend streak';
    return 'Start your streak today!';
  }

  List<DateTime> get thisWeekActivities {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return activityDates.where((date) {
      return date.isAfter(startDate.subtract(const Duration(days: 1)));
    }).toList();
  }

  List<DateTime> get thisMonthActivities {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return activityDates.where((date) {
      return date.isAfter(startOfMonth.subtract(const Duration(days: 1)));
    }).toList();
  }

  Map<int, int> get weeklyStreakCounts {
    final counts = <int, int>{};
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final weekday = (now.weekday + i) % 7;
      counts[weekday] = activityDates.where((date) => date.weekday == weekday + 1).length;
    }
    
    return counts;
  }

  bool hasReachedMilestone(int days) {
    return currentStreak >= days || longestStreak >= days;
  }

  List<int> get availableMilestones {
    return [3, 7, 14, 21, 30, 50, 75, 100, 150, 200, 250, 365];
  }

  int? get nextMilestone {
    for (final milestone in availableMilestones) {
      if (currentStreak < milestone) {
        return milestone;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
      'streakStartDate': streakStartDate.toIso8601String(),
      'streakEndDate': streakEndDate?.toIso8601String(),
      'isActive': isActive,
      'activityDates': activityDates.map((d) => d.toIso8601String()).toList(),
      'streakMilestones': streakMilestones,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'] as String)
          : null,
      streakStartDate: DateTime.parse(json['streakStartDate'] as String),
      streakEndDate: json['streakEndDate'] != null
          ? DateTime.parse(json['streakEndDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      activityDates: (json['activityDates'] as List<dynamic>? ?? [])
          .map((d) => DateTime.parse(d as String))
          .toList(),
      streakMilestones: json['streakMilestones'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StreakData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StreakData(id: $id, type: $type, currentStreak: $currentStreak)';
  }
}
