// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer _$AnswerFromJson(Map<String, dynamic> json) => Answer(
  answerId: json['answerId'] as String,
  questionId: json['questionId'] as String,
  expertId: json['expertId'] as String,
  content: json['content'] as String,
  references:
      (json['references'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  submittedDate: DateTime.parse(json['submittedDate'] as String),
  lastModified: json['lastModified'] == null
      ? null
      : DateTime.parse(json['lastModified'] as String),
  upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
  downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
  isVerifiedAnswer: json['isVerifiedAnswer'] as bool? ?? true,
  isAccepted: json['isAccepted'] as bool? ?? false,
  answerType:
      $enumDecodeNullable(_$AnswerTypeEnumMap, json['answerType']) ??
      AnswerType.comprehensive,
  disclaimer: json['disclaimer'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$AnswerTagEnumMap, e))
          .toList() ??
      const [],
  metadata: json['metadata'] == null
      ? null
      : AnswerMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
  'answerId': instance.answerId,
  'questionId': instance.questionId,
  'expertId': instance.expertId,
  'content': instance.content,
  'references': instance.references,
  'attachments': instance.attachments,
  'submittedDate': instance.submittedDate.toIso8601String(),
  'lastModified': instance.lastModified?.toIso8601String(),
  'upvotes': instance.upvotes,
  'downvotes': instance.downvotes,
  'isVerifiedAnswer': instance.isVerifiedAnswer,
  'isAccepted': instance.isAccepted,
  'answerType': _$AnswerTypeEnumMap[instance.answerType]!,
  'disclaimer': instance.disclaimer,
  'tags': instance.tags.map((e) => _$AnswerTagEnumMap[e]!).toList(),
  'metadata': instance.metadata,
};

const _$AnswerTypeEnumMap = {
  AnswerType.comprehensive: 'comprehensive',
  AnswerType.educational: 'educational',
  AnswerType.quick: 'quick',
  AnswerType.clarification: 'clarification',
  AnswerType.referral: 'referral',
  AnswerType.emergency: 'emergency',
};

const _$AnswerTagEnumMap = {
  AnswerTag.evidenceBased: 'evidenceBased',
  AnswerTag.clinicalExperience: 'clinicalExperience',
  AnswerTag.generalGuidance: 'generalGuidance',
  AnswerTag.lifestyle: 'lifestyle',
  AnswerTag.medication: 'medication',
  AnswerTag.diagnostic: 'diagnostic',
  AnswerTag.followUp: 'followUp',
  AnswerTag.urgent: 'urgent',
};

AnswerMetadata _$AnswerMetadataFromJson(
  Map<String, dynamic> json,
) => AnswerMetadata(
  sourceType: json['sourceType'] as String?,
  citations:
      (json['citations'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  medicalSpecialty: json['medicalSpecialty'] as String?,
  keywords:
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  evidenceLevel: json['evidenceLevel'] as String?,
  requiresFollowUp: json['requiresFollowUp'] as bool? ?? false,
  followUpInstructions: json['followUpInstructions'] as String?,
  relatedConditions:
      (json['relatedConditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  customFields: json['customFields'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$AnswerMetadataToJson(AnswerMetadata instance) =>
    <String, dynamic>{
      'sourceType': instance.sourceType,
      'citations': instance.citations,
      'medicalSpecialty': instance.medicalSpecialty,
      'keywords': instance.keywords,
      'evidenceLevel': instance.evidenceLevel,
      'requiresFollowUp': instance.requiresFollowUp,
      'followUpInstructions': instance.followUpInstructions,
      'relatedConditions': instance.relatedConditions,
      'customFields': instance.customFields,
    };

AnswerThread _$AnswerThreadFromJson(Map<String, dynamic> json) => AnswerThread(
  threadId: json['threadId'] as String,
  parentAnswerId: json['parentAnswerId'] as String,
  questionId: json['questionId'] as String,
  followUpAnswers:
      (json['followUpAnswers'] as List<dynamic>?)
          ?.map((e) => Answer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdDate: DateTime.parse(json['createdDate'] as String),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$AnswerThreadToJson(AnswerThread instance) =>
    <String, dynamic>{
      'threadId': instance.threadId,
      'parentAnswerId': instance.parentAnswerId,
      'questionId': instance.questionId,
      'followUpAnswers': instance.followUpAnswers,
      'createdDate': instance.createdDate.toIso8601String(),
      'isActive': instance.isActive,
    };

AnswerFeedback _$AnswerFeedbackFromJson(Map<String, dynamic> json) =>
    AnswerFeedback(
      feedbackId: json['feedbackId'] as String,
      answerId: json['answerId'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$FeedbackTypeEnumMap, json['type']),
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      submittedDate: DateTime.parse(json['submittedDate'] as String),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );

Map<String, dynamic> _$AnswerFeedbackToJson(AnswerFeedback instance) =>
    <String, dynamic>{
      'feedbackId': instance.feedbackId,
      'answerId': instance.answerId,
      'userId': instance.userId,
      'type': _$FeedbackTypeEnumMap[instance.type]!,
      'rating': instance.rating,
      'comment': instance.comment,
      'submittedDate': instance.submittedDate.toIso8601String(),
      'isAnonymous': instance.isAnonymous,
    };

const _$FeedbackTypeEnumMap = {
  FeedbackType.helpful: 'helpful',
  FeedbackType.accurate: 'accurate',
  FeedbackType.clear: 'clear',
  FeedbackType.comprehensive: 'comprehensive',
  FeedbackType.timely: 'timely',
  FeedbackType.followUp: 'followUp',
};
