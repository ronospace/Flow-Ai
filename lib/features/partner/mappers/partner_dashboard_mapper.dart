import '../models/partner_models.dart' as model;

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
}
