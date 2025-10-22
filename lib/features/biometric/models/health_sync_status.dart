import 'package:json_annotation/json_annotation.dart';

part 'health_sync_status.g.dart';

/// Health Sync Status
/// Represents the current synchronization state of health data
enum HealthSyncStatus {
  disconnected('Disconnected', 'No health services connected', '📵'),
  connecting('Connecting', 'Attempting to connect to health services', '🔄'),
  connected('Connected', 'Health services connected successfully', '✅'),
  syncing('Syncing', 'Synchronizing health data', '⏫'),
  syncComplete('Sync Complete', 'All data synchronized successfully', '✅'),
  partialSync('Partial Sync', 'Some data synchronized with warnings', '⚠️'),
  error('Error', 'Sync failed due to an error', '❌'),
  permissionDenied('Permission Denied', 'Health data access permission required', '🔒'),
  networkError('Network Error', 'Network connection required for sync', '📶'),
  serverError('Server Error', 'Health platform service unavailable', '🔴');

  const HealthSyncStatus(this.displayName, this.description, this.icon);

  final String displayName;
  final String description;
  final String icon;

  /// Get status color for UI
  int get color {
    switch (this) {
      case HealthSyncStatus.disconnected:
        return 0xFF9E9E9E; // Grey
      case HealthSyncStatus.connecting:
      case HealthSyncStatus.syncing:
        return 0xFF2196F3; // Blue
      case HealthSyncStatus.connected:
      case HealthSyncStatus.syncComplete:
        return 0xFF4CAF50; // Green
      case HealthSyncStatus.partialSync:
        return 0xFFFF9800; // Orange
      case HealthSyncStatus.error:
      case HealthSyncStatus.serverError:
        return 0xFFF44336; // Red
      case HealthSyncStatus.permissionDenied:
      case HealthSyncStatus.networkError:
        return 0xFFFF5722; // Deep Orange
    }
  }

  /// Check if status indicates an active connection
  bool get isConnected {
    return this == HealthSyncStatus.connected ||
           this == HealthSyncStatus.syncing ||
           this == HealthSyncStatus.syncComplete ||
           this == HealthSyncStatus.partialSync;
  }

  /// Check if status indicates sync is in progress
  bool get isSyncing {
    return this == HealthSyncStatus.connecting ||
           this == HealthSyncStatus.syncing;
  }

  /// Check if status indicates an error state
  bool get isError {
    return this == HealthSyncStatus.error ||
           this == HealthSyncStatus.permissionDenied ||
           this == HealthSyncStatus.networkError ||
           this == HealthSyncStatus.serverError;
  }

  /// Get recommended action for current status
  String? get recommendedAction {
    switch (this) {
      case HealthSyncStatus.disconnected:
        return 'Connect to Apple Health or Google Fit to sync your health data';
      case HealthSyncStatus.connecting:
      case HealthSyncStatus.syncing:
        return 'Please wait while we sync your health data';
      case HealthSyncStatus.connected:
        return 'Health services connected. Tap to sync now';
      case HealthSyncStatus.syncComplete:
        return null; // No action needed
      case HealthSyncStatus.partialSync:
        return 'Some data could not be synced. Check your settings';
      case HealthSyncStatus.error:
        return 'Sync failed. Try again or check your connection';
      case HealthSyncStatus.permissionDenied:
        return 'Grant health data permissions in your device settings';
      case HealthSyncStatus.networkError:
        return 'Check your internet connection and try again';
      case HealthSyncStatus.serverError:
        return 'Health service temporarily unavailable. Try again later';
    }
  }
}

/// Health Sync Details
/// Contains detailed information about sync status
@JsonSerializable()
class HealthSyncDetails {
  final String syncId;
  final HealthSyncStatus status;
  final DateTime lastSyncAttempt;
  final DateTime? lastSuccessfulSync;
  final Map<String, PlatformSyncStatus> platformStatus;
  final List<SyncError> errors;
  final SyncProgress? currentProgress;
  final SyncStatistics statistics;

  HealthSyncDetails({
    required this.syncId,
    required this.status,
    required this.lastSyncAttempt,
    this.lastSuccessfulSync,
    this.platformStatus = const {},
    this.errors = const [],
    this.currentProgress,
    required this.statistics,
  });

  /// Check if any platform is connected
  bool get hasConnectedPlatforms {
    return platformStatus.values.any((status) => status.isConnected);
  }

  /// Get connected platform names
  List<String> get connectedPlatforms {
    return platformStatus.entries
        .where((entry) => entry.value.isConnected)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get platforms with errors
  List<String> get platformsWithErrors {
    return platformStatus.entries
        .where((entry) => entry.value.hasError)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get overall sync health score (0-100)
  int get syncHealthScore {
    if (platformStatus.isEmpty) return 0;

    var score = 0;
    var totalPlatforms = platformStatus.length;

    for (final platformSync in platformStatus.values) {
      if (platformSync.isConnected) score += 40;
      if (platformSync.lastSync != null) score += 20;
      if (!platformSync.hasError) score += 20;
      if (platformSync.dataQuality == SyncDataQuality.excellent) score += 20;
    }

    return (score / totalPlatforms).round().clamp(0, 100);
  }

  /// Get time since last successful sync
  Duration? get timeSinceLastSync {
    return lastSuccessfulSync != null ? 
        DateTime.now().difference(lastSuccessfulSync!) : null;
  }

  factory HealthSyncDetails.fromJson(Map<String, dynamic> json) => 
      _$HealthSyncDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$HealthSyncDetailsToJson(this);
}

/// Platform Sync Status
/// Status for individual health platforms (Apple Health, Google Fit, etc.)
@JsonSerializable()
class PlatformSyncStatus {
  final String platformName;
  final bool isConnected;
  final DateTime? lastSync;
  final DateTime? lastAttempt;
  final SyncResult lastResult;
  final List<String> supportedDataTypes;
  final Map<String, int> syncedDataCounts;
  final SyncDataQuality dataQuality;
  final String? errorMessage;

  PlatformSyncStatus({
    required this.platformName,
    this.isConnected = false,
    this.lastSync,
    this.lastAttempt,
    this.lastResult = SyncResult.pending,
    this.supportedDataTypes = const [],
    this.syncedDataCounts = const {},
    this.dataQuality = SyncDataQuality.unknown,
    this.errorMessage,
  });

  /// Check if platform has error
  bool get hasError => lastResult == SyncResult.error;

  /// Get sync status message
  String get statusMessage {
    if (!isConnected) return 'Not connected';
    if (hasError) return errorMessage ?? 'Sync error';
    if (lastSync == null) return 'Never synced';
    
    final timeSince = DateTime.now().difference(lastSync!);
    if (timeSince.inMinutes < 5) return 'Just synced';
    if (timeSince.inHours < 1) return '${timeSince.inMinutes}m ago';
    if (timeSince.inHours < 24) return '${timeSince.inHours}h ago';
    return '${timeSince.inDays}d ago';
  }

  /// Get total synced data points
  int get totalSyncedData {
    return syncedDataCounts.values.fold(0, (sum, count) => sum + count);
  }

  factory PlatformSyncStatus.fromJson(Map<String, dynamic> json) => 
      _$PlatformSyncStatusFromJson(json);
  Map<String, dynamic> toJson() => _$PlatformSyncStatusToJson(this);
}

/// Sync Result
enum SyncResult {
  pending('Pending', 'Sync not yet attempted'),
  success('Success', 'Sync completed successfully'),
  partial('Partial', 'Sync completed with some warnings'),
  error('Error', 'Sync failed due to an error'),
  cancelled('Cancelled', 'Sync was cancelled by user');

  const SyncResult(this.displayName, this.description);

  final String displayName;
  final String description;

  int get color {
    switch (this) {
      case SyncResult.pending:
        return 0xFF9E9E9E; // Grey
      case SyncResult.success:
        return 0xFF4CAF50; // Green
      case SyncResult.partial:
        return 0xFFFF9800; // Orange
      case SyncResult.error:
        return 0xFFF44336; // Red
      case SyncResult.cancelled:
        return 0xFF607D8B; // Blue Grey
    }
  }
}

/// Sync Data Quality
enum SyncDataQuality {
  unknown('Unknown', 'Data quality not assessed'),
  poor('Poor', 'Low quality or incomplete data'),
  fair('Fair', 'Acceptable data quality'),
  good('Good', 'High quality data'),
  excellent('Excellent', 'Premium quality, validated data');

  const SyncDataQuality(this.displayName, this.description);

  final String displayName;
  final String description;

  int get color {
    switch (this) {
      case SyncDataQuality.unknown:
        return 0xFF9E9E9E; // Grey
      case SyncDataQuality.poor:
        return 0xFFF44336; // Red
      case SyncDataQuality.fair:
        return 0xFFFF9800; // Orange
      case SyncDataQuality.good:
        return 0xFF8BC34A; // Light Green
      case SyncDataQuality.excellent:
        return 0xFF4CAF50; // Green
    }
  }
}

/// Sync Progress
/// Real-time progress information during sync
@JsonSerializable()
class SyncProgress {
  final String taskId;
  final String currentTask;
  final int totalSteps;
  final int completedSteps;
  final String? currentPlatform;
  final String? currentDataType;
  final int processedRecords;
  final int totalRecords;
  final DateTime startTime;
  final Duration? estimatedTimeRemaining;

  SyncProgress({
    required this.taskId,
    required this.currentTask,
    required this.totalSteps,
    this.completedSteps = 0,
    this.currentPlatform,
    this.currentDataType,
    this.processedRecords = 0,
    this.totalRecords = 0,
    required this.startTime,
    this.estimatedTimeRemaining,
  });

  /// Get progress percentage (0-100)
  double get progressPercentage {
    if (totalSteps == 0) return 0.0;
    return (completedSteps / totalSteps * 100).clamp(0.0, 100.0);
  }

  /// Get record processing percentage
  double get recordProgressPercentage {
    if (totalRecords == 0) return 0.0;
    return (processedRecords / totalRecords * 100).clamp(0.0, 100.0);
  }

  /// Get elapsed time
  Duration get elapsedTime => DateTime.now().difference(startTime);

  /// Check if sync is complete
  bool get isComplete => completedSteps >= totalSteps;

  /// Get progress message
  String get progressMessage {
    if (currentPlatform != null && currentDataType != null) {
      return 'Syncing $currentDataType from $currentPlatform...';
    } else if (currentPlatform != null) {
      return 'Connecting to $currentPlatform...';
    } else {
      return currentTask;
    }
  }

  factory SyncProgress.fromJson(Map<String, dynamic> json) => _$SyncProgressFromJson(json);
  Map<String, dynamic> toJson() => _$SyncProgressToJson(this);
}

/// Sync Error
/// Detailed error information
@JsonSerializable()
class SyncError {
  final String errorId;
  final SyncErrorType type;
  final String message;
  final String? platform;
  final String? dataType;
  final DateTime timestamp;
  final bool isRetryable;
  final Map<String, dynamic> details;

  SyncError({
    required this.errorId,
    required this.type,
    required this.message,
    this.platform,
    this.dataType,
    required this.timestamp,
    this.isRetryable = true,
    this.details = const {},
  });

  /// Get user-friendly error message
  String get userMessage {
    switch (type) {
      case SyncErrorType.permission:
        return 'Permission required to access ${platform ?? 'health'} data';
      case SyncErrorType.network:
        return 'Network connection required for sync';
      case SyncErrorType.authentication:
        return 'Please re-authenticate with ${platform ?? 'health service'}';
      case SyncErrorType.rateLimit:
        return 'Too many requests. Please wait before syncing again';
      case SyncErrorType.dataFormat:
        return 'Data format error. Some records may be skipped';
      case SyncErrorType.serverError:
        return '${platform ?? 'Health'} service temporarily unavailable';
      case SyncErrorType.timeout:
        return 'Sync timed out. Try reducing the date range';
      case SyncErrorType.unknown:
        return message;
    }
  }

  factory SyncError.fromJson(Map<String, dynamic> json) => _$SyncErrorFromJson(json);
  Map<String, dynamic> toJson() => _$SyncErrorToJson(this);
}

/// Sync Error Types
enum SyncErrorType {
  permission('Permission Denied'),
  network('Network Error'),
  authentication('Authentication Failed'),
  rateLimit('Rate Limit Exceeded'),
  dataFormat('Data Format Error'),
  serverError('Server Error'),
  timeout('Timeout'),
  unknown('Unknown Error');

  const SyncErrorType(this.displayName);

  final String displayName;
}

/// Sync Statistics
/// Overall statistics about sync performance
@JsonSerializable()
class SyncStatistics {
  final int totalSyncAttempts;
  final int successfulSyncs;
  final int failedSyncs;
  final int partialSyncs;
  final DateTime firstSync;
  final Duration totalSyncTime;
  final Map<String, int> dataTypesCounts;
  final Map<String, int> platformCounts;
  final double averageSyncDuration; // minutes

  SyncStatistics({
    this.totalSyncAttempts = 0,
    this.successfulSyncs = 0,
    this.failedSyncs = 0,
    this.partialSyncs = 0,
    required this.firstSync,
    this.totalSyncTime = Duration.zero,
    this.dataTypesCounts = const {},
    this.platformCounts = const {},
    this.averageSyncDuration = 0.0,
  });

  /// Get sync success rate (0-1)
  double get successRate {
    if (totalSyncAttempts == 0) return 0.0;
    return successfulSyncs / totalSyncAttempts;
  }

  /// Get total data points synced
  int get totalDataPoints {
    return dataTypesCounts.values.fold(0, (sum, count) => sum + count);
  }

  /// Get most synced data type
  String? get mostSyncedDataType {
    if (dataTypesCounts.isEmpty) return null;
    
    var maxCount = 0;
    String? maxType;
    
    dataTypesCounts.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        maxType = type;
      }
    });
    
    return maxType;
  }

  factory SyncStatistics.fromJson(Map<String, dynamic> json) => 
      _$SyncStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$SyncStatisticsToJson(this);
}
