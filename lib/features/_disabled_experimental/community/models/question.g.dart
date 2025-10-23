// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  questionId: json['questionId'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  category: $enumDecode(_$QuestionCategoryEnumMap, json['category']),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  preferredExpertId: json['preferredExpertId'] as String?,
  isAnonymous: json['isAnonymous'] as bool? ?? false,
  isUrgent: json['isUrgent'] as bool? ?? false,
  status: $enumDecode(_$QuestionStatusEnumMap, json['status']),
  submittedDate: DateTime.parse(json['submittedDate'] as String),
  lastModified: json['lastModified'] == null
      ? null
      : DateTime.parse(json['lastModified'] as String),
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
  downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
  answers:
      (json['answers'] as List<dynamic>?)
          ?.map((e) => Answer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  acceptedAnswerId: json['acceptedAnswerId'] as String?,
  attachedImages:
      (json['attachedImages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  metadata: json['metadata'] == null
      ? null
      : QuestionMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'questionId': instance.questionId,
  'userId': instance.userId,
  'title': instance.title,
  'content': instance.content,
  'category': _$QuestionCategoryEnumMap[instance.category]!,
  'tags': instance.tags,
  'preferredExpertId': instance.preferredExpertId,
  'isAnonymous': instance.isAnonymous,
  'isUrgent': instance.isUrgent,
  'status': _$QuestionStatusEnumMap[instance.status]!,
  'submittedDate': instance.submittedDate.toIso8601String(),
  'lastModified': instance.lastModified?.toIso8601String(),
  'viewCount': instance.viewCount,
  'upvotes': instance.upvotes,
  'downvotes': instance.downvotes,
  'answers': instance.answers,
  'acceptedAnswerId': instance.acceptedAnswerId,
  'attachedImages': instance.attachedImages,
  'metadata': instance.metadata,
};

const _$QuestionCategoryEnumMap = {
  QuestionCategory.cycleHealth: 'cycleHealth',
  QuestionCategory.pcos: 'pcos',
  QuestionCategory.fertility: 'fertility',
  QuestionCategory.pregnancy: 'pregnancy',
  QuestionCategory.contraception: 'contraception',
  QuestionCategory.menopause: 'menopause',
  QuestionCategory.pain: 'pain',
  QuestionCategory.lifestyle: 'lifestyle',
  QuestionCategory.mental: 'mental',
  QuestionCategory.emergency: 'emergency',
  QuestionCategory.general: 'general',
};

const _$QuestionStatusEnumMap = {
  QuestionStatus.draft: 'draft',
  QuestionStatus.open: 'open',
  QuestionStatus.answered: 'answered',
  QuestionStatus.resolved: 'resolved',
  QuestionStatus.closed: 'closed',
  QuestionStatus.flagged: 'flagged',
  QuestionStatus.archived: 'archived',
};

QuestionMetadata _$QuestionMetadataFromJson(Map<String, dynamic> json) =>
    QuestionMetadata(
      userAge: json['userAge'] as String?,
      location: json['location'] as String?,
      symptoms:
          (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      symptomStartDate: json['symptomStartDate'] == null
          ? null
          : DateTime.parse(json['symptomStartDate'] as String),
      medicalHistory: json['medicalHistory'] as String?,
      medications:
          (json['medications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      additionalContext: json['additionalContext'] as String?,
      consentForResearch: json['consentForResearch'] as bool? ?? false,
      customFields: json['customFields'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$QuestionMetadataToJson(QuestionMetadata instance) =>
    <String, dynamic>{
      'userAge': instance.userAge,
      'location': instance.location,
      'symptoms': instance.symptoms,
      'symptomStartDate': instance.symptomStartDate?.toIso8601String(),
      'medicalHistory': instance.medicalHistory,
      'medications': instance.medications,
      'additionalContext': instance.additionalContext,
      'consentForResearch': instance.consentForResearch,
      'customFields': instance.customFields,
    };
