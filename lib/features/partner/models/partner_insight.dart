/// Represents an AI-generated insight for partners
class PartnerInsight {
  final String id;
  final String partnershipId;
  final PartnerInsightType type;
  final String title;
  final String content;
  final List<String> actionSuggestions;
  final DateTime generatedAt;
  final DateTime expiresAt;
  final bool isRead;

  PartnerInsight({
    required this.id,
    required this.partnershipId,
    required this.type,
    required this.title,
    required this.content,
    this.actionSuggestions = const [],
    required this.generatedAt,
    required this.expiresAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnershipId': partnershipId,
      'type': type.name,
      'title': title,
      'content': content,
      'actionSuggestions': actionSuggestions,
      'generatedAt': generatedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory PartnerInsight.fromJson(Map<String, dynamic> json) {
    return PartnerInsight(
      id: json['id'],
      partnershipId: json['partnershipId'],
      type: PartnerInsightType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PartnerInsightType.supportSuggestion,
      ),
      title: json['title'],
      content: json['content'],
      actionSuggestions: List<String>.from(json['actionSuggestions'] ?? []),
      generatedAt: DateTime.parse(json['generatedAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}

enum PartnerInsightType {
  supportSuggestion,
  cycleUpdate,
  moodAlert,
  healthTip,
}

