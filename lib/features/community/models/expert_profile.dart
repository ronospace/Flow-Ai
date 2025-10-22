import 'package:json_annotation/json_annotation.dart';

part 'expert_profile.g.dart';

/// Expert Profile Model
/// Represents a verified healthcare professional in the community
@JsonSerializable()
class ExpertProfile {
  final String expertId;
  final String userId;
  final String fullName;
  final String title;
  final List<String> specialties;
  final List<String> credentials;
  final String institution;
  final String licenseNumber;
  final String bio;
  final String? profileImageUrl;
  final double rating;
  final int totalAnswers;
  final int acceptedAnswers;
  final double responseRate;
  final Duration averageResponseTime;
  final DateTime joinedDate;
  final bool isAvailable;
  final List<String> languages;
  final ExpertBadges? badges;
  final String? websiteUrl;
  final String? linkedInProfile;

  ExpertProfile({
    required this.expertId,
    required this.userId,
    required this.fullName,
    required this.title,
    required this.specialties,
    required this.credentials,
    required this.institution,
    required this.licenseNumber,
    required this.bio,
    this.profileImageUrl,
    required this.rating,
    required this.totalAnswers,
    required this.acceptedAnswers,
    required this.responseRate,
    required this.averageResponseTime,
    required this.joinedDate,
    required this.isAvailable,
    required this.languages,
    this.badges,
    this.websiteUrl,
    this.linkedInProfile,
  });

  // Computed properties
  double get acceptanceRate => totalAnswers > 0 ? acceptedAnswers / totalAnswers : 0.0;
  int get reputation => (rating * 100 + acceptedAnswers * 10 + totalAnswers * 2).round();
  bool get isTopExpert => rating >= 4.5 && totalAnswers >= 50;
  bool get isFeatured => badges?.featured == true;

  /// Get expert status based on performance metrics
  ExpertStatus get status {
    if (rating >= 4.8 && totalAnswers >= 100 && responseRate >= 0.95) {
      return ExpertStatus.platinum;
    } else if (rating >= 4.5 && totalAnswers >= 50 && responseRate >= 0.90) {
      return ExpertStatus.gold;
    } else if (rating >= 4.0 && totalAnswers >= 20 && responseRate >= 0.80) {
      return ExpertStatus.silver;
    } else {
      return ExpertStatus.bronze;
    }
  }

  /// Get primary specialty (first in the list)
  String get primarySpecialty => specialties.isNotEmpty ? specialties.first : 'General Practice';

  /// Get formatted credentials string
  String get formattedCredentials => credentials.join(', ');

  /// Check if expert specializes in a particular area
  bool hasSpecialty(String specialty) {
    return specialties.any((s) => s.toLowerCase().contains(specialty.toLowerCase()));
  }

  /// Check if expert is active (answered in last 30 days)
  bool get isActive {
    // In a real implementation, this would check last activity date
    return isAvailable && responseRate >= 0.7;
  }

  /// Get availability status message
  String get availabilityMessage {
    if (!isAvailable) return 'Currently unavailable';
    
    final avgHours = averageResponseTime.inHours;
    if (avgHours < 2) return 'Usually responds within 2 hours';
    if (avgHours < 24) return 'Usually responds within $avgHours hours';
    
    final days = (avgHours / 24).ceil();
    return 'Usually responds within $days day${days > 1 ? 's' : ''}';
  }

  factory ExpertProfile.fromJson(Map<String, dynamic> json) => _$ExpertProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ExpertProfileToJson(this);

  ExpertProfile copyWith({
    String? expertId,
    String? userId,
    String? fullName,
    String? title,
    List<String>? specialties,
    List<String>? credentials,
    String? institution,
    String? licenseNumber,
    String? bio,
    String? profileImageUrl,
    double? rating,
    int? totalAnswers,
    int? acceptedAnswers,
    double? responseRate,
    Duration? averageResponseTime,
    DateTime? joinedDate,
    bool? isAvailable,
    List<String>? languages,
    ExpertBadges? badges,
    String? websiteUrl,
    String? linkedInProfile,
  }) {
    return ExpertProfile(
      expertId: expertId ?? this.expertId,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      title: title ?? this.title,
      specialties: specialties ?? this.specialties,
      credentials: credentials ?? this.credentials,
      institution: institution ?? this.institution,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      totalAnswers: totalAnswers ?? this.totalAnswers,
      acceptedAnswers: acceptedAnswers ?? this.acceptedAnswers,
      responseRate: responseRate ?? this.responseRate,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      joinedDate: joinedDate ?? this.joinedDate,
      isAvailable: isAvailable ?? this.isAvailable,
      languages: languages ?? this.languages,
      badges: badges ?? this.badges,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      linkedInProfile: linkedInProfile ?? this.linkedInProfile,
    );
  }
}

/// Expert Badges for recognition and achievements
@JsonSerializable()
class ExpertBadges {
  final bool topContributor;
  final bool featured;
  final bool verified;
  final bool quickResponder;
  final bool knowledgeBaseContributor;
  final bool communityModerator;
  final List<String> specialtyBadges;
  final DateTime? lastBadgeEarned;

  ExpertBadges({
    this.topContributor = false,
    this.featured = false,
    this.verified = true, // All experts are verified by default
    this.quickResponder = false,
    this.knowledgeBaseContributor = false,
    this.communityModerator = false,
    this.specialtyBadges = const [],
    this.lastBadgeEarned,
  });

  /// Get total number of badges earned
  int get totalBadges {
    var count = 0;
    if (topContributor) count++;
    if (featured) count++;
    if (verified) count++;
    if (quickResponder) count++;
    if (knowledgeBaseContributor) count++;
    if (communityModerator) count++;
    count += specialtyBadges.length;
    return count;
  }

  /// Get list of all earned badge names
  List<String> get earnedBadges {
    final badges = <String>[];
    if (topContributor) badges.add('Top Contributor');
    if (featured) badges.add('Featured Expert');
    if (verified) badges.add('Verified Professional');
    if (quickResponder) badges.add('Quick Responder');
    if (knowledgeBaseContributor) badges.add('Knowledge Base Contributor');
    if (communityModerator) badges.add('Community Moderator');
    badges.addAll(specialtyBadges);
    return badges;
  }

  factory ExpertBadges.fromJson(Map<String, dynamic> json) => _$ExpertBadgesFromJson(json);
  Map<String, dynamic> toJson() => _$ExpertBadgesToJson(this);
}

/// Expert Status Levels
enum ExpertStatus {
  bronze('Bronze', 'Basic level expert', 0xFF8B4513),
  silver('Silver', 'Experienced expert', 0xFFC0C0C0),
  gold('Gold', 'Highly rated expert', 0xFFFFD700),
  platinum('Platinum', 'Top-tier expert', 0xFF40E0D0);

  const ExpertStatus(this.displayName, this.description, this.color);

  final String displayName;
  final String description;
  final int color;

  /// Get icon for the status level
  String get icon {
    switch (this) {
      case ExpertStatus.bronze:
        return '🥉';
      case ExpertStatus.silver:
        return '🥈';
      case ExpertStatus.gold:
        return '🥇';
      case ExpertStatus.platinum:
        return '💎';
    }
  }
}

/// Expert availability schedule
@JsonSerializable()
class ExpertAvailability {
  final String expertId;
  final Map<String, List<TimeSlot>> weeklySchedule; // Day of week -> time slots
  final List<String> timeZones; // Supported time zones
  final String primaryTimeZone;
  final bool acceptsUrgentQuestions;
  final Duration maxResponseTime;
  final String? availabilityNotes;

  ExpertAvailability({
    required this.expertId,
    required this.weeklySchedule,
    required this.timeZones,
    required this.primaryTimeZone,
    this.acceptsUrgentQuestions = true,
    this.maxResponseTime = const Duration(hours: 24),
    this.availabilityNotes,
  });

  /// Check if expert is available at a specific time
  bool isAvailableAt(DateTime dateTime) {
    final dayOfWeek = _getDayOfWeek(dateTime.weekday);
    final timeSlots = weeklySchedule[dayOfWeek] ?? [];
    
    for (final slot in timeSlots) {
      if (slot.contains(dateTime)) {
        return true;
      }
    }
    return false;
  }

  /// Get next available time slot
  DateTime? getNextAvailableTime() {
    final now = DateTime.now();
    
    // Check next 7 days
    for (int i = 0; i < 7; i++) {
      final checkDate = now.add(Duration(days: i));
      final dayOfWeek = _getDayOfWeek(checkDate.weekday);
      final timeSlots = weeklySchedule[dayOfWeek] ?? [];
      
      for (final slot in timeSlots) {
        final slotStart = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
          slot.startTime.hour,
          slot.startTime.minute,
        );
        
        if (slotStart.isAfter(now)) {
          return slotStart;
        }
      }
    }
    
    return null;
  }

  String _getDayOfWeek(int weekday) {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[weekday - 1];
  }

  factory ExpertAvailability.fromJson(Map<String, dynamic> json) => _$ExpertAvailabilityFromJson(json);
  Map<String, dynamic> toJson() => _$ExpertAvailabilityToJson(this);
}

/// Time slot for expert availability
@JsonSerializable()
class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isAvailable;
  final String? notes;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.notes,
  });

  /// Check if a specific time falls within this slot
  bool contains(DateTime dateTime) {
    if (!isAvailable) return false;
    
    final checkTime = TimeOfDay.fromDateTime(dateTime);
    return _isTimeBetween(checkTime, startTime, endTime);
  }

  /// Get duration of this time slot
  Duration get duration {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return Duration(minutes: endMinutes - startMinutes);
  }

  bool _isTimeBetween(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    
    if (startMinutes <= endMinutes) {
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } else {
      // Handles overnight slots (e.g., 22:00 - 02:00)
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }

  factory TimeSlot.fromJson(Map<String, dynamic> json) => _$TimeSlotFromJson(json);
  Map<String, dynamic> toJson() => _$TimeSlotToJson(this);
}

/// Simple TimeOfDay class (if not importing from Flutter)
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  @override
  String toString() {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeOfDay && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}
