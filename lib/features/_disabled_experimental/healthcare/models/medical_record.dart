/// Medical Record Model
class MedicalRecord {
  final String id;
  final String providerId;
  final String patientId;
  final DateTime recordDate;
  final RecordType type;
  final String title;
  final String description;
  final Map<String, dynamic> data;
  final List<String> attachmentUrls;
  final bool isConfidential;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MedicalRecord({
    required this.id,
    required this.providerId,
    required this.patientId,
    required this.recordDate,
    required this.type,
    required this.title,
    required this.description,
    required this.data,
    this.attachmentUrls = const [],
    this.isConfidential = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'patientId': patientId,
      'recordDate': recordDate.toIso8601String(),
      'type': type.name,
      'title': title,
      'description': description,
      'data': data,
      'attachmentUrls': attachmentUrls,
      'isConfidential': isConfidential,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      providerId: json['providerId'],
      patientId: json['patientId'],
      recordDate: DateTime.parse(json['recordDate']),
      type: RecordType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => RecordType.general,
      ),
      title: json['title'],
      description: json['description'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      attachmentUrls: List<String>.from(json['attachmentUrls'] ?? []),
      isConfidential: json['isConfidential'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  @override
  String toString() {
    return 'MedicalRecord(id: $id, type: ${type.displayName}, title: $title, date: $recordDate)';
  }
}

/// Medical Record Types
enum RecordType {
  general,
  consultation,
  labResults,
  prescription,
  diagnosis,
  treatment,
  procedure,
  imaging,
  vaccination,
  reproductive,
  gynecological,
  hormonal,
}

/// Extension for Record Type
extension RecordTypeExtension on RecordType {
  String get displayName {
    switch (this) {
      case RecordType.general:
        return 'General Record';
      case RecordType.consultation:
        return 'Consultation';
      case RecordType.labResults:
        return 'Lab Results';
      case RecordType.prescription:
        return 'Prescription';
      case RecordType.diagnosis:
        return 'Diagnosis';
      case RecordType.treatment:
        return 'Treatment';
      case RecordType.procedure:
        return 'Procedure';
      case RecordType.imaging:
        return 'Imaging';
      case RecordType.vaccination:
        return 'Vaccination';
      case RecordType.reproductive:
        return 'Reproductive Health';
      case RecordType.gynecological:
        return 'Gynecological';
      case RecordType.hormonal:
        return 'Hormonal';
    }
  }

  String get emoji {
    switch (this) {
      case RecordType.general:
        return '📋';
      case RecordType.consultation:
        return '👩‍⚕️';
      case RecordType.labResults:
        return '🧪';
      case RecordType.prescription:
        return '💊';
      case RecordType.diagnosis:
        return '🩺';
      case RecordType.treatment:
        return '🏥';
      case RecordType.procedure:
        return '⚕️';
      case RecordType.imaging:
        return '📷';
      case RecordType.vaccination:
        return '💉';
      case RecordType.reproductive:
        return '🤱';
      case RecordType.gynecological:
        return '👩‍⚕️';
      case RecordType.hormonal:
        return '🧬';
    }
  }
}
