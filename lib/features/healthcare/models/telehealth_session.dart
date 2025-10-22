/// Telehealth Session model for healthcare integration
class TelehealthSession {
  final String sessionId;
  final String providerId;
  final String patientId;
  final DateTime scheduledDateTime;
  final Duration duration;
  final TelehealthSessionType type;
  final TelehealthSessionStatus status;
  final String? meetingLink;
  final String? reason;
  final double cost;
  final TelehealthInsurance? insurance;
  final DateTime? bookingDate;
  final String? cancellationReason;
  final List<String>? attachments;
  final String? sessionNotes;
  final TelehealthSessionRating? rating;

  const TelehealthSession({
    required this.sessionId,
    required this.providerId,
    required this.patientId,
    required this.scheduledDateTime,
    required this.duration,
    required this.type,
    required this.status,
    this.meetingLink,
    this.reason,
    required this.cost,
    this.insurance,
    this.bookingDate,
    this.cancellationReason,
    this.attachments,
    this.sessionNotes,
    this.rating,
  });

  /// Copy with updated fields
  TelehealthSession copyWith({
    String? sessionId,
    String? providerId,
    String? patientId,
    DateTime? scheduledDateTime,
    Duration? duration,
    TelehealthSessionType? type,
    TelehealthSessionStatus? status,
    String? meetingLink,
    String? reason,
    double? cost,
    TelehealthInsurance? insurance,
    DateTime? bookingDate,
    String? cancellationReason,
    List<String>? attachments,
    String? sessionNotes,
    TelehealthSessionRating? rating,
  }) {
    return TelehealthSession(
      sessionId: sessionId ?? this.sessionId,
      providerId: providerId ?? this.providerId,
      patientId: patientId ?? this.patientId,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      status: status ?? this.status,
      meetingLink: meetingLink ?? this.meetingLink,
      reason: reason ?? this.reason,
      cost: cost ?? this.cost,
      insurance: insurance ?? this.insurance,
      bookingDate: bookingDate ?? this.bookingDate,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      attachments: attachments ?? this.attachments,
      sessionNotes: sessionNotes ?? this.sessionNotes,
      rating: rating ?? this.rating,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'providerId': providerId,
      'patientId': patientId,
      'scheduledDateTime': scheduledDateTime.toIso8601String(),
      'duration': duration.inMinutes,
      'type': type.name,
      'status': status.name,
      'meetingLink': meetingLink,
      'reason': reason,
      'cost': cost,
      'insurance': insurance?.toJson(),
      'bookingDate': bookingDate?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'attachments': attachments,
      'sessionNotes': sessionNotes,
      'rating': rating?.toJson(),
    };
  }

  /// Create from JSON
  factory TelehealthSession.fromJson(Map<String, dynamic> json) {
    return TelehealthSession(
      sessionId: json['sessionId'] as String,
      providerId: json['providerId'] as String,
      patientId: json['patientId'] as String,
      scheduledDateTime: DateTime.parse(json['scheduledDateTime'] as String),
      duration: Duration(minutes: json['duration'] as int),
      type: TelehealthSessionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TelehealthSessionType.consultation,
      ),
      status: TelehealthSessionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TelehealthSessionStatus.available,
      ),
      meetingLink: json['meetingLink'] as String?,
      reason: json['reason'] as String?,
      cost: (json['cost'] as num).toDouble(),
      insurance: json['insurance'] != null
          ? TelehealthInsurance.fromJson(json['insurance'] as Map<String, dynamic>)
          : null,
      bookingDate: json['bookingDate'] != null
          ? DateTime.parse(json['bookingDate'] as String)
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List)
          : null,
      sessionNotes: json['sessionNotes'] as String?,
      rating: json['rating'] != null
          ? TelehealthSessionRating.fromJson(json['rating'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Get formatted duration
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Check if session is upcoming
  bool get isUpcoming {
    return status == TelehealthSessionStatus.scheduled &&
           scheduledDateTime.isAfter(DateTime.now());
  }

  /// Check if session is in progress
  bool get isInProgress {
    final now = DateTime.now();
    return status == TelehealthSessionStatus.scheduled &&
           now.isAfter(scheduledDateTime) &&
           now.isBefore(scheduledDateTime.add(duration));
  }

  /// Get final cost after insurance
  double get finalCost {
    if (insurance?.isAccepted == true) {
      return insurance!.copay;
    }
    return cost;
  }
}

/// Types of telehealth sessions
enum TelehealthSessionType {
  consultation,
  followUp,
  emergencyConsult,
  mentalHealth,
  nutritionConsult,
  fertilityCounseling,
  preventiveCare,
}

extension TelehealthSessionTypeExtension on TelehealthSessionType {
  String get displayName {
    switch (this) {
      case TelehealthSessionType.consultation:
        return 'General Consultation';
      case TelehealthSessionType.followUp:
        return 'Follow-up Appointment';
      case TelehealthSessionType.emergencyConsult:
        return 'Emergency Consultation';
      case TelehealthSessionType.mentalHealth:
        return 'Mental Health Session';
      case TelehealthSessionType.nutritionConsult:
        return 'Nutrition Consultation';
      case TelehealthSessionType.fertilityCounseling:
        return 'Fertility Counseling';
      case TelehealthSessionType.preventiveCare:
        return 'Preventive Care';
    }
  }

  String get icon {
    switch (this) {
      case TelehealthSessionType.consultation:
        return '💬';
      case TelehealthSessionType.followUp:
        return '🔄';
      case TelehealthSessionType.emergencyConsult:
        return '🚨';
      case TelehealthSessionType.mentalHealth:
        return '🧠';
      case TelehealthSessionType.nutritionConsult:
        return '🥗';
      case TelehealthSessionType.fertilityCounseling:
        return '🤱';
      case TelehealthSessionType.preventiveCare:
        return '🛡️';
    }
  }
}

/// Status of telehealth sessions
enum TelehealthSessionStatus {
  available,
  scheduled,
  inProgress,
  completed,
  cancelled,
  noShow,
  rescheduled,
}

extension TelehealthSessionStatusExtension on TelehealthSessionStatus {
  String get displayName {
    switch (this) {
      case TelehealthSessionStatus.available:
        return 'Available';
      case TelehealthSessionStatus.scheduled:
        return 'Scheduled';
      case TelehealthSessionStatus.inProgress:
        return 'In Progress';
      case TelehealthSessionStatus.completed:
        return 'Completed';
      case TelehealthSessionStatus.cancelled:
        return 'Cancelled';
      case TelehealthSessionStatus.noShow:
        return 'No Show';
      case TelehealthSessionStatus.rescheduled:
        return 'Rescheduled';
    }
  }

  bool get isActive {
    return this == TelehealthSessionStatus.scheduled ||
           this == TelehealthSessionStatus.inProgress;
  }

  bool get isCompleted {
    return this == TelehealthSessionStatus.completed ||
           this == TelehealthSessionStatus.cancelled ||
           this == TelehealthSessionStatus.noShow;
  }
}

/// Insurance information for telehealth
class TelehealthInsurance {
  final bool isAccepted;
  final double copay;
  final double coverage;
  final String? planName;
  final String? policyNumber;

  const TelehealthInsurance({
    required this.isAccepted,
    required this.copay,
    required this.coverage,
    this.planName,
    this.policyNumber,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'isAccepted': isAccepted,
      'copay': copay,
      'coverage': coverage,
      'planName': planName,
      'policyNumber': policyNumber,
    };
  }

  /// Create from JSON
  factory TelehealthInsurance.fromJson(Map<String, dynamic> json) {
    return TelehealthInsurance(
      isAccepted: json['isAccepted'] as bool,
      copay: (json['copay'] as num).toDouble(),
      coverage: (json['coverage'] as num).toDouble(),
      planName: json['planName'] as String?,
      policyNumber: json['policyNumber'] as String?,
    );
  }

  /// Get coverage percentage as string
  String get coveragePercentage {
    return '${(coverage * 100).toInt()}%';
  }
}

/// Session rating and feedback
class TelehealthSessionRating {
  final int rating; // 1-5 stars
  final String? feedback;
  final DateTime ratingDate;
  final List<String>? tags;

  TelehealthSessionRating({
    required this.rating,
    this.feedback,
    DateTime? ratingDate,
    this.tags,
  }) : ratingDate = ratingDate ?? DateTime.now();

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'feedback': feedback,
      'ratingDate': ratingDate.toIso8601String(),
      'tags': tags,
    };
  }

  /// Create from JSON
  factory TelehealthSessionRating.fromJson(Map<String, dynamic> json) {
    return TelehealthSessionRating(
      rating: json['rating'] as int,
      feedback: json['feedback'] as String?,
      ratingDate: DateTime.parse(json['ratingDate'] as String),
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
    );
  }

  /// Get star representation
  String get stars {
    return '⭐' * rating + '☆' * (5 - rating);
  }

  /// Check if rating is positive (4-5 stars)
  bool get isPositive => rating >= 4;
}
