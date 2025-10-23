import 'package:json_annotation/json_annotation.dart';

part 'expert_verification.g.dart';

/// Expert Verification Model
/// Handles the verification process for healthcare professionals
@JsonSerializable()
class ExpertVerification {
  final String verificationId;
  final String userId;
  final ExpertApplicantInfo applicantInfo;
  final List<ExpertVerificationDocument> documents;
  final VerificationStatus status;
  final DateTime submittedDate;
  final DateTime? reviewedDate;
  final String? reviewedBy;
  final String? rejectionReason;
  final List<VerificationNote> notes;
  final VerificationScore? score;

  ExpertVerification({
    required this.verificationId,
    required this.userId,
    required this.applicantInfo,
    required this.documents,
    required this.status,
    required this.submittedDate,
    this.reviewedDate,
    this.reviewedBy,
    this.rejectionReason,
    this.notes = const [],
    this.score,
  });

  // Computed properties
  Duration get timeSinceSubmission => DateTime.now().difference(submittedDate);
  bool get isPending => status == VerificationStatus.pending;
  bool get isApproved => status == VerificationStatus.approved;
  bool get isRejected => status == VerificationStatus.rejected;
  bool get isComplete => documents.isNotEmpty && applicantInfo.isComplete;
  
  /// Get days since submission
  int get daysSinceSubmission => timeSinceSubmission.inDays;

  /// Check if verification is overdue for review
  bool get isOverdue => isPending && daysSinceSubmission > 7;

  /// Get completion percentage
  double get completionPercentage {
    var completed = 0;
    var total = 6; // Basic required fields

    // Check basic info completion
    if (applicantInfo.fullName.isNotEmpty) completed++;
    if (applicantInfo.email.isNotEmpty) completed++;
    if (applicantInfo.licenseNumber.isNotEmpty) completed++;
    if (applicantInfo.institution.isNotEmpty) completed++;
    if (applicantInfo.specialty.isNotEmpty) completed++;
    if (applicantInfo.bio.isNotEmpty) completed++;

    // Check documents
    total += 3; // Medical license, education, professional photo
    if (hasDocument(DocumentType.medicalLicense)) completed++;
    if (hasDocument(DocumentType.educationCertificate)) completed++;
    if (hasDocument(DocumentType.professionalPhoto)) completed++;

    return completed / total;
  }

  /// Check if specific document type exists
  bool hasDocument(DocumentType type) {
    return documents.any((doc) => doc.type == type);
  }

  /// Get document by type
  ExpertVerificationDocument? getDocument(DocumentType type) {
    try {
      return documents.firstWhere((doc) => doc.type == type);
    } catch (e) {
      return null;
    }
  }

  /// Get verification priority level
  VerificationPriority get priority {
    if (applicantInfo.isEmergencySpecialist) return VerificationPriority.urgent;
    if (applicantInfo.isHighDemandSpecialty) return VerificationPriority.high;
    if (daysSinceSubmission > 14) return VerificationPriority.high;
    if (daysSinceSubmission > 7) return VerificationPriority.medium;
    return VerificationPriority.normal;
  }

  /// Get formatted status message
  String get statusMessage {
    switch (status) {
      case VerificationStatus.pending:
        return 'Under review - typically takes 3-5 business days';
      case VerificationStatus.approved:
        return 'Verification approved - welcome to our expert community!';
      case VerificationStatus.rejected:
        return 'Application not approved: ${rejectionReason ?? 'Please review requirements'}';
      case VerificationStatus.underReview:
        return 'Currently being reviewed by our medical verification team';
      case VerificationStatus.additionalInfoRequired:
        return 'Additional information or documents required';
      case VerificationStatus.suspended:
        return 'Verification suspended - please contact support';
    }
  }

  factory ExpertVerification.fromJson(Map<String, dynamic> json) => _$ExpertVerificationFromJson(json);
  Map<String, dynamic> toJson() => _$ExpertVerificationToJson(this);
}

/// Expert Applicant Information
@JsonSerializable()
class ExpertApplicantInfo {
  final String fullName;
  final String email;
  final String specialty;
  final String licenseNumber;
  final String institution;
  final List<String> credentials;
  final String bio;
  final String? linkedInProfile;
  final String? websiteUrl;
  final String? phoneNumber;
  final String? address;
  final List<String> languages;
  final int? yearsOfExperience;
  final String? subspecialty;

  ExpertApplicantInfo({
    required this.fullName,
    required this.email,
    required this.specialty,
    required this.licenseNumber,
    required this.institution,
    required this.credentials,
    required this.bio,
    this.linkedInProfile,
    this.websiteUrl,
    this.phoneNumber,
    this.address,
    this.languages = const ['English'],
    this.yearsOfExperience,
    this.subspecialty,
  });

  /// Check if basic information is complete
  bool get isComplete {
    return fullName.isNotEmpty &&
           email.isNotEmpty &&
           specialty.isNotEmpty &&
           licenseNumber.isNotEmpty &&
           institution.isNotEmpty &&
           credentials.isNotEmpty &&
           bio.length >= 100; // Minimum bio length
  }

  /// Check if specialty is emergency-related
  bool get isEmergencySpecialist {
    const emergencySpecialties = [
      'Emergency Medicine',
      'Critical Care',
      'Trauma Surgery',
      'Emergency Obstetrics'
    ];
    return emergencySpecialties.any((spec) => 
        specialty.toLowerCase().contains(spec.toLowerCase()));
  }

  /// Check if specialty is high-demand
  bool get isHighDemandSpecialty {
    const highDemandSpecialties = [
      'Obstetrics',
      'Gynecology',
      'Reproductive Endocrinology',
      'Maternal-Fetal Medicine',
      'Endocrinology'
    ];
    return highDemandSpecialties.any((spec) => 
        specialty.toLowerCase().contains(spec.toLowerCase()));
  }

  /// Get formatted credentials string
  String get formattedCredentials {
    return credentials.join(', ');
  }

  /// Get experience level description
  String get experienceLevel {
    if (yearsOfExperience == null) return 'Not specified';
    
    final years = yearsOfExperience!;
    if (years < 5) return 'Early Career (< 5 years)';
    if (years < 10) return 'Experienced (5-10 years)';
    if (years < 20) return 'Senior (10-20 years)';
    return 'Veteran (20+ years)';
  }

  factory ExpertApplicantInfo.fromJson(Map<String, dynamic> json) => _$ExpertApplicantInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ExpertApplicantInfoToJson(this);
}

/// Expert Verification Document
@JsonSerializable()
class ExpertVerificationDocument {
  final String documentId;
  final DocumentType type;
  final String fileName;
  final String fileUrl;
  final String? description;
  final DateTime uploadedDate;
  final DocumentStatus status;
  final String? verificationNotes;

  ExpertVerificationDocument({
    required this.documentId,
    required this.type,
    required this.fileName,
    required this.fileUrl,
    this.description,
    required this.uploadedDate,
    this.status = DocumentStatus.pending,
    this.verificationNotes,
  });

  /// Check if document is verified
  bool get isVerified => status == DocumentStatus.verified;

  /// Check if document is rejected
  bool get isRejected => status == DocumentStatus.rejected;

  /// Check if document needs review
  bool get needsReview => status == DocumentStatus.pending;

  factory ExpertVerificationDocument.fromJson(Map<String, dynamic> json) => 
      _$ExpertVerificationDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$ExpertVerificationDocumentToJson(this);
}

/// Document Types for verification
enum DocumentType {
  medicalLicense('Medical License', 'Current medical license or registration', true),
  educationCertificate('Education Certificate', 'Medical degree or relevant certification', true),
  professionalPhoto('Professional Photo', 'Professional headshot for profile', true),
  boardCertification('Board Certification', 'Specialty board certification', false),
  malpracticeInsurance('Malpractice Insurance', 'Professional liability insurance', false),
  hospitalAffiliation('Hospital Affiliation', 'Hospital or clinic affiliation letter', false),
  cv('Curriculum Vitae', 'Current CV or resume', false),
  referenceLetters('Reference Letters', 'Professional references', false);

  const DocumentType(this.displayName, this.description, this.required);

  final String displayName;
  final String description;
  final bool required;

  /// Get document icon
  String get icon {
    switch (this) {
      case DocumentType.medicalLicense:
        return '📜';
      case DocumentType.educationCertificate:
        return '🎓';
      case DocumentType.professionalPhoto:
        return '📸';
      case DocumentType.boardCertification:
        return '🏆';
      case DocumentType.malpracticeInsurance:
        return '🛡️';
      case DocumentType.hospitalAffiliation:
        return '🏥';
      case DocumentType.cv:
        return '📋';
      case DocumentType.referenceLetters:
        return '✉️';
    }
  }
}

/// Document Status
enum DocumentStatus {
  pending('Pending Review', 'Document uploaded, awaiting review'),
  verified('Verified', 'Document has been verified'),
  rejected('Rejected', 'Document rejected - resubmission required'),
  expired('Expired', 'Document has expired and needs renewal');

  const DocumentStatus(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Get status color
  int get color {
    switch (this) {
      case DocumentStatus.pending:
        return 0xFFFF9800; // Orange
      case DocumentStatus.verified:
        return 0xFF4CAF50; // Green
      case DocumentStatus.rejected:
        return 0xFFF44336; // Red
      case DocumentStatus.expired:
        return 0xFF9E9E9E; // Grey
    }
  }
}

/// Verification Status
enum VerificationStatus {
  pending('Pending', 'Application submitted, waiting for review'),
  underReview('Under Review', 'Being reviewed by verification team'),
  additionalInfoRequired('Additional Info Required', 'More information needed'),
  approved('Approved', 'Verification approved'),
  rejected('Rejected', 'Application rejected'),
  suspended('Suspended', 'Verification suspended');

  const VerificationStatus(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Get status color
  int get color {
    switch (this) {
      case VerificationStatus.pending:
        return 0xFFFF9800; // Orange
      case VerificationStatus.underReview:
        return 0xFF2196F3; // Blue
      case VerificationStatus.additionalInfoRequired:
        return 0xFFFF5722; // Deep Orange
      case VerificationStatus.approved:
        return 0xFF4CAF50; // Green
      case VerificationStatus.rejected:
        return 0xFFF44336; // Red
      case VerificationStatus.suspended:
        return 0xFF9E9E9E; // Grey
    }
  }

  /// Get status icon
  String get icon {
    switch (this) {
      case VerificationStatus.pending:
        return '⏳';
      case VerificationStatus.underReview:
        return '🔍';
      case VerificationStatus.additionalInfoRequired:
        return '📝';
      case VerificationStatus.approved:
        return '✅';
      case VerificationStatus.rejected:
        return '❌';
      case VerificationStatus.suspended:
        return '⚠️';
    }
  }
}

/// Verification Priority
enum VerificationPriority {
  normal('Normal', 0xFF4CAF50),
  medium('Medium', 0xFFFF9800),
  high('High', 0xFFFF5722),
  urgent('Urgent', 0xFFF44336);

  const VerificationPriority(this.displayName, this.color);

  final String displayName;
  final int color;
}

/// Verification Note
@JsonSerializable()
class VerificationNote {
  final String noteId;
  final String reviewerId;
  final String content;
  final DateTime createdDate;
  final NoteType type;
  final bool isInternal;

  VerificationNote({
    required this.noteId,
    required this.reviewerId,
    required this.content,
    required this.createdDate,
    required this.type,
    this.isInternal = true,
  });

  factory VerificationNote.fromJson(Map<String, dynamic> json) => _$VerificationNoteFromJson(json);
  Map<String, dynamic> toJson() => _$VerificationNoteToJson(this);
}

/// Note Types
enum NoteType {
  general('General Note', 'General verification note'),
  concern('Concern', 'Verification concern or issue'),
  clarification('Clarification Needed', 'Additional clarification required'),
  approved('Approved', 'Verification approved note'),
  rejected('Rejected', 'Rejection reason note');

  const NoteType(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Verification Score
@JsonSerializable()
class VerificationScore {
  final int credentialsScore; // 0-25 points
  final int experienceScore; // 0-25 points
  final int documentationScore; // 0-25 points
  final int professionalismScore; // 0-25 points
  final String? scoreNotes;
  final DateTime scoredDate;
  final String scoredBy;

  VerificationScore({
    required this.credentialsScore,
    required this.experienceScore,
    required this.documentationScore,
    required this.professionalismScore,
    this.scoreNotes,
    required this.scoredDate,
    required this.scoredBy,
  });

  /// Get total verification score
  int get totalScore => credentialsScore + experienceScore + documentationScore + professionalismScore;

  /// Get score percentage
  double get scorePercentage => totalScore / 100.0;

  /// Get score grade
  VerificationGrade get grade {
    if (scorePercentage >= 0.9) return VerificationGrade.excellent;
    if (scorePercentage >= 0.8) return VerificationGrade.good;
    if (scorePercentage >= 0.7) return VerificationGrade.satisfactory;
    return VerificationGrade.needsImprovement;
  }

  /// Check if score meets minimum requirements
  bool get meetsMinimumRequirements => totalScore >= 70;

  factory VerificationScore.fromJson(Map<String, dynamic> json) => _$VerificationScoreFromJson(json);
  Map<String, dynamic> toJson() => _$VerificationScoreToJson(this);
}

/// Verification Grades
enum VerificationGrade {
  excellent('Excellent', 'Outstanding credentials and documentation', 0xFF4CAF50),
  good('Good', 'Strong credentials with minor improvements possible', 0xFF8BC34A),
  satisfactory('Satisfactory', 'Meets basic requirements', 0xFFFF9800),
  needsImprovement('Needs Improvement', 'Below minimum standards', 0xFFF44336);

  const VerificationGrade(this.displayName, this.description, this.color);

  final String displayName;
  final String description;
  final int color;

  String get icon {
    switch (this) {
      case VerificationGrade.excellent:
        return '🌟';
      case VerificationGrade.good:
        return '⭐';
      case VerificationGrade.satisfactory:
        return '✅';
      case VerificationGrade.needsImprovement:
        return '⚠️';
    }
  }
}

/// Verification Checklist Item
@JsonSerializable()
class VerificationChecklistItem {
  final String itemId;
  final String title;
  final String description;
  final bool isRequired;
  final bool isCompleted;
  final DateTime? completedDate;
  final String? completedBy;
  final String? notes;

  VerificationChecklistItem({
    required this.itemId,
    required this.title,
    required this.description,
    this.isRequired = true,
    this.isCompleted = false,
    this.completedDate,
    this.completedBy,
    this.notes,
  });

  factory VerificationChecklistItem.fromJson(Map<String, dynamic> json) => 
      _$VerificationChecklistItemFromJson(json);
  Map<String, dynamic> toJson() => _$VerificationChecklistItemToJson(this);
}
