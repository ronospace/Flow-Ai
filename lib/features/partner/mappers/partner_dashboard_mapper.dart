import '../models/partner_models.dart' as model;
import '../models/partner_insight.dart' as insight_model;

class PartnerDashboardMapper {
  static model.Partnership toPartnership(dynamic ps) {
    return model.Partnership(
      id: ps.id,
      userId1: ps.primaryUserId,
      userId2: ps.partnerUserId,
      customName1: ps.primaryUserName,
      customName2: ps.partnerUserName,
      establishedAt: ps.createdAt,
      status: model.PartnershipStatus.active,
      privacySettings: model.PartnerPrivacySettings(
        shareBasicCycleInfo: ps.sharingSettings.shareSymptoms,
        shareDetailedSymptoms: ps.sharingSettings.sharePhysicalSymptoms,
        shareMoodData: ps.sharingSettings.shareMoodData,
        shareEnergyLevels: true,
        sharePainData: ps.sharingSettings.sharePhysicalSymptoms,
        shareAIInsights: ps.sharingSettings.allowInsights,
        sharePredictions: ps.sharingSettings.sharePredictions,
        allowNotifications: ps.sharingSettings.sendNotifications,
        allowCareActions: true,
      ),
      lastActiveAt: ps.lastActiveAt,
    );
  }

  static model.PartnerMessage toPartnerMessage(dynamic pm) {
    model.PartnerMessageType type;
    switch (pm.type.name) {
      case 'text':
        type = model.PartnerMessageType.text;
        break;
      case 'careAction':
        type = model.PartnerMessageType.careAction;
        break;
      case 'insight':
        type = model.PartnerMessageType.supportive;
        break;
      default:
        type = model.PartnerMessageType.text;
    }

    return model.PartnerMessage(
      id: pm.id,
      partnershipId: pm.partnershipId,
      senderId: pm.senderId,
      receiverId: pm.receiverId,
      content: pm.content,
      type: type,
      createdAt: pm.sentAt,
      readAt: pm.isRead ? pm.sentAt : null,
      metadata: pm.metadata,
    );
  }

  static insight_model.PartnerInsight toPartnerInsight(dynamic pi) {
    return insight_model.PartnerInsight(
      id: pi.id,
      partnershipId: pi.partnershipId,
      type: insight_model.PartnerInsightType.values.firstWhere(
        (e) => e.name == pi.type.name,
        orElse: () => insight_model.PartnerInsightType.supportSuggestion,
      ),
      title: pi.title,
      content: pi.content,
      actionSuggestions: pi.actionSuggestions,
      generatedAt: pi.generatedAt,
      expiresAt: pi.expiresAt,
      isRead: pi.isRead,
    );
  }
}
