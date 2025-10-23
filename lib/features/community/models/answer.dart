import 'package:json_annotation/json_annotation.dart';

part 'answer.g.dart';

/// Answer Model for Community Q&A
/// Represents expert responses to user questions
@JsonSerializable()
class Answer {
  final String answerId;
  final String questionId;
  final String expertId;
  final String content;
  final List<String> references;
  final List<String> attachments;
  final DateTime submittedDate;
  final DateTime? lastModified;
  final int upvotes;
  final int downvotes;
  final bool isVerifiedAnswer;
  final bool isAccepted;
  final AnswerType answerType;
  final String? disclaimer;
  final List<AnswerTag> tags;
  final AnswerMetadata? metadata;

  Answer({
    required this.answerId,
    required this.questionId,
    required this.expertId,
    required this.content,
    this.references = const [],
    this.attachments = const [],
    required this.submittedDate,
    this.lastModified,
    this.upvotes = 0,
    this.downvotes = 0,
    this.isVerifiedAnswer = true,
    this.isAccepted = false,
    this.answerType = AnswerType.comprehensive,
    this.disclaimer,
    this.tags = const [],
    this.metadata,
  });

  // Computed properties
  int get totalVotes => upvotes - downvotes;
  double get score => (upvotes - downvotes) + (isAccepted ? 15 : 0) + (isVerifiedAnswer ? 5 : 0);
  bool get hasReferences => references.isNotEmpty;
  bool get hasAttachments => attachments.isNotEmpty;
  Duration get timeSinceSubmission => DateTime.now().difference(submittedDate);
  bool get isRecent => timeSinceSubmission.inDays < 7;

  /// Get answer quality score based on various factors
  double get qualityScore {
    var score = 0.0;
    
    // Content length (optimal range: 200-1000 characters)
    final contentLength = content.length;
    if (contentLength >= 200 && contentLength <= 1000) {
      score += 2.0;
    } else if (contentLength >= 100) {
      score += 1.0;
    }
    
    // Has references
    if (hasReferences) {
      score += 3.0;
    }
    
    // Vote ratio
    final totalVotesAbs = upvotes + downvotes;
    if (totalVotesAbs > 0) {
      final voteRatio = upvotes / totalVotesAbs;
      score += voteRatio * 2.0;
    }
    
    // Verified answer bonus
    if (isVerifiedAnswer) {
      score += 1.0;
    }
    
    // Accepted answer bonus
    if (isAccepted) {
      score += 5.0;
    }
    
    // Answer type bonus
    switch (answerType) {
      case AnswerType.comprehensive:
        score += 1.5;
        break;
      case AnswerType.educational:
        score += 1.0;
        break;
      case AnswerType.quick:
        score += 0.5;
        break;
      default:
        break;
    }
    
    return score.clamp(0.0, 10.0);
  }

  /// Get helpfulness rating
  HelpfulnessRating get helpfulnessRating {
    if (qualityScore >= 8.0) return HelpfulnessRating.excellent;
    if (qualityScore >= 6.0) return HelpfulnessRating.good;
    if (qualityScore >= 4.0) return HelpfulnessRating.fair;
    return HelpfulnessRating.poor;
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

  /// Get formatted references list
  String get formattedReferences {
    if (references.isEmpty) return '';
    
    return references
        .asMap()
        .entries
        .map((entry) => '${entry.key + 1}. ${entry.value}')
        .join('\n');
  }

  /// Get word count of answer content
  int get wordCount {
    return content.trim().split(RegExp(r'\s+')).length;
  }

  /// Get estimated reading time in minutes
  int get readingTimeMinutes {
    const averageWordsPerMinute = 200;
    return (wordCount / averageWordsPerMinute).ceil().clamp(1, 30);
  }

  /// Check if answer contains medical advice disclaimer
  bool get hasDisclaimer {
    return disclaimer != null || 
           content.toLowerCase().contains('consult') ||
           content.toLowerCase().contains('medical professional') ||
           content.toLowerCase().contains('doctor');
  }

  /// Get answer summary (first few sentences)
  String getSummary({int maxLength = 200}) {
    if (content.length <= maxLength) return content;
    
    // Try to break at sentence end
    final sentences = content.split('. ');
    var summary = '';
    
    for (final sentence in sentences) {
      if (('$summary$sentence. ').length <= maxLength) {
        summary += '$sentence. ';
      } else {
        break;
      }
    }
    
    if (summary.isEmpty) {
      // Fallback to character limit
      return '${content.substring(0, maxLength)}...';
    }
    
    return summary.trim();
  }

  /// Extract key medical terms from answer
  List<String> get medicalTerms {
    final terms = <String>[];
    final medicalKeywords = [
      'PCOS', 'endometriosis', 'fibroids', 'ovulation', 'estrogen', 'progesterone',
      'insulin resistance', 'thyroid', 'amenorrhea', 'dysmenorrhea', 'menorrhagia',
      'oligomenorrhea', 'perimenopause', 'menopause', 'fertility', 'contraception'
    ];
    
    final contentLower = content.toLowerCase();
    for (final term in medicalKeywords) {
      if (contentLower.contains(term.toLowerCase())) {
        terms.add(term);
      }
    }
    
    return terms;
  }

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerToJson(this);

  Answer copyWith({
    String? answerId,
    String? questionId,
    String? expertId,
    String? content,
    List<String>? references,
    List<String>? attachments,
    DateTime? submittedDate,
    DateTime? lastModified,
    int? upvotes,
    int? downvotes,
    bool? isVerifiedAnswer,
    bool? isAccepted,
    AnswerType? answerType,
    String? disclaimer,
    List<AnswerTag>? tags,
    AnswerMetadata? metadata,
  }) {
    return Answer(
      answerId: answerId ?? this.answerId,
      questionId: questionId ?? this.questionId,
      expertId: expertId ?? this.expertId,
      content: content ?? this.content,
      references: references ?? this.references,
      attachments: attachments ?? this.attachments,
      submittedDate: submittedDate ?? this.submittedDate,
      lastModified: lastModified ?? this.lastModified,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      isVerifiedAnswer: isVerifiedAnswer ?? this.isVerifiedAnswer,
      isAccepted: isAccepted ?? this.isAccepted,
      answerType: answerType ?? this.answerType,
      disclaimer: disclaimer ?? this.disclaimer,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Answer Types
enum AnswerType {
  comprehensive('Comprehensive', 'Detailed answer covering all aspects', '📚'),
  educational('Educational', 'Focuses on education and understanding', '🎓'),
  quick('Quick Response', 'Brief but helpful answer', '⚡'),
  clarification('Clarification', 'Asks for more information or clarifies', '❓'),
  referral('Referral', 'Recommends consulting other healthcare professionals', '👩‍⚕️'),
  emergency('Emergency Response', 'Addresses urgent medical concerns', '🚨');

  const AnswerType(this.displayName, this.description, this.icon);

  final String displayName;
  final String description;
  final String icon;

  /// Get type color for UI
  int get color {
    switch (this) {
      case AnswerType.comprehensive:
        return 0xFF4CAF50; // Green
      case AnswerType.educational:
        return 0xFF2196F3; // Blue
      case AnswerType.quick:
        return 0xFFFF9800; // Orange
      case AnswerType.clarification:
        return 0xFF9C27B0; // Purple
      case AnswerType.referral:
        return 0xFF00BCD4; // Cyan
      case AnswerType.emergency:
        return 0xFFF44336; // Red
    }
  }
}

/// Answer Tags for categorization
enum AnswerTag {
  evidenceBased('Evidence-Based', 'Based on scientific research'),
  clinicalExperience('Clinical Experience', 'Based on clinical experience'),
  generalGuidance('General Guidance', 'General health guidance'),
  lifestyle('Lifestyle', 'Lifestyle recommendations'),
  medication('Medication', 'Medication-related information'),
  diagnostic('Diagnostic', 'Diagnostic information'),
  followUp('Follow-up Required', 'Requires medical follow-up'),
  urgent('Urgent', 'Urgent medical attention needed');

  const AnswerTag(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Get tag color for UI
  int get color {
    switch (this) {
      case AnswerTag.evidenceBased:
        return 0xFF4CAF50; // Green
      case AnswerTag.clinicalExperience:
        return 0xFF2196F3; // Blue
      case AnswerTag.generalGuidance:
        return 0xFF607D8B; // Blue Grey
      case AnswerTag.lifestyle:
        return 0xFFFF9800; // Orange
      case AnswerTag.medication:
        return 0xFF9C27B0; // Purple
      case AnswerTag.diagnostic:
        return 0xFF00BCD4; // Cyan
      case AnswerTag.followUp:
        return 0xFFFF5722; // Deep Orange
      case AnswerTag.urgent:
        return 0xFFF44336; // Red
    }
  }
}

/// Helpfulness Rating
enum HelpfulnessRating {
  poor('Poor', 0xFF9E9E9E),
  fair('Fair', 0xFFFF9800),
  good('Good', 0xFF4CAF50),
  excellent('Excellent', 0xFF2E7D32);

  const HelpfulnessRating(this.displayName, this.color);

  final String displayName;
  final int color;

  String get icon {
    switch (this) {
      case HelpfulnessRating.poor:
        return '😞';
      case HelpfulnessRating.fair:
        return '😐';
      case HelpfulnessRating.good:
        return '😊';
      case HelpfulnessRating.excellent:
        return '😍';
    }
  }
}

/// Answer Metadata for additional context
@JsonSerializable()
class AnswerMetadata {
  final String? sourceType; // 'research', 'clinical_experience', 'guideline'
  final List<String> citations;
  final String? medicalSpecialty;
  final List<String> keywords;
  final String? evidenceLevel; // 'high', 'moderate', 'low'
  final bool requiresFollowUp;
  final String? followUpInstructions;
  final List<String> relatedConditions;
  final Map<String, dynamic> customFields;

  AnswerMetadata({
    this.sourceType,
    this.citations = const [],
    this.medicalSpecialty,
    this.keywords = const [],
    this.evidenceLevel,
    this.requiresFollowUp = false,
    this.followUpInstructions,
    this.relatedConditions = const [],
    this.customFields = const {},
  });

  /// Check if answer has high-quality metadata
  bool get isWellDocumented {
    return sourceType != null && 
           citations.isNotEmpty && 
           keywords.isNotEmpty &&
           evidenceLevel != null;
  }

  /// Get formatted citations
  String get formattedCitations {
    if (citations.isEmpty) return 'No citations provided';
    
    return citations
        .asMap()
        .entries
        .map((entry) => '${entry.key + 1}. ${entry.value}')
        .join('\n');
  }

  /// Get evidence strength score (1-5)
  int get evidenceStrength {
    switch (evidenceLevel?.toLowerCase()) {
      case 'high':
        return 5;
      case 'moderate':
        return 3;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  factory AnswerMetadata.fromJson(Map<String, dynamic> json) => _$AnswerMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerMetadataToJson(this);
}

/// Answer Threading for follow-up responses
@JsonSerializable()
class AnswerThread {
  final String threadId;
  final String parentAnswerId;
  final String questionId;
  final List<Answer> followUpAnswers;
  final DateTime createdDate;
  final bool isActive;

  AnswerThread({
    required this.threadId,
    required this.parentAnswerId,
    required this.questionId,
    this.followUpAnswers = const [],
    required this.createdDate,
    this.isActive = true,
  });

  /// Get total answers in thread
  int get totalAnswers => followUpAnswers.length + 1; // +1 for parent answer

  /// Get most recent answer in thread
  Answer? get mostRecentAnswer {
    if (followUpAnswers.isEmpty) return null;
    
    return followUpAnswers
        .reduce((a, b) => a.submittedDate.isAfter(b.submittedDate) ? a : b);
  }

  /// Check if thread has recent activity
  bool get hasRecentActivity {
    final recentAnswer = mostRecentAnswer;
    if (recentAnswer == null) return false;
    
    return DateTime.now().difference(recentAnswer.submittedDate).inDays < 7;
  }

  factory AnswerThread.fromJson(Map<String, dynamic> json) => _$AnswerThreadFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerThreadToJson(this);
}

/// Answer Feedback from users
@JsonSerializable()
class AnswerFeedback {
  final String feedbackId;
  final String answerId;
  final String userId;
  final FeedbackType type;
  final int rating; // 1-5 stars
  final String? comment;
  final DateTime submittedDate;
  final bool isAnonymous;

  AnswerFeedback({
    required this.feedbackId,
    required this.answerId,
    required this.userId,
    required this.type,
    required this.rating,
    this.comment,
    required this.submittedDate,
    this.isAnonymous = false,
  });

  /// Check if feedback is positive
  bool get isPositive => rating >= 4;

  /// Check if feedback has detailed comment
  bool get hasDetailedComment => comment != null && comment!.length > 20;

  factory AnswerFeedback.fromJson(Map<String, dynamic> json) => _$AnswerFeedbackFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerFeedbackToJson(this);
}

/// Feedback Types
enum FeedbackType {
  helpful('Helpful', 'Answer was helpful'),
  accurate('Accurate', 'Answer was medically accurate'),
  clear('Clear', 'Answer was easy to understand'),
  comprehensive('Comprehensive', 'Answer covered all aspects'),
  timely('Timely', 'Answer was provided quickly'),
  followUp('Follow-up Needed', 'More information needed');

  const FeedbackType(this.displayName, this.description);

  final String displayName;
  final String description;

  String get icon {
    switch (this) {
      case FeedbackType.helpful:
        return '👍';
      case FeedbackType.accurate:
        return '✅';
      case FeedbackType.clear:
        return '💡';
      case FeedbackType.comprehensive:
        return '📝';
      case FeedbackType.timely:
        return '⏰';
      case FeedbackType.followUp:
        return '🔄';
    }
  }
}
