// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_sync_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthSyncDetails _$HealthSyncDetailsFromJson(
  Map<String, dynamic> json,
) => HealthSyncDetails(
  syncId: json['syncId'] as String,
  status: $enumDecode(_$HealthSyncStatusEnumMap, json['status']),
  lastSyncAttempt: DateTime.parse(json['lastSyncAttempt'] as String),
  lastSuccessfulSync: json['lastSuccessfulSync'] == null
      ? null
      : DateTime.parse(json['lastSuccessfulSync'] as String),
  platformStatus:
      (json['platformStatus'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, PlatformSyncStatus.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  errors:
      (json['errors'] as List<dynamic>?)
          ?.map((e) => SyncError.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  currentProgress: json['currentProgress'] == null
      ? null
      : SyncProgress.fromJson(json['currentProgress'] as Map<String, dynamic>),
  statistics: SyncStatistics.fromJson(
    json['statistics'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$HealthSyncDetailsToJson(HealthSyncDetails instance) =>
    <String, dynamic>{
      'syncId': instance.syncId,
      'status': _$HealthSyncStatusEnumMap[instance.status]!,
      'lastSyncAttempt': instance.lastSyncAttempt.toIso8601String(),
      'lastSuccessfulSync': instance.lastSuccessfulSync?.toIso8601String(),
      'platformStatus': instance.platformStatus,
      'errors': instance.errors,
      'currentProgress': instance.currentProgress,
      'statistics': instance.statistics,
    };

const _$HealthSyncStatusEnumMap = {
  HealthSyncStatus.disconnected: 'disconnected',
  HealthSyncStatus.connecting: 'connecting',
  HealthSyncStatus.connected: 'connected',
  HealthSyncStatus.syncing: 'syncing',
  HealthSyncStatus.syncComplete: 'syncComplete',
  HealthSyncStatus.partialSync: 'partialSync',
  HealthSyncStatus.error: 'error',
  HealthSyncStatus.permissionDenied: 'permissionDenied',
  HealthSyncStatus.networkError: 'networkError',
  HealthSyncStatus.serverError: 'serverError',
};

PlatformSyncStatus _$PlatformSyncStatusFromJson(Map<String, dynamic> json) =>
    PlatformSyncStatus(
      platformName: json['platformName'] as String,
      isConnected: json['isConnected'] as bool? ?? false,
      lastSync: json['lastSync'] == null
          ? null
          : DateTime.parse(json['lastSync'] as String),
      lastAttempt: json['lastAttempt'] == null
          ? null
          : DateTime.parse(json['lastAttempt'] as String),
      lastResult:
          $enumDecodeNullable(_$SyncResultEnumMap, json['lastResult']) ??
          SyncResult.pending,
      supportedDataTypes:
          (json['supportedDataTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      syncedDataCounts:
          (json['syncedDataCounts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      dataQuality:
          $enumDecodeNullable(_$SyncDataQualityEnumMap, json['dataQuality']) ??
          SyncDataQuality.unknown,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$PlatformSyncStatusToJson(PlatformSyncStatus instance) =>
    <String, dynamic>{
      'platformName': instance.platformName,
      'isConnected': instance.isConnected,
      'lastSync': instance.lastSync?.toIso8601String(),
      'lastAttempt': instance.lastAttempt?.toIso8601String(),
      'lastResult': _$SyncResultEnumMap[instance.lastResult]!,
      'supportedDataTypes': instance.supportedDataTypes,
      'syncedDataCounts': instance.syncedDataCounts,
      'dataQuality': _$SyncDataQualityEnumMap[instance.dataQuality]!,
      'errorMessage': instance.errorMessage,
    };

const _$SyncResultEnumMap = {
  SyncResult.pending: 'pending',
  SyncResult.success: 'success',
  SyncResult.partial: 'partial',
  SyncResult.error: 'error',
  SyncResult.cancelled: 'cancelled',
};

const _$SyncDataQualityEnumMap = {
  SyncDataQuality.unknown: 'unknown',
  SyncDataQuality.poor: 'poor',
  SyncDataQuality.fair: 'fair',
  SyncDataQuality.good: 'good',
  SyncDataQuality.excellent: 'excellent',
};

SyncProgress _$SyncProgressFromJson(Map<String, dynamic> json) => SyncProgress(
  taskId: json['taskId'] as String,
  currentTask: json['currentTask'] as String,
  totalSteps: (json['totalSteps'] as num).toInt(),
  completedSteps: (json['completedSteps'] as num?)?.toInt() ?? 0,
  currentPlatform: json['currentPlatform'] as String?,
  currentDataType: json['currentDataType'] as String?,
  processedRecords: (json['processedRecords'] as num?)?.toInt() ?? 0,
  totalRecords: (json['totalRecords'] as num?)?.toInt() ?? 0,
  startTime: DateTime.parse(json['startTime'] as String),
  estimatedTimeRemaining: json['estimatedTimeRemaining'] == null
      ? null
      : Duration(microseconds: (json['estimatedTimeRemaining'] as num).toInt()),
);

Map<String, dynamic> _$SyncProgressToJson(SyncProgress instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'currentTask': instance.currentTask,
      'totalSteps': instance.totalSteps,
      'completedSteps': instance.completedSteps,
      'currentPlatform': instance.currentPlatform,
      'currentDataType': instance.currentDataType,
      'processedRecords': instance.processedRecords,
      'totalRecords': instance.totalRecords,
      'startTime': instance.startTime.toIso8601String(),
      'estimatedTimeRemaining': instance.estimatedTimeRemaining?.inMicroseconds,
    };

SyncError _$SyncErrorFromJson(Map<String, dynamic> json) => SyncError(
  errorId: json['errorId'] as String,
  type: $enumDecode(_$SyncErrorTypeEnumMap, json['type']),
  message: json['message'] as String,
  platform: json['platform'] as String?,
  dataType: json['dataType'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  isRetryable: json['isRetryable'] as bool? ?? true,
  details: json['details'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$SyncErrorToJson(SyncError instance) => <String, dynamic>{
  'errorId': instance.errorId,
  'type': _$SyncErrorTypeEnumMap[instance.type]!,
  'message': instance.message,
  'platform': instance.platform,
  'dataType': instance.dataType,
  'timestamp': instance.timestamp.toIso8601String(),
  'isRetryable': instance.isRetryable,
  'details': instance.details,
};

const _$SyncErrorTypeEnumMap = {
  SyncErrorType.permission: 'permission',
  SyncErrorType.network: 'network',
  SyncErrorType.authentication: 'authentication',
  SyncErrorType.rateLimit: 'rateLimit',
  SyncErrorType.dataFormat: 'dataFormat',
  SyncErrorType.serverError: 'serverError',
  SyncErrorType.timeout: 'timeout',
  SyncErrorType.unknown: 'unknown',
};

SyncStatistics _$SyncStatisticsFromJson(Map<String, dynamic> json) =>
    SyncStatistics(
      totalSyncAttempts: (json['totalSyncAttempts'] as num?)?.toInt() ?? 0,
      successfulSyncs: (json['successfulSyncs'] as num?)?.toInt() ?? 0,
      failedSyncs: (json['failedSyncs'] as num?)?.toInt() ?? 0,
      partialSyncs: (json['partialSyncs'] as num?)?.toInt() ?? 0,
      firstSync: DateTime.parse(json['firstSync'] as String),
      totalSyncTime: json['totalSyncTime'] == null
          ? Duration.zero
          : Duration(microseconds: (json['totalSyncTime'] as num).toInt()),
      dataTypesCounts:
          (json['dataTypesCounts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      platformCounts:
          (json['platformCounts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      averageSyncDuration:
          (json['averageSyncDuration'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$SyncStatisticsToJson(SyncStatistics instance) =>
    <String, dynamic>{
      'totalSyncAttempts': instance.totalSyncAttempts,
      'successfulSyncs': instance.successfulSyncs,
      'failedSyncs': instance.failedSyncs,
      'partialSyncs': instance.partialSyncs,
      'firstSync': instance.firstSync.toIso8601String(),
      'totalSyncTime': instance.totalSyncTime.inMicroseconds,
      'dataTypesCounts': instance.dataTypesCounts,
      'platformCounts': instance.platformCounts,
      'averageSyncDuration': instance.averageSyncDuration,
    };
