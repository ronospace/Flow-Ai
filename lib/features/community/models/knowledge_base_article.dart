import 'package:json_annotation/json_annotation.dart';

part 'knowledge_base_article.g.dart';

/// Knowledge Base Article Model
/// Represents curated medical content and expert-generated articles
@JsonSerializable()
class KnowledgeBaseArticle {
  final String articleId;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final String authorId;
  final DateTime createdDate;
  final DateTime lastUpdated;
  final int views;
  final double? rating;
  final String? sourceQuestionId;
  final String? sourceAnswerId;
  final bool isPublished;
  final bool isFeatured;
  final ArticleType type;
  final String? summary;
  final List<String> relatedArticles;
  final List<ArticleSection> sections;
  final ArticleMetadata? metadata;

  KnowledgeBaseArticle({
    required this.articleId,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    required this.authorId,
    required this.createdDate,
    required this.lastUpdated,
    this.views = 0,
    this.rating,
    this.sourceQuestionId,
    this.sourceAnswerId,
    this.isPublished = false,
    this.isFeatured = false,
    this.type = ArticleType.educational,
    this.summary,
    this.relatedArticles = const [],
    this.sections = const [],
    this.metadata,
  });

  // Computed properties
  bool get isRecent => DateTime.now().difference(createdDate).inDays < 30;
  bool get isPopular => views > 100 || (rating != null && rating! >= 4.5);
  bool get hasHighRating => rating != null && rating! >= 4.0;
  bool get isOutdated => DateTime.now().difference(lastUpdated).inDays > 365;
  bool get needsReview => isOutdated || (rating != null && rating! < 3.0);
  
  /// Get reading time in minutes based on content length
  int get readingTimeMinutes {
    final wordCount = _getWordCount();
    return (wordCount / 200).ceil().clamp(1, 60); // 200 words per minute
  }

  /// Get article quality score
  double get qualityScore {
    var score = 0.0;
    
    // Content length (optimal: 500-3000 words)
    final wordCount = _getWordCount();
    if (wordCount >= 500 && wordCount <= 3000) {
      score += 2.0;
    } else if (wordCount >= 200) {
      score += 1.0;
    }
    
    // Has sections
    if (sections.isNotEmpty) {
      score += 1.5;
    }
    
    // Has metadata
    if (metadata != null && metadata!.hasReferences) {
      score += 2.0;
    }
    
    // User rating
    if (rating != null) {
      score += rating!;
    }
    
    // View engagement
    if (views > 50) {
      score += 1.0;
    }
    
    // Recent update
    if (!isOutdated) {
      score += 0.5;
    }
    
    return score.clamp(0.0, 10.0);
  }

  /// Get content summary
  String getContentSummary({int maxLength = 300}) {
    if (summary != null && summary!.isNotEmpty) {
      return summary!;
    }
    
    if (content.length <= maxLength) {
      return content;
    }
    
    // Find a good breaking point
    final truncated = content.substring(0, maxLength);
    final lastSentence = truncated.lastIndexOf('.');
    
    if (lastSentence > maxLength * 0.7) {
      return truncated.substring(0, lastSentence + 1);
    }
    
    return '$truncated...';
  }

  /// Get formatted time since creation
  String get timeAgo {
    final duration = DateTime.now().difference(createdDate);
    
    if (duration.inDays > 365) {
      final years = (duration.inDays / 365).floor();
      return '${years}y ago';
    } else if (duration.inDays > 30) {
      final months = (duration.inDays / 30).floor();
      return '${months}mo ago';
    } else if (duration.inDays > 0) {
      return '${duration.inDays}d ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if article matches search query
  bool matchesQuery(String query) {
    final queryLower = query.toLowerCase();
    
    return title.toLowerCase().contains(queryLower) ||
           content.toLowerCase().contains(queryLower) ||
           tags.any((tag) => tag.toLowerCase().contains(queryLower)) ||
           category.toLowerCase().contains(queryLower) ||
           (summary != null && summary!.toLowerCase().contains(queryLower));
  }

  /// Get key topics from content
  List<String> get keyTopics {
    final topics = <String>{};
    
    // Add tags
    topics.addAll(tags);
    
    // Extract medical terms (simplified)
    final medicalTerms = [
      'PCOS', 'endometriosis', 'fibroids', 'ovulation', 'menstruation',
      'fertility', 'pregnancy', 'menopause', 'hormones', 'estrogen',
      'progesterone', 'insulin resistance', 'irregular cycles'
    ];
    
    final contentLower = content.toLowerCase();
    for (final term in medicalTerms) {
      if (contentLower.contains(term.toLowerCase())) {
        topics.add(term);
      }
    }
    
    return topics.take(10).toList();
  }

  /// Get article difficulty level
  DifficultyLevel get difficultyLevel {
    // Simple heuristic based on content complexity
    final wordCount = _getWordCount();
    final hasAdvancedTerms = _hasAdvancedMedicalTerms();
    
    if (hasAdvancedTerms && wordCount > 1500) {
      return DifficultyLevel.advanced;
    } else if (wordCount > 800 || hasAdvancedTerms) {
      return DifficultyLevel.intermediate;
    } else {
      return DifficultyLevel.beginner;
    }
  }

  /// Check if article is comprehensive
  bool get isComprehensive {
    return _getWordCount() >= 1000 &&
           sections.length >= 3 &&
           metadata?.hasReferences == true;
  }

  int _getWordCount() {
    return content.trim().split(RegExp(r'\s+')).length;
  }

  bool _hasAdvancedMedicalTerms() {
    const advancedTerms = [
      'pathophysiology', 'endocrinology', 'pharmacology',
      'differential diagnosis', 'contraindications'
    ];
    
    final contentLower = content.toLowerCase();
    return advancedTerms.any((term) => contentLower.contains(term));
  }

  factory KnowledgeBaseArticle.fromJson(Map<String, dynamic> json) => 
      _$KnowledgeBaseArticleFromJson(json);
  Map<String, dynamic> toJson() => _$KnowledgeBaseArticleToJson(this);

  KnowledgeBaseArticle copyWith({
    String? articleId,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    String? authorId,
    DateTime? createdDate,
    DateTime? lastUpdated,
    int? views,
    double? rating,
    String? sourceQuestionId,
    String? sourceAnswerId,
    bool? isPublished,
    bool? isFeatured,
    ArticleType? type,
    String? summary,
    List<String>? relatedArticles,
    List<ArticleSection>? sections,
    ArticleMetadata? metadata,
  }) {
    return KnowledgeBaseArticle(
      articleId: articleId ?? this.articleId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      authorId: authorId ?? this.authorId,
      createdDate: createdDate ?? this.createdDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      views: views ?? this.views,
      rating: rating ?? this.rating,
      sourceQuestionId: sourceQuestionId ?? this.sourceQuestionId,
      sourceAnswerId: sourceAnswerId ?? this.sourceAnswerId,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      type: type ?? this.type,
      summary: summary ?? this.summary,
      relatedArticles: relatedArticles ?? this.relatedArticles,
      sections: sections ?? this.sections,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Article Types
enum ArticleType {
  educational('Educational', 'General educational content', '📚'),
  clinical('Clinical', 'Clinical guidelines and protocols', '🩺'),
  faq('FAQ', 'Frequently asked questions', '❓'),
  guide('How-to Guide', 'Step-by-step guides and instructions', '📋'),
  research('Research Summary', 'Research findings and analysis', '🔬'),
  news('News & Updates', 'Latest news and medical updates', '📰'),
  expert('Expert Opinion', 'Expert insights and perspectives', '👩‍⚕️');

  const ArticleType(this.displayName, this.description, this.icon);

  final String displayName;
  final String description;
  final String icon;

  /// Get type color for UI
  int get color {
    switch (this) {
      case ArticleType.educational:
        return 0xFF4CAF50; // Green
      case ArticleType.clinical:
        return 0xFF2196F3; // Blue
      case ArticleType.faq:
        return 0xFFFF9800; // Orange
      case ArticleType.guide:
        return 0xFF9C27B0; // Purple
      case ArticleType.research:
        return 0xFF00BCD4; // Cyan
      case ArticleType.news:
        return 0xFFFF5722; // Deep Orange
      case ArticleType.expert:
        return 0xFF795548; // Brown
    }
  }
}

/// Difficulty Levels
enum DifficultyLevel {
  beginner('Beginner', 'Easy to understand for general audience', '🟢'),
  intermediate('Intermediate', 'Some medical knowledge helpful', '🟡'),
  advanced('Advanced', 'Medical background recommended', '🔴');

  const DifficultyLevel(this.displayName, this.description, this.icon);

  final String displayName;
  final String description;
  final String icon;

  /// Get level color
  int get color {
    switch (this) {
      case DifficultyLevel.beginner:
        return 0xFF4CAF50; // Green
      case DifficultyLevel.intermediate:
        return 0xFFFF9800; // Orange
      case DifficultyLevel.advanced:
        return 0xFFF44336; // Red
    }
  }
}

/// Article Section for structured content
@JsonSerializable()
class ArticleSection {
  final String sectionId;
  final String title;
  final String content;
  final int order;
  final SectionType type;
  final List<String>? bulletPoints;
  final String? imageUrl;
  final String? videoUrl;

  ArticleSection({
    required this.sectionId,
    required this.title,
    required this.content,
    required this.order,
    this.type = SectionType.text,
    this.bulletPoints,
    this.imageUrl,
    this.videoUrl,
  });

  /// Check if section has media content
  bool get hasMedia => imageUrl != null || videoUrl != null;

  /// Get section word count
  int get wordCount => content.trim().split(RegExp(r'\s+')).length;

  factory ArticleSection.fromJson(Map<String, dynamic> json) => _$ArticleSectionFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleSectionToJson(this);
}

/// Section Types
enum SectionType {
  text('Text', 'Regular text content'),
  list('List', 'Bullet point or numbered list'),
  image('Image', 'Image with caption'),
  video('Video', 'Video content'),
  quote('Quote', 'Featured quote or callout'),
  warning('Warning', 'Important warning or disclaimer'),
  tip('Tip', 'Helpful tip or advice');

  const SectionType(this.displayName, this.description);

  final String displayName;
  final String description;

  String get icon {
    switch (this) {
      case SectionType.text:
        return '📝';
      case SectionType.list:
        return '📋';
      case SectionType.image:
        return '🖼️';
      case SectionType.video:
        return '🎥';
      case SectionType.quote:
        return '💬';
      case SectionType.warning:
        return '⚠️';
      case SectionType.tip:
        return '💡';
    }
  }
}

/// Article Metadata
@JsonSerializable()
class ArticleMetadata {
  final String? authorBio;
  final List<String> references;
  final List<String> sources;
  final DateTime? lastMedicalReview;
  final String? reviewedBy;
  final String? evidenceLevel;
  final List<String> relatedConditions;
  final String? targetAudience;
  final List<String> keywords;
  final String? disclaimerText;
  final Map<String, dynamic> customFields;

  ArticleMetadata({
    this.authorBio,
    this.references = const [],
    this.sources = const [],
    this.lastMedicalReview,
    this.reviewedBy,
    this.evidenceLevel,
    this.relatedConditions = const [],
    this.targetAudience,
    this.keywords = const [],
    this.disclaimerText,
    this.customFields = const {},
  });

  /// Check if article has references
  bool get hasReferences => references.isNotEmpty || sources.isNotEmpty;

  /// Check if medical review is current (within 2 years)
  bool get haCurrentMedicalReview {
    if (lastMedicalReview == null) return false;
    return DateTime.now().difference(lastMedicalReview!).inDays < 730;
  }

  /// Get formatted references
  String get formattedReferences {
    if (references.isEmpty) return '';
    
    return references
        .asMap()
        .entries
        .map((entry) => '${entry.key + 1}. ${entry.value}')
        .join('\n');
  }

  /// Get evidence quality score
  int get evidenceQuality {
    var score = 0;
    
    if (hasReferences) score += 3;
    if (haCurrentMedicalReview) score += 2;
    if (evidenceLevel == 'high') score += 3;
    else if (evidenceLevel == 'moderate') score += 2;
    else if (evidenceLevel == 'low') score += 1;
    
    return score.clamp(0, 8);
  }

  factory ArticleMetadata.fromJson(Map<String, dynamic> json) => _$ArticleMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleMetadataToJson(this);
}

/// Article Filter Options
class ArticleFilters {
  final List<String>? categories;
  final List<ArticleType>? types;
  final DifficultyLevel? maxDifficulty;
  final int? minRating;
  final bool? isFeatured;
  final bool? hasReferences;
  final DateTime? publishedAfter;
  final List<String>? tags;
  final String? searchQuery;
  final String? authorId;

  ArticleFilters({
    this.categories,
    this.types,
    this.maxDifficulty,
    this.minRating,
    this.isFeatured,
    this.hasReferences,
    this.publishedAfter,
    this.tags,
    this.searchQuery,
    this.authorId,
  });

  /// Check if an article matches these filters
  bool matches(KnowledgeBaseArticle article) {
    // Category filter
    if (categories != null && !categories!.contains(article.category)) {
      return false;
    }

    // Type filter
    if (types != null && !types!.contains(article.type)) {
      return false;
    }

    // Difficulty filter
    if (maxDifficulty != null && article.difficultyLevel.index > maxDifficulty!.index) {
      return false;
    }

    // Rating filter
    if (minRating != null && (article.rating == null || article.rating! < minRating!)) {
      return false;
    }

    // Featured filter
    if (isFeatured != null && article.isFeatured != isFeatured!) {
      return false;
    }

    // References filter
    if (hasReferences != null && (article.metadata?.hasReferences ?? false) != hasReferences!) {
      return false;
    }

    // Published date filter
    if (publishedAfter != null && article.createdDate.isBefore(publishedAfter!)) {
      return false;
    }

    // Tags filter
    if (tags != null && !tags!.any((tag) => article.tags.contains(tag))) {
      return false;
    }

    // Author filter
    if (authorId != null && article.authorId != authorId!) {
      return false;
    }

    // Search query filter
    if (searchQuery != null && !article.matchesQuery(searchQuery!)) {
      return false;
    }

    return true;
  }
}

/// Article Statistics
@JsonSerializable()
class ArticleStatistics {
  final String articleId;
  final int totalViews;
  final int uniqueViews;
  final int shares;
  final int bookmarks;
  final double averageRating;
  final int totalRatings;
  final Map<String, int> viewsByDay;
  final Map<String, int> viewsByRegion;
  final DateTime lastUpdated;

  ArticleStatistics({
    required this.articleId,
    this.totalViews = 0,
    this.uniqueViews = 0,
    this.shares = 0,
    this.bookmarks = 0,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.viewsByDay = const {},
    this.viewsByRegion = const {},
    required this.lastUpdated,
  });

  /// Get engagement score
  double get engagementScore {
    if (totalViews == 0) return 0.0;
    
    final shareRate = shares / totalViews;
    final bookmarkRate = bookmarks / totalViews;
    final ratingRate = totalRatings / totalViews;
    
    return (shareRate * 5 + bookmarkRate * 3 + ratingRate * 2 + averageRating).clamp(0.0, 10.0);
  }

  /// Get trending score
  double get trendingScore {
    // Calculate views in last 7 days
    final recentViews = _getRecentViews(7);
    final totalRecentViews = recentViews.values.fold(0, (sum, views) => sum + views);
    
    return (totalRecentViews * 0.7 + engagementScore * 0.3).clamp(0.0, 100.0);
  }

  Map<String, int> _getRecentViews(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentViews = <String, int>{};
    
    viewsByDay.forEach((date, views) {
      final viewDate = DateTime.tryParse(date);
      if (viewDate != null && viewDate.isAfter(cutoffDate)) {
        recentViews[date] = views;
      }
    });
    
    return recentViews;
  }

  factory ArticleStatistics.fromJson(Map<String, dynamic> json) => _$ArticleStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleStatisticsToJson(this);
}
