import 'package:json_annotation/json_annotation.dart';
import 'answer.dart';

part 'question.g.dart';

/// Question Model for Community Q&A
/// Represents user questions submitted to healthcare experts
@JsonSerializable()
class Question {
  final String questionId;
  final String userId;
  final String title;
  final String content;
  final QuestionCategory category;
  final List<String> tags;
  final String? preferredExpertId;
  final bool isAnonymous;
  final bool isUrgent;
  final QuestionStatus status;
  final DateTime submittedDate;
  final DateTime? lastModified;
  final int viewCount;
  final int upvotes;
  final int downvotes;
  final List<Answer> answers;
  final String? acceptedAnswerId;
  final List<String> attachedImages;
  final QuestionMetadata? metadata;

  Question({
    required this.questionId,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    this.tags = const [],
    this.preferredExpertId,
    this.isAnonymous = false,
    this.isUrgent = false,
    required this.status,
    required this.submittedDate,
    this.lastModified,
    this.viewCount = 0,
    this.upvotes = 0,
    this.downvotes = 0,
    this.answers = const [],
    this.acceptedAnswerId,
    this.attachedImages = const [],
    this.metadata,
  });

  // Computed properties
  int get totalVotes => upvotes - downvotes;
  double get score => (upvotes - downvotes + answers.length * 0.5);
  bool get hasAcceptedAnswer => acceptedAnswerId != null;
  bool get hasAnswers => answers.isNotEmpty;
  Duration get timeSinceSubmission => DateTime.now().difference(submittedDate);
  bool get isRecent => timeSinceSubmission.inDays < 7;
  bool get isPopular => viewCount > 50 || upvotes > 10;

  /// Get question urgency level
  UrgencyLevel get urgencyLevel {
    if (isUrgent) return UrgencyLevel.urgent;
    if (category == QuestionCategory.emergency) return UrgencyLevel.critical;
    if (timeSinceSubmission.inHours > 48 && !hasAnswers) return UrgencyLevel.high;
    return UrgencyLevel.normal;
  }

  /// Get display name for author (considering anonymity)
  String get authorDisplayName {
    if (isAnonymous) {
      return 'Anonymous User';
    }
    // In real implementation, this would fetch user's display name
    return 'User ${userId.substring(0, 6)}';
  }

  /// Get formatted time since submission
  String get timeAgo {
    final duration = timeSinceSubmission;
    
    if (duration.inDays > 0) {
      return '${duration.inDays}d ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Get question summary (truncated content)
  String getSummary({int maxLength = 150}) {
    if (content.length <= maxLength) return content;
    
    final truncated = content.substring(0, maxLength);
    final lastSpace = truncated.lastIndexOf(' ');
    
    if (lastSpace > maxLength * 0.7) {
      return '${truncated.substring(0, lastSpace)}...';
    }
    
    return '${truncated}...';
  }

  /// Check if question matches search query
  bool matchesQuery(String query) {
    final queryLower = query.toLowerCase();
    
    return title.toLowerCase().contains(queryLower) ||
           content.toLowerCase().contains(queryLower) ||
           tags.any((tag) => tag.toLowerCase().contains(queryLower)) ||
           category.displayName.toLowerCase().contains(queryLower);
  }

  /// Get related tags based on content and category
  List<String> get suggestedTags {
    final suggestions = <String>[];
    
    // Category-based suggestions
    switch (category) {
      case QuestionCategory.cycleHealth:
        suggestions.addAll(['irregular cycles', 'period tracking', 'cycle length']);
        break;
      case QuestionCategory.pcos:
        suggestions.addAll(['PCOS', 'hormones', 'insulin resistance']);
        break;
      case QuestionCategory.fertility:
        suggestions.addAll(['fertility', 'ovulation', 'conception']);
        break;
      case QuestionCategory.pregnancy:
        suggestions.addAll(['pregnancy', 'early pregnancy', 'symptoms']);
        break;
      case QuestionCategory.contraception:
        suggestions.addAll(['birth control', 'contraception', 'family planning']);
        break;
      case QuestionCategory.menopause:
        suggestions.addAll(['menopause', 'perimenopause', 'hormone changes']);
        break;
      default:
        suggestions.addAll(['general health', 'wellness']);
    }
    
    // Remove tags already applied
    suggestions.removeWhere((tag) => tags.contains(tag));
    
    return suggestions.take(5).toList();
  }

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  Question copyWith({
    String? questionId,
    String? userId,
    String? title,
    String? content,
    QuestionCategory? category,
    List<String>? tags,
    String? preferredExpertId,
    bool? isAnonymous,
    bool? isUrgent,
    QuestionStatus? status,
    DateTime? submittedDate,
    DateTime? lastModified,
    int? viewCount,
    int? upvotes,
    int? downvotes,
    List<Answer>? answers,
    String? acceptedAnswerId,
    List<String>? attachedImages,
    QuestionMetadata? metadata,
  }) {
    return Question(
      questionId: questionId ?? this.questionId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      preferredExpertId: preferredExpertId ?? this.preferredExpertId,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isUrgent: isUrgent ?? this.isUrgent,
      status: status ?? this.status,
      submittedDate: submittedDate ?? this.submittedDate,
      lastModified: lastModified ?? this.lastModified,
      viewCount: viewCount ?? this.viewCount,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      answers: answers ?? this.answers,
      acceptedAnswerId: acceptedAnswerId ?? this.acceptedAnswerId,
      attachedImages: attachedImages ?? this.attachedImages,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Question Categories
enum QuestionCategory {
  cycleHealth('Cycle Health', 'Questions about menstrual cycle and period tracking', '🩸'),
  pcos('PCOS & Hormones', 'Polycystic ovary syndrome and hormonal issues', '⚗️'),
  fertility('Fertility', 'Conception, ovulation, and fertility-related questions', '🤱'),
  pregnancy('Pregnancy', 'Early pregnancy signs and concerns', '🤰'),
  contraception('Contraception', 'Birth control methods and family planning', '💊'),
  menopause('Menopause', 'Menopause and perimenopause questions', '🌸'),
  pain('Pain & Symptoms', 'Period pain, cramps, and other symptoms', '😣'),
  lifestyle('Lifestyle', 'Diet, exercise, and lifestyle factors', '🏃‍♀️'),
  mental('Mental Health', 'Mood, anxiety, and mental health during cycle', '🧠'),
  emergency('Emergency', 'Urgent medical concerns requiring immediate attention', '🚨'),
  general('General Health', 'General women\'s health questions', '💗');

  const QuestionCategory(this.displayName, this.description, this.icon);

  final String displayName;
  final String description;
  final String icon;

  /// Get category color for UI
  int get color {
    switch (this) {
      case QuestionCategory.cycleHealth:
        return 0xFFE91E63; // Pink
      case QuestionCategory.pcos:
        return 0xFF9C27B0; // Purple
      case QuestionCategory.fertility:
        return 0xFF4CAF50; // Green
      case QuestionCategory.pregnancy:
        return 0xFFFF9800; // Orange
      case QuestionCategory.contraception:
        return 0xFF2196F3; // Blue
      case QuestionCategory.menopause:
        return 0xFF795548; // Brown
      case QuestionCategory.pain:
        return 0xFFF44336; // Red
      case QuestionCategory.lifestyle:
        return 0xFF00BCD4; // Cyan
      case QuestionCategory.mental:
        return 0xFF673AB7; // Deep Purple
      case QuestionCategory.emergency:
        return 0xFFFF1744; // Red Accent
      case QuestionCategory.general:
        return 0xFF607D8B; // Blue Grey
    }
  }
}

/// Question Status
enum QuestionStatus {
  draft('Draft', 'Question is being composed'),
  open('Open', 'Waiting for expert answers'),
  answered('Answered', 'Has received at least one answer'),
  resolved('Resolved', 'Has an accepted answer'),
  closed('Closed', 'No longer accepting answers'),
  flagged('Flagged', 'Under moderation review'),
  archived('Archived', 'Archived for reference');

  const QuestionStatus(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Get status color for UI
  int get color {
    switch (this) {
      case QuestionStatus.draft:
        return 0xFF9E9E9E; // Grey
      case QuestionStatus.open:
        return 0xFF2196F3; // Blue
      case QuestionStatus.answered:
        return 0xFFFF9800; // Orange
      case QuestionStatus.resolved:
        return 0xFF4CAF50; // Green
      case QuestionStatus.closed:
        return 0xFF607D8B; // Blue Grey
      case QuestionStatus.flagged:
        return 0xFFF44336; // Red
      case QuestionStatus.archived:
        return 0xFF795548; // Brown
    }
  }

  /// Get status icon
  String get icon {
    switch (this) {
      case QuestionStatus.draft:
        return '📝';
      case QuestionStatus.open:
        return '❓';
      case QuestionStatus.answered:
        return '💬';
      case QuestionStatus.resolved:
        return '✅';
      case QuestionStatus.closed:
        return '🔒';
      case QuestionStatus.flagged:
        return '⚠️';
      case QuestionStatus.archived:
        return '📁';
    }
  }
}

/// Question Urgency Level
enum UrgencyLevel {
  normal('Normal', 0xFF4CAF50),
  high('High', 0xFFFF9800),
  urgent('Urgent', 0xFFF44336),
  critical('Critical', 0xFFD32F2F);

  const UrgencyLevel(this.displayName, this.color);

  final String displayName;
  final int color;

  String get icon {
    switch (this) {
      case UrgencyLevel.normal:
        return '🟢';
      case UrgencyLevel.high:
        return '🟡';
      case UrgencyLevel.urgent:
        return '🟠';
      case UrgencyLevel.critical:
        return '🔴';
    }
  }
}

/// Question Metadata for additional context
@JsonSerializable()
class QuestionMetadata {
  final String? userAge;
  final String? location;
  final List<String> symptoms;
  final DateTime? symptomStartDate;
  final String? medicalHistory;
  final List<String> medications;
  final String? additionalContext;
  final bool consentForResearch;
  final Map<String, dynamic> customFields;

  QuestionMetadata({
    this.userAge,
    this.location,
    this.symptoms = const [],
    this.symptomStartDate,
    this.medicalHistory,
    this.medications = const [],
    this.additionalContext,
    this.consentForResearch = false,
    this.customFields = const {},
  });

  /// Check if metadata is complete for expert consultation
  bool get isComplete {
    return userAge != null && symptoms.isNotEmpty && symptomStartDate != null;
  }

  /// Get formatted symptoms list
  String get formattedSymptoms {
    if (symptoms.isEmpty) return 'No symptoms specified';
    return symptoms.join(', ');
  }

  /// Get formatted medications list
  String get formattedMedications {
    if (medications.isEmpty) return 'No medications specified';
    return medications.join(', ');
  }

  factory QuestionMetadata.fromJson(Map<String, dynamic> json) => _$QuestionMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionMetadataToJson(this);
}

/// Question Filter Options
class QuestionFilters {
  final List<QuestionCategory>? categories;
  final List<QuestionStatus>? statuses;
  final UrgencyLevel? minUrgency;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool? hasAnswers;
  final bool? isResolved;
  final int? minUpvotes;
  final List<String>? tags;
  final String? searchQuery;

  QuestionFilters({
    this.categories,
    this.statuses,
    this.minUrgency,
    this.dateFrom,
    this.dateTo,
    this.hasAnswers,
    this.isResolved,
    this.minUpvotes,
    this.tags,
    this.searchQuery,
  });

  /// Check if a question matches these filters
  bool matches(Question question) {
    // Category filter
    if (categories != null && !categories!.contains(question.category)) {
      return false;
    }

    // Status filter
    if (statuses != null && !statuses!.contains(question.status)) {
      return false;
    }

    // Urgency filter
    if (minUrgency != null && question.urgencyLevel.index < minUrgency!.index) {
      return false;
    }

    // Date range filter
    if (dateFrom != null && question.submittedDate.isBefore(dateFrom!)) {
      return false;
    }
    if (dateTo != null && question.submittedDate.isAfter(dateTo!)) {
      return false;
    }

    // Has answers filter
    if (hasAnswers != null && question.hasAnswers != hasAnswers!) {
      return false;
    }

    // Is resolved filter
    if (isResolved != null && question.hasAcceptedAnswer != isResolved!) {
      return false;
    }

    // Minimum upvotes filter
    if (minUpvotes != null && question.upvotes < minUpvotes!) {
      return false;
    }

    // Tags filter
    if (tags != null && !tags!.any((tag) => question.tags.contains(tag))) {
      return false;
    }

    // Search query filter
    if (searchQuery != null && !question.matchesQuery(searchQuery!)) {
      return false;
    }

    return true;
  }
}
