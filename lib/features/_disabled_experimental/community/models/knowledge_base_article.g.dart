// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_base_article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KnowledgeBaseArticle _$KnowledgeBaseArticleFromJson(
  Map<String, dynamic> json,
) => KnowledgeBaseArticle(
  articleId: json['articleId'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  category: json['category'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  authorId: json['authorId'] as String,
  createdDate: DateTime.parse(json['createdDate'] as String),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  views: (json['views'] as num?)?.toInt() ?? 0,
  rating: (json['rating'] as num?)?.toDouble(),
  sourceQuestionId: json['sourceQuestionId'] as String?,
  sourceAnswerId: json['sourceAnswerId'] as String?,
  isPublished: json['isPublished'] as bool? ?? false,
  isFeatured: json['isFeatured'] as bool? ?? false,
  type:
      $enumDecodeNullable(_$ArticleTypeEnumMap, json['type']) ??
      ArticleType.educational,
  summary: json['summary'] as String?,
  relatedArticles:
      (json['relatedArticles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  sections:
      (json['sections'] as List<dynamic>?)
          ?.map((e) => ArticleSection.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  metadata: json['metadata'] == null
      ? null
      : ArticleMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$KnowledgeBaseArticleToJson(
  KnowledgeBaseArticle instance,
) => <String, dynamic>{
  'articleId': instance.articleId,
  'title': instance.title,
  'content': instance.content,
  'category': instance.category,
  'tags': instance.tags,
  'authorId': instance.authorId,
  'createdDate': instance.createdDate.toIso8601String(),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'views': instance.views,
  'rating': instance.rating,
  'sourceQuestionId': instance.sourceQuestionId,
  'sourceAnswerId': instance.sourceAnswerId,
  'isPublished': instance.isPublished,
  'isFeatured': instance.isFeatured,
  'type': _$ArticleTypeEnumMap[instance.type]!,
  'summary': instance.summary,
  'relatedArticles': instance.relatedArticles,
  'sections': instance.sections,
  'metadata': instance.metadata,
};

const _$ArticleTypeEnumMap = {
  ArticleType.educational: 'educational',
  ArticleType.clinical: 'clinical',
  ArticleType.faq: 'faq',
  ArticleType.guide: 'guide',
  ArticleType.research: 'research',
  ArticleType.news: 'news',
  ArticleType.expert: 'expert',
};

ArticleSection _$ArticleSectionFromJson(Map<String, dynamic> json) =>
    ArticleSection(
      sectionId: json['sectionId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      order: (json['order'] as num).toInt(),
      type:
          $enumDecodeNullable(_$SectionTypeEnumMap, json['type']) ??
          SectionType.text,
      bulletPoints: (json['bulletPoints'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );

Map<String, dynamic> _$ArticleSectionToJson(ArticleSection instance) =>
    <String, dynamic>{
      'sectionId': instance.sectionId,
      'title': instance.title,
      'content': instance.content,
      'order': instance.order,
      'type': _$SectionTypeEnumMap[instance.type]!,
      'bulletPoints': instance.bulletPoints,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
    };

const _$SectionTypeEnumMap = {
  SectionType.text: 'text',
  SectionType.list: 'list',
  SectionType.image: 'image',
  SectionType.video: 'video',
  SectionType.quote: 'quote',
  SectionType.warning: 'warning',
  SectionType.tip: 'tip',
};

ArticleMetadata _$ArticleMetadataFromJson(
  Map<String, dynamic> json,
) => ArticleMetadata(
  authorBio: json['authorBio'] as String?,
  references:
      (json['references'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  sources:
      (json['sources'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  lastMedicalReview: json['lastMedicalReview'] == null
      ? null
      : DateTime.parse(json['lastMedicalReview'] as String),
  reviewedBy: json['reviewedBy'] as String?,
  evidenceLevel: json['evidenceLevel'] as String?,
  relatedConditions:
      (json['relatedConditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  targetAudience: json['targetAudience'] as String?,
  keywords:
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  disclaimerText: json['disclaimerText'] as String?,
  customFields: json['customFields'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$ArticleMetadataToJson(ArticleMetadata instance) =>
    <String, dynamic>{
      'authorBio': instance.authorBio,
      'references': instance.references,
      'sources': instance.sources,
      'lastMedicalReview': instance.lastMedicalReview?.toIso8601String(),
      'reviewedBy': instance.reviewedBy,
      'evidenceLevel': instance.evidenceLevel,
      'relatedConditions': instance.relatedConditions,
      'targetAudience': instance.targetAudience,
      'keywords': instance.keywords,
      'disclaimerText': instance.disclaimerText,
      'customFields': instance.customFields,
    };

ArticleStatistics _$ArticleStatisticsFromJson(Map<String, dynamic> json) =>
    ArticleStatistics(
      articleId: json['articleId'] as String,
      totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
      uniqueViews: (json['uniqueViews'] as num?)?.toInt() ?? 0,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      bookmarks: (json['bookmarks'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (json['totalRatings'] as num?)?.toInt() ?? 0,
      viewsByDay:
          (json['viewsByDay'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      viewsByRegion:
          (json['viewsByRegion'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$ArticleStatisticsToJson(ArticleStatistics instance) =>
    <String, dynamic>{
      'articleId': instance.articleId,
      'totalViews': instance.totalViews,
      'uniqueViews': instance.uniqueViews,
      'shares': instance.shares,
      'bookmarks': instance.bookmarks,
      'averageRating': instance.averageRating,
      'totalRatings': instance.totalRatings,
      'viewsByDay': instance.viewsByDay,
      'viewsByRegion': instance.viewsByRegion,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
