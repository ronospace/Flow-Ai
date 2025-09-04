import 'dart:typed_data';

// === ENUMS ===

enum DeploymentTarget {
  development,
  staging,
  production,
  testFlight,
  appStore,
  playStore,
}

enum AppStoreStatus {
  draft,
  readyForReview,
  inReview,
  pendingDeveloperRelease,
  pendingAppleRelease,
  processing,
  readyForSale,
  rejected,
  metadataRejected,
  removedFromSale,
  developerRejected,
}

enum ComplianceStatus {
  notChecked,
  checking,
  compliant,
  nonCompliant,
  warning,
  error,
}

enum BuildStatus {
  pending,
  building,
  success,
  failed,
  archived,
  uploaded,
  processing,
  ready,
}

enum ReleaseType {
  major,
  minor,
  patch,
  hotfix,
  beta,
  alpha,
}

enum PlatformTarget {
  ios,
  android,
  web,
  macos,
  windows,
  linux,
}

// === APP METADATA MODELS ===

class AppMetadata {
  final String appName;
  final String bundleId;
  final String version;
  final String buildNumber;
  final String description;
  final String shortDescription;
  final List<String> keywords;
  final String primaryCategory;
  final String? secondaryCategory;
  final String supportUrl;
  final String marketingUrl;
  final String privacyPolicyUrl;
  final String copyrightText;
  final Map<String, String> localizedDescriptions;
  final Map<String, List<String>> localizedKeywords;
  final List<Screenshot> screenshots;
  final AppIcon appIcon;
  final List<String> supportedLanguages;
  final AgeRating ageRating;
  final PricingInfo pricingInfo;

  const AppMetadata({
    required this.appName,
    required this.bundleId,
    required this.version,
    required this.buildNumber,
    required this.description,
    required this.shortDescription,
    required this.keywords,
    required this.primaryCategory,
    this.secondaryCategory,
    required this.supportUrl,
    required this.marketingUrl,
    required this.privacyPolicyUrl,
    required this.copyrightText,
    required this.localizedDescriptions,
    required this.localizedKeywords,
    required this.screenshots,
    required this.appIcon,
    required this.supportedLanguages,
    required this.ageRating,
    required this.pricingInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'app_name': appName,
      'bundle_id': bundleId,
      'version': version,
      'build_number': buildNumber,
      'description': description,
      'short_description': shortDescription,
      'keywords': keywords,
      'primary_category': primaryCategory,
      'secondary_category': secondaryCategory,
      'support_url': supportUrl,
      'marketing_url': marketingUrl,
      'privacy_policy_url': privacyPolicyUrl,
      'copyright_text': copyrightText,
      'localized_descriptions': localizedDescriptions,
      'localized_keywords': localizedKeywords,
      'screenshots': screenshots.map((s) => s.toJson()).toList(),
      'app_icon': appIcon.toJson(),
      'supported_languages': supportedLanguages,
      'age_rating': ageRating.toJson(),
      'pricing_info': pricingInfo.toJson(),
    };
  }

  factory AppMetadata.fromJson(Map<String, dynamic> json) {
    return AppMetadata(
      appName: json['app_name'],
      bundleId: json['bundle_id'],
      version: json['version'],
      buildNumber: json['build_number'],
      description: json['description'],
      shortDescription: json['short_description'],
      keywords: List<String>.from(json['keywords']),
      primaryCategory: json['primary_category'],
      secondaryCategory: json['secondary_category'],
      supportUrl: json['support_url'],
      marketingUrl: json['marketing_url'],
      privacyPolicyUrl: json['privacy_policy_url'],
      copyrightText: json['copyright_text'],
      localizedDescriptions: Map<String, String>.from(json['localized_descriptions']),
      localizedKeywords: Map<String, List<String>>.from(
        json['localized_keywords'].map((k, v) => MapEntry(k, List<String>.from(v))),
      ),
      screenshots: (json['screenshots'] as List)
          .map((s) => Screenshot.fromJson(s))
          .toList(),
      appIcon: AppIcon.fromJson(json['app_icon']),
      supportedLanguages: List<String>.from(json['supported_languages']),
      ageRating: AgeRating.fromJson(json['age_rating']),
      pricingInfo: PricingInfo.fromJson(json['pricing_info']),
    );
  }
}

class Screenshot {
  final String filePath;
  final PlatformTarget platform;
  final String deviceType; // iPhone 6.5", iPad Pro, etc.
  final int width;
  final int height;
  final String? locale;
  final int order;
  final Uint8List? imageData;

  const Screenshot({
    required this.filePath,
    required this.platform,
    required this.deviceType,
    required this.width,
    required this.height,
    this.locale,
    required this.order,
    this.imageData,
  });

  Map<String, dynamic> toJson() {
    return {
      'file_path': filePath,
      'platform': platform.name,
      'device_type': deviceType,
      'width': width,
      'height': height,
      'locale': locale,
      'order': order,
      'has_image_data': imageData != null,
    };
  }

  factory Screenshot.fromJson(Map<String, dynamic> json) {
    return Screenshot(
      filePath: json['file_path'],
      platform: PlatformTarget.values.firstWhere((e) => e.name == json['platform']),
      deviceType: json['device_type'],
      width: json['width'],
      height: json['height'],
      locale: json['locale'],
      order: json['order'],
    );
  }
}

class AppIcon {
  final String filePath;
  final int size;
  final Uint8List? imageData;
  final List<AppIconVariant> variants;

  const AppIcon({
    required this.filePath,
    required this.size,
    this.imageData,
    required this.variants,
  });

  Map<String, dynamic> toJson() {
    return {
      'file_path': filePath,
      'size': size,
      'has_image_data': imageData != null,
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }

  factory AppIcon.fromJson(Map<String, dynamic> json) {
    return AppIcon(
      filePath: json['file_path'],
      size: json['size'],
      variants: (json['variants'] as List)
          .map((v) => AppIconVariant.fromJson(v))
          .toList(),
    );
  }
}

class AppIconVariant {
  final String filePath;
  final int size;
  final PlatformTarget platform;
  final String? usage; // app, settings, notification, etc.

  const AppIconVariant({
    required this.filePath,
    required this.size,
    required this.platform,
    this.usage,
  });

  Map<String, dynamic> toJson() {
    return {
      'file_path': filePath,
      'size': size,
      'platform': platform.name,
      'usage': usage,
    };
  }

  factory AppIconVariant.fromJson(Map<String, dynamic> json) {
    return AppIconVariant(
      filePath: json['file_path'],
      size: json['size'],
      platform: PlatformTarget.values.firstWhere((e) => e.name == json['platform']),
      usage: json['usage'],
    );
  }
}

class AgeRating {
  final int minimumAge;
  final Map<String, String> ratingReasons;
  final bool frequentMildProfanity;
  final bool infrequentStrongProfanity;
  final bool mildViolence;
  final bool mildSuggestiveThemes;
  final bool mildMedicalTreatmentInfo;

  const AgeRating({
    required this.minimumAge,
    required this.ratingReasons,
    this.frequentMildProfanity = false,
    this.infrequentStrongProfanity = false,
    this.mildViolence = false,
    this.mildSuggestiveThemes = false,
    this.mildMedicalTreatmentInfo = true, // Health app
  });

  Map<String, dynamic> toJson() {
    return {
      'minimum_age': minimumAge,
      'rating_reasons': ratingReasons,
      'frequent_mild_profanity': frequentMildProfanity,
      'infrequent_strong_profanity': infrequentStrongProfanity,
      'mild_violence': mildViolence,
      'mild_suggestive_themes': mildSuggestiveThemes,
      'mild_medical_treatment_info': mildMedicalTreatmentInfo,
    };
  }

  factory AgeRating.fromJson(Map<String, dynamic> json) {
    return AgeRating(
      minimumAge: json['minimum_age'],
      ratingReasons: Map<String, String>.from(json['rating_reasons']),
      frequentMildProfanity: json['frequent_mild_profanity'] ?? false,
      infrequentStrongProfanity: json['infrequent_strong_profanity'] ?? false,
      mildViolence: json['mild_violence'] ?? false,
      mildSuggestiveThemes: json['mild_suggestive_themes'] ?? false,
      mildMedicalTreatmentInfo: json['mild_medical_treatment_info'] ?? true,
    );
  }
}

class PricingInfo {
  final bool isFree;
  final Map<String, double> prices; // Country code -> Price
  final List<InAppPurchase> inAppPurchases;
  final List<Subscription> subscriptions;

  const PricingInfo({
    required this.isFree,
    required this.prices,
    required this.inAppPurchases,
    required this.subscriptions,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_free': isFree,
      'prices': prices,
      'in_app_purchases': inAppPurchases.map((iap) => iap.toJson()).toList(),
      'subscriptions': subscriptions.map((sub) => sub.toJson()).toList(),
    };
  }

  factory PricingInfo.fromJson(Map<String, dynamic> json) {
    return PricingInfo(
      isFree: json['is_free'],
      prices: Map<String, double>.from(json['prices']),
      inAppPurchases: (json['in_app_purchases'] as List)
          .map((iap) => InAppPurchase.fromJson(iap))
          .toList(),
      subscriptions: (json['subscriptions'] as List)
          .map((sub) => Subscription.fromJson(sub))
          .toList(),
    );
  }
}

class InAppPurchase {
  final String id;
  final String name;
  final String description;
  final Map<String, double> prices;
  final String type; // consumable, non-consumable, etc.

  const InAppPurchase({
    required this.id,
    required this.name,
    required this.description,
    required this.prices,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'prices': prices,
      'type': type,
    };
  }

  factory InAppPurchase.fromJson(Map<String, dynamic> json) {
    return InAppPurchase(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      prices: Map<String, double>.from(json['prices']),
      type: json['type'],
    );
  }
}

class Subscription {
  final String id;
  final String name;
  final String description;
  final Map<String, double> prices;
  final String duration; // monthly, yearly, etc.
  final bool hasFreeTrial;
  final int? freeTrialDays;

  const Subscription({
    required this.id,
    required this.name,
    required this.description,
    required this.prices,
    required this.duration,
    this.hasFreeTrial = false,
    this.freeTrialDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'prices': prices,
      'duration': duration,
      'has_free_trial': hasFreeTrial,
      'free_trial_days': freeTrialDays,
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      prices: Map<String, double>.from(json['prices']),
      duration: json['duration'],
      hasFreeTrial: json['has_free_trial'] ?? false,
      freeTrialDays: json['free_trial_days'],
    );
  }
}

// === COMPLIANCE MODELS ===

class ComplianceCheck {
  final String id;
  final String name;
  final String description;
  final String category;
  final ComplianceStatus status;
  final List<ComplianceIssue> issues;
  final DateTime lastChecked;
  final Map<String, dynamic> checkData;

  ComplianceCheck({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.issues,
    required this.lastChecked,
    required this.checkData,
  });

  bool get isCompliant => status == ComplianceStatus.compliant;
  bool get hasWarnings => issues.any((i) => i.severity == 'warning');
  bool get hasErrors => issues.any((i) => i.severity == 'error');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'status': status.name,
      'issues': issues.map((i) => i.toJson()).toList(),
      'last_checked': lastChecked.toIso8601String(),
      'check_data': checkData,
      'is_compliant': isCompliant,
      'has_warnings': hasWarnings,
      'has_errors': hasErrors,
    };
  }

  factory ComplianceCheck.fromJson(Map<String, dynamic> json) {
    return ComplianceCheck(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      status: ComplianceStatus.values.firstWhere((e) => e.name == json['status']),
      issues: (json['issues'] as List)
          .map((i) => ComplianceIssue.fromJson(i))
          .toList(),
      lastChecked: DateTime.parse(json['last_checked']),
      checkData: json['check_data'] ?? {},
    );
  }
}

class ComplianceIssue {
  final String id;
  final String description;
  final String severity; // error, warning, info
  final String category;
  final String? suggestedFix;
  final String? documentationUrl;
  final Map<String, dynamic> metadata;

  const ComplianceIssue({
    required this.id,
    required this.description,
    required this.severity,
    required this.category,
    this.suggestedFix,
    this.documentationUrl,
    this.metadata = const {},
  });

  bool get isError => severity == 'error';
  bool get isWarning => severity == 'warning';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'severity': severity,
      'category': category,
      'suggested_fix': suggestedFix,
      'documentation_url': documentationUrl,
      'metadata': metadata,
      'is_error': isError,
      'is_warning': isWarning,
    };
  }

  factory ComplianceIssue.fromJson(Map<String, dynamic> json) {
    return ComplianceIssue(
      id: json['id'],
      description: json['description'],
      severity: json['severity'],
      category: json['category'],
      suggestedFix: json['suggested_fix'],
      documentationUrl: json['documentation_url'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class ComplianceReport {
  final String id;
  final DateTime generatedAt;
  final String appVersion;
  final DeploymentTarget target;
  final List<ComplianceCheck> checks;
  final ComplianceStatus overallStatus;
  final int totalChecks;
  final int passedChecks;
  final int failedChecks;
  final int warningChecks;

  ComplianceReport({
    required this.id,
    required this.generatedAt,
    required this.appVersion,
    required this.target,
    required this.checks,
    required this.overallStatus,
    required this.totalChecks,
    required this.passedChecks,
    required this.failedChecks,
    required this.warningChecks,
  });

  bool get isReadyForRelease => overallStatus == ComplianceStatus.compliant && failedChecks == 0;
  double get complianceScore => totalChecks > 0 ? passedChecks / totalChecks : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'generated_at': generatedAt.toIso8601String(),
      'app_version': appVersion,
      'target': target.name,
      'checks': checks.map((c) => c.toJson()).toList(),
      'overall_status': overallStatus.name,
      'total_checks': totalChecks,
      'passed_checks': passedChecks,
      'failed_checks': failedChecks,
      'warning_checks': warningChecks,
      'is_ready_for_release': isReadyForRelease,
      'compliance_score': complianceScore,
    };
  }
}

// === BUILD MODELS ===

class BuildConfiguration {
  final String name;
  final DeploymentTarget target;
  final PlatformTarget platform;
  final String buildMode; // debug, profile, release
  final Map<String, String> environmentVariables;
  final List<String> buildFlags;
  final bool obfuscate;
  final bool treeShakeIcons;
  final String? flavorName;
  final Map<String, dynamic> customSettings;

  const BuildConfiguration({
    required this.name,
    required this.target,
    required this.platform,
    required this.buildMode,
    required this.environmentVariables,
    required this.buildFlags,
    this.obfuscate = true,
    this.treeShakeIcons = true,
    this.flavorName,
    this.customSettings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'target': target.name,
      'platform': platform.name,
      'build_mode': buildMode,
      'environment_variables': environmentVariables,
      'build_flags': buildFlags,
      'obfuscate': obfuscate,
      'tree_shake_icons': treeShakeIcons,
      'flavor_name': flavorName,
      'custom_settings': customSettings,
    };
  }

  factory BuildConfiguration.fromJson(Map<String, dynamic> json) {
    return BuildConfiguration(
      name: json['name'],
      target: DeploymentTarget.values.firstWhere((e) => e.name == json['target']),
      platform: PlatformTarget.values.firstWhere((e) => e.name == json['platform']),
      buildMode: json['build_mode'],
      environmentVariables: Map<String, String>.from(json['environment_variables']),
      buildFlags: List<String>.from(json['build_flags']),
      obfuscate: json['obfuscate'] ?? true,
      treeShakeIcons: json['tree_shake_icons'] ?? true,
      flavorName: json['flavor_name'],
      customSettings: json['custom_settings'] ?? {},
    );
  }
}

class BuildResult {
  final String id;
  final BuildConfiguration configuration;
  final BuildStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? buildDuration;
  final String? outputPath;
  final int? buildSize;
  final List<BuildArtifact> artifacts;
  final List<BuildMessage> messages;
  final String? errorMessage;
  final Map<String, dynamic> buildMetrics;

  BuildResult({
    required this.id,
    required this.configuration,
    required this.status,
    required this.startTime,
    this.endTime,
    this.buildDuration,
    this.outputPath,
    this.buildSize,
    required this.artifacts,
    required this.messages,
    this.errorMessage,
    required this.buildMetrics,
  });

  bool get isSuccess => status == BuildStatus.success;
  bool get isFailed => status == BuildStatus.failed;
  bool get isComplete => endTime != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'configuration': configuration.toJson(),
      'status': status.name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'build_duration_ms': buildDuration?.inMilliseconds,
      'output_path': outputPath,
      'build_size': buildSize,
      'artifacts': artifacts.map((a) => a.toJson()).toList(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'error_message': errorMessage,
      'build_metrics': buildMetrics,
      'is_success': isSuccess,
      'is_failed': isFailed,
      'is_complete': isComplete,
    };
  }
}

class BuildArtifact {
  final String name;
  final String type; // apk, ipa, app, etc.
  final String path;
  final int sizeBytes;
  final String? checksum;
  final DateTime createdAt;

  const BuildArtifact({
    required this.name,
    required this.type,
    required this.path,
    required this.sizeBytes,
    this.checksum,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'path': path,
      'size_bytes': sizeBytes,
      'checksum': checksum,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BuildArtifact.fromJson(Map<String, dynamic> json) {
    return BuildArtifact(
      name: json['name'],
      type: json['type'],
      path: json['path'],
      sizeBytes: json['size_bytes'],
      checksum: json['checksum'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class BuildMessage {
  final String level; // info, warning, error
  final String message;
  final String? file;
  final int? line;
  final int? column;
  final DateTime timestamp;

  const BuildMessage({
    required this.level,
    required this.message,
    this.file,
    this.line,
    this.column,
    required this.timestamp,
  });

  bool get isError => level == 'error';
  bool get isWarning => level == 'warning';

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'message': message,
      'file': file,
      'line': line,
      'column': column,
      'timestamp': timestamp.toIso8601String(),
      'is_error': isError,
      'is_warning': isWarning,
    };
  }

  factory BuildMessage.fromJson(Map<String, dynamic> json) {
    return BuildMessage(
      level: json['level'],
      message: json['message'],
      file: json['file'],
      line: json['line'],
      column: json['column'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

// === RELEASE MODELS ===

class ReleasePackage {
  final String id;
  final String version;
  final String buildNumber;
  final ReleaseType releaseType;
  final DateTime createdAt;
  final List<PlatformTarget> platforms;
  final Map<PlatformTarget, BuildResult> buildResults;
  final AppMetadata metadata;
  final List<String> releaseNotes;
  final Map<String, List<String>> localizedReleaseNotes;
  final ComplianceReport complianceReport;
  final ReleaseConfiguration configuration;

  ReleasePackage({
    required this.id,
    required this.version,
    required this.buildNumber,
    required this.releaseType,
    required this.createdAt,
    required this.platforms,
    required this.buildResults,
    required this.metadata,
    required this.releaseNotes,
    required this.localizedReleaseNotes,
    required this.complianceReport,
    required this.configuration,
  });

  bool get isReadyForRelease {
    return complianceReport.isReadyForRelease &&
           buildResults.values.every((build) => build.isSuccess);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'build_number': buildNumber,
      'release_type': releaseType.name,
      'created_at': createdAt.toIso8601String(),
      'platforms': platforms.map((p) => p.name).toList(),
      'build_results': buildResults.map((k, v) => MapEntry(k.name, v.toJson())),
      'metadata': metadata.toJson(),
      'release_notes': releaseNotes,
      'localized_release_notes': localizedReleaseNotes,
      'compliance_report': complianceReport.toJson(),
      'configuration': configuration.toJson(),
      'is_ready_for_release': isReadyForRelease,
    };
  }
}

class ReleaseConfiguration {
  final bool automaticRelease;
  final DateTime? scheduledReleaseDate;
  final List<String> targetCountries;
  final bool phasedRelease;
  final int? phasedReleasePercentage;
  final bool betaRelease;
  final List<String> betaGroups;
  final Map<String, dynamic> customSettings;

  const ReleaseConfiguration({
    this.automaticRelease = false,
    this.scheduledReleaseDate,
    this.targetCountries = const [],
    this.phasedRelease = false,
    this.phasedReleasePercentage,
    this.betaRelease = false,
    this.betaGroups = const [],
    this.customSettings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'automatic_release': automaticRelease,
      'scheduled_release_date': scheduledReleaseDate?.toIso8601String(),
      'target_countries': targetCountries,
      'phased_release': phasedRelease,
      'phased_release_percentage': phasedReleasePercentage,
      'beta_release': betaRelease,
      'beta_groups': betaGroups,
      'custom_settings': customSettings,
    };
  }

  factory ReleaseConfiguration.fromJson(Map<String, dynamic> json) {
    return ReleaseConfiguration(
      automaticRelease: json['automatic_release'] ?? false,
      scheduledReleaseDate: json['scheduled_release_date'] != null
          ? DateTime.parse(json['scheduled_release_date'])
          : null,
      targetCountries: List<String>.from(json['target_countries'] ?? []),
      phasedRelease: json['phased_release'] ?? false,
      phasedReleasePercentage: json['phased_release_percentage'],
      betaRelease: json['beta_release'] ?? false,
      betaGroups: List<String>.from(json['beta_groups'] ?? []),
      customSettings: json['custom_settings'] ?? {},
    );
  }
}

// === DEPLOYMENT STATUS ===

class DeploymentStatus {
  final String releaseId;
  final DeploymentTarget target;
  final PlatformTarget platform;
  final AppStoreStatus status;
  final DateTime lastUpdated;
  final String? reviewNotes;
  final List<String> rejectionReasons;
  final DateTime? submittedAt;
  final DateTime? reviewStartedAt;
  final DateTime? approvedAt;
  final DateTime? releasedAt;
  final Map<String, dynamic> storeMetadata;

  DeploymentStatus({
    required this.releaseId,
    required this.target,
    required this.platform,
    required this.status,
    required this.lastUpdated,
    this.reviewNotes,
    required this.rejectionReasons,
    this.submittedAt,
    this.reviewStartedAt,
    this.approvedAt,
    this.releasedAt,
    required this.storeMetadata,
  });

  bool get isInReview => status == AppStoreStatus.inReview;
  bool get isApproved => status == AppStoreStatus.readyForSale;
  bool get isRejected => status == AppStoreStatus.rejected || status == AppStoreStatus.metadataRejected;

  Duration? get reviewDuration {
    if (reviewStartedAt != null && approvedAt != null) {
      return approvedAt!.difference(reviewStartedAt!);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'release_id': releaseId,
      'target': target.name,
      'platform': platform.name,
      'status': status.name,
      'last_updated': lastUpdated.toIso8601String(),
      'review_notes': reviewNotes,
      'rejection_reasons': rejectionReasons,
      'submitted_at': submittedAt?.toIso8601String(),
      'review_started_at': reviewStartedAt?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'released_at': releasedAt?.toIso8601String(),
      'store_metadata': storeMetadata,
      'is_in_review': isInReview,
      'is_approved': isApproved,
      'is_rejected': isRejected,
      'review_duration_hours': reviewDuration?.inHours,
    };
  }
}
