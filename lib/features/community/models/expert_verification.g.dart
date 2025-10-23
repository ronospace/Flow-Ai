// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expert_verification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpertVerification _$ExpertVerificationFromJson(Map<String, dynamic> json) =>
    ExpertVerification(
      verificationId: json['verificationId'] as String,
      userId: json['userId'] as String,
      applicantInfo: ExpertApplicantInfo.fromJson(
        json['applicantInfo'] as Map<String, dynamic>,
      ),
      documents: (json['documents'] as List<dynamic>)
          .map(
            (e) =>
                ExpertVerificationDocument.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      status: $enumDecode(_$VerificationStatusEnumMap, json['status']),
      submittedDate: DateTime.parse(json['submittedDate'] as String),
      reviewedDate: json['reviewedDate'] == null
          ? null
          : DateTime.parse(json['reviewedDate'] as String),
      reviewedBy: json['reviewedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      notes:
          (json['notes'] as List<dynamic>?)
              ?.map((e) => VerificationNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      score: json['score'] == null
          ? null
          : VerificationScore.fromJson(json['score'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExpertVerificationToJson(ExpertVerification instance) =>
    <String, dynamic>{
      'verificationId': instance.verificationId,
      'userId': instance.userId,
      'applicantInfo': instance.applicantInfo,
      'documents': instance.documents,
      'status': _$VerificationStatusEnumMap[instance.status]!,
      'submittedDate': instance.submittedDate.toIso8601String(),
      'reviewedDate': instance.reviewedDate?.toIso8601String(),
      'reviewedBy': instance.reviewedBy,
      'rejectionReason': instance.rejectionReason,
      'notes': instance.notes,
      'score': instance.score,
    };

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 'pending',
  VerificationStatus.underReview: 'underReview',
  VerificationStatus.additionalInfoRequired: 'additionalInfoRequired',
  VerificationStatus.approved: 'approved',
  VerificationStatus.rejected: 'rejected',
  VerificationStatus.suspended: 'suspended',
};

ExpertApplicantInfo _$ExpertApplicantInfoFromJson(Map<String, dynamic> json) =>
    ExpertApplicantInfo(
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      specialty: json['specialty'] as String,
      licenseNumber: json['licenseNumber'] as String,
      institution: json['institution'] as String,
      credentials: (json['credentials'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      bio: json['bio'] as String,
      linkedInProfile: json['linkedInProfile'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      languages:
          (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['English'],
      yearsOfExperience: (json['yearsOfExperience'] as num?)?.toInt(),
      subspecialty: json['subspecialty'] as String?,
    );

Map<String, dynamic> _$ExpertApplicantInfoToJson(
  ExpertApplicantInfo instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'email': instance.email,
  'specialty': instance.specialty,
  'licenseNumber': instance.licenseNumber,
  'institution': instance.institution,
  'credentials': instance.credentials,
  'bio': instance.bio,
  'linkedInProfile': instance.linkedInProfile,
  'websiteUrl': instance.websiteUrl,
  'phoneNumber': instance.phoneNumber,
  'address': instance.address,
  'languages': instance.languages,
  'yearsOfExperience': instance.yearsOfExperience,
  'subspecialty': instance.subspecialty,
};

ExpertVerificationDocument _$ExpertVerificationDocumentFromJson(
  Map<String, dynamic> json,
) => ExpertVerificationDocument(
  documentId: json['documentId'] as String,
  type: $enumDecode(_$DocumentTypeEnumMap, json['type']),
  fileName: json['fileName'] as String,
  fileUrl: json['fileUrl'] as String,
  description: json['description'] as String?,
  uploadedDate: DateTime.parse(json['uploadedDate'] as String),
  status:
      $enumDecodeNullable(_$DocumentStatusEnumMap, json['status']) ??
      DocumentStatus.pending,
  verificationNotes: json['verificationNotes'] as String?,
);

Map<String, dynamic> _$ExpertVerificationDocumentToJson(
  ExpertVerificationDocument instance,
) => <String, dynamic>{
  'documentId': instance.documentId,
  'type': _$DocumentTypeEnumMap[instance.type]!,
  'fileName': instance.fileName,
  'fileUrl': instance.fileUrl,
  'description': instance.description,
  'uploadedDate': instance.uploadedDate.toIso8601String(),
  'status': _$DocumentStatusEnumMap[instance.status]!,
  'verificationNotes': instance.verificationNotes,
};

const _$DocumentTypeEnumMap = {
  DocumentType.medicalLicense: 'medicalLicense',
  DocumentType.educationCertificate: 'educationCertificate',
  DocumentType.professionalPhoto: 'professionalPhoto',
  DocumentType.boardCertification: 'boardCertification',
  DocumentType.malpracticeInsurance: 'malpracticeInsurance',
  DocumentType.hospitalAffiliation: 'hospitalAffiliation',
  DocumentType.cv: 'cv',
  DocumentType.referenceLetters: 'referenceLetters',
};

const _$DocumentStatusEnumMap = {
  DocumentStatus.pending: 'pending',
  DocumentStatus.verified: 'verified',
  DocumentStatus.rejected: 'rejected',
  DocumentStatus.expired: 'expired',
};

VerificationNote _$VerificationNoteFromJson(Map<String, dynamic> json) =>
    VerificationNote(
      noteId: json['noteId'] as String,
      reviewerId: json['reviewerId'] as String,
      content: json['content'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      type: $enumDecode(_$NoteTypeEnumMap, json['type']),
      isInternal: json['isInternal'] as bool? ?? true,
    );

Map<String, dynamic> _$VerificationNoteToJson(VerificationNote instance) =>
    <String, dynamic>{
      'noteId': instance.noteId,
      'reviewerId': instance.reviewerId,
      'content': instance.content,
      'createdDate': instance.createdDate.toIso8601String(),
      'type': _$NoteTypeEnumMap[instance.type]!,
      'isInternal': instance.isInternal,
    };

const _$NoteTypeEnumMap = {
  NoteType.general: 'general',
  NoteType.concern: 'concern',
  NoteType.clarification: 'clarification',
  NoteType.approved: 'approved',
  NoteType.rejected: 'rejected',
};

VerificationScore _$VerificationScoreFromJson(Map<String, dynamic> json) =>
    VerificationScore(
      credentialsScore: (json['credentialsScore'] as num).toInt(),
      experienceScore: (json['experienceScore'] as num).toInt(),
      documentationScore: (json['documentationScore'] as num).toInt(),
      professionalismScore: (json['professionalismScore'] as num).toInt(),
      scoreNotes: json['scoreNotes'] as String?,
      scoredDate: DateTime.parse(json['scoredDate'] as String),
      scoredBy: json['scoredBy'] as String,
    );

Map<String, dynamic> _$VerificationScoreToJson(VerificationScore instance) =>
    <String, dynamic>{
      'credentialsScore': instance.credentialsScore,
      'experienceScore': instance.experienceScore,
      'documentationScore': instance.documentationScore,
      'professionalismScore': instance.professionalismScore,
      'scoreNotes': instance.scoreNotes,
      'scoredDate': instance.scoredDate.toIso8601String(),
      'scoredBy': instance.scoredBy,
    };

VerificationChecklistItem _$VerificationChecklistItemFromJson(
  Map<String, dynamic> json,
) => VerificationChecklistItem(
  itemId: json['itemId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  isRequired: json['isRequired'] as bool? ?? true,
  isCompleted: json['isCompleted'] as bool? ?? false,
  completedDate: json['completedDate'] == null
      ? null
      : DateTime.parse(json['completedDate'] as String),
  completedBy: json['completedBy'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$VerificationChecklistItemToJson(
  VerificationChecklistItem instance,
) => <String, dynamic>{
  'itemId': instance.itemId,
  'title': instance.title,
  'description': instance.description,
  'isRequired': instance.isRequired,
  'isCompleted': instance.isCompleted,
  'completedDate': instance.completedDate?.toIso8601String(),
  'completedBy': instance.completedBy,
  'notes': instance.notes,
};
