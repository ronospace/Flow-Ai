// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wearable_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WearableDevice _$WearableDeviceFromJson(Map<String, dynamic> json) =>
    WearableDevice(
      deviceId: json['deviceId'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$DeviceTypeEnumMap, json['type']),
      manufacturer: json['manufacturer'] as String,
      isConnected: json['isConnected'] as bool? ?? false,
      batteryLevel: (json['batteryLevel'] as num?)?.toInt(),
      lastSync: json['lastSync'] == null
          ? null
          : DateTime.parse(json['lastSync'] as String),
      supportedMetrics:
          (json['supportedMetrics'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$BiometricTypeEnumMap, e))
              .toList() ??
          const [],
      firmwareVersion: json['firmwareVersion'] as String?,
      hardwareVersion: json['hardwareVersion'] as String?,
      status:
          $enumDecodeNullable(_$DeviceStatusEnumMap, json['status']) ??
          DeviceStatus.active,
      connectionType:
          $enumDecodeNullable(
            _$ConnectionTypeEnumMap,
            json['connectionType'],
          ) ??
          ConnectionType.bluetooth,
      capabilities: json['capabilities'] as Map<String, dynamic>? ?? const {},
      settings: json['settings'] == null
          ? const DeviceSettings()
          : DeviceSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WearableDeviceToJson(WearableDevice instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'name': instance.name,
      'type': _$DeviceTypeEnumMap[instance.type]!,
      'manufacturer': instance.manufacturer,
      'isConnected': instance.isConnected,
      'batteryLevel': instance.batteryLevel,
      'lastSync': instance.lastSync?.toIso8601String(),
      'supportedMetrics': instance.supportedMetrics
          .map((e) => _$BiometricTypeEnumMap[e]!)
          .toList(),
      'firmwareVersion': instance.firmwareVersion,
      'hardwareVersion': instance.hardwareVersion,
      'status': _$DeviceStatusEnumMap[instance.status]!,
      'connectionType': _$ConnectionTypeEnumMap[instance.connectionType]!,
      'capabilities': instance.capabilities,
      'settings': instance.settings,
    };

const _$DeviceTypeEnumMap = {
  DeviceType.appleWatch: 'appleWatch',
  DeviceType.fitbit: 'fitbit',
  DeviceType.garmin: 'garmin',
  DeviceType.samsung: 'samsung',
  DeviceType.polar: 'polar',
  DeviceType.suunto: 'suunto',
  DeviceType.ouraRing: 'ouraRing',
  DeviceType.whoopBand: 'whoopBand',
  DeviceType.xiaomi: 'xiaomi',
  DeviceType.huawei: 'huawei',
  DeviceType.smartScale: 'smartScale',
  DeviceType.chestStrap: 'chestStrap',
  DeviceType.glucoseMeter: 'glucoseMeter',
  DeviceType.bloodPressureMonitor: 'bloodPressureMonitor',
  DeviceType.thermometer: 'thermometer',
};

const _$BiometricTypeEnumMap = {
  BiometricType.heartRate: 'heartRate',
  BiometricType.restingHeartRate: 'restingHeartRate',
  BiometricType.heartRateVariability: 'heartRateVariability',
  BiometricType.bloodPressureSystolic: 'bloodPressureSystolic',
  BiometricType.bloodPressureDiastolic: 'bloodPressureDiastolic',
  BiometricType.bloodOxygen: 'bloodOxygen',
  BiometricType.steps: 'steps',
  BiometricType.distance: 'distance',
  BiometricType.activeCalories: 'activeCalories',
  BiometricType.totalCalories: 'totalCalories',
  BiometricType.activeMinutes: 'activeMinutes',
  BiometricType.exerciseMinutes: 'exerciseMinutes',
  BiometricType.weight: 'weight',
  BiometricType.bodyFat: 'bodyFat',
  BiometricType.muscleMass: 'muscleMass',
  BiometricType.boneDensity: 'boneDensity',
  BiometricType.waterPercentage: 'waterPercentage',
  BiometricType.bodyTemperature: 'bodyTemperature',
  BiometricType.skinTemperature: 'skinTemperature',
  BiometricType.basalBodyTemperature: 'basalBodyTemperature',
  BiometricType.sleep: 'sleep',
  BiometricType.sleepQuality: 'sleepQuality',
  BiometricType.deepSleep: 'deepSleep',
  BiometricType.remSleep: 'remSleep',
  BiometricType.sleepEfficiency: 'sleepEfficiency',
  BiometricType.stressLevel: 'stressLevel',
  BiometricType.mentalWellbeing: 'mentalWellbeing',
  BiometricType.mindfulnessMinutes: 'mindfulnessMinutes',
  BiometricType.respiratoryRate: 'respiratoryRate',
  BiometricType.vo2Max: 'vo2Max',
  BiometricType.menstrualFlow: 'menstrualFlow',
  BiometricType.ovulationTest: 'ovulationTest',
  BiometricType.cervicalMucus: 'cervicalMucus',
  BiometricType.activity: 'activity',
  BiometricType.readiness: 'readiness',
  BiometricType.recovery: 'recovery',
  BiometricType.energy: 'energy',
};

const _$DeviceStatusEnumMap = {
  DeviceStatus.active: 'active',
  DeviceStatus.inactive: 'inactive',
  DeviceStatus.charging: 'charging',
  DeviceStatus.updating: 'updating',
  DeviceStatus.error: 'error',
  DeviceStatus.maintenance: 'maintenance',
};

const _$ConnectionTypeEnumMap = {
  ConnectionType.bluetooth: 'bluetooth',
  ConnectionType.wifi: 'wifi',
  ConnectionType.cellular: 'cellular',
  ConnectionType.cloud: 'cloud',
  ConnectionType.usb: 'usb',
};

DeviceSettings _$DeviceSettingsFromJson(Map<String, dynamic> json) =>
    DeviceSettings(
      autoSync: json['autoSync'] as bool? ?? true,
      syncInterval: (json['syncInterval'] as num?)?.toInt() ?? 15,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      batteryOptimization: json['batteryOptimization'] as bool? ?? false,
      enabledMetrics:
          (json['enabledMetrics'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry($enumDecode(_$BiometricTypeEnumMap, k), e as bool),
          ) ??
          const {},
      syncQuality:
          $enumDecodeNullable(_$SyncQualityEnumMap, json['syncQuality']) ??
          SyncQuality.balanced,
      backgroundSync: json['backgroundSync'] as bool? ?? true,
    );

Map<String, dynamic> _$DeviceSettingsToJson(DeviceSettings instance) =>
    <String, dynamic>{
      'autoSync': instance.autoSync,
      'syncInterval': instance.syncInterval,
      'notificationsEnabled': instance.notificationsEnabled,
      'batteryOptimization': instance.batteryOptimization,
      'enabledMetrics': instance.enabledMetrics.map(
        (k, e) => MapEntry(_$BiometricTypeEnumMap[k]!, e),
      ),
      'syncQuality': _$SyncQualityEnumMap[instance.syncQuality]!,
      'backgroundSync': instance.backgroundSync,
    };

const _$SyncQualityEnumMap = {
  SyncQuality.minimal: 'minimal',
  SyncQuality.balanced: 'balanced',
  SyncQuality.comprehensive: 'comprehensive',
};

DeviceSyncHistory _$DeviceSyncHistoryFromJson(Map<String, dynamic> json) =>
    DeviceSyncHistory(
      deviceId: json['deviceId'] as String,
      syncHistory:
          (json['syncHistory'] as List<dynamic>?)
              ?.map((e) => SyncRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastSuccessfulSync: DateTime.parse(json['lastSuccessfulSync'] as String),
      totalSyncAttempts: (json['totalSyncAttempts'] as num?)?.toInt() ?? 0,
      successfulSyncs: (json['successfulSyncs'] as num?)?.toInt() ?? 0,
      failedSyncs: (json['failedSyncs'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DeviceSyncHistoryToJson(DeviceSyncHistory instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'syncHistory': instance.syncHistory,
      'lastSuccessfulSync': instance.lastSuccessfulSync.toIso8601String(),
      'totalSyncAttempts': instance.totalSyncAttempts,
      'successfulSyncs': instance.successfulSyncs,
      'failedSyncs': instance.failedSyncs,
    };

SyncRecord _$SyncRecordFromJson(Map<String, dynamic> json) => SyncRecord(
  syncId: json['syncId'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  status: $enumDecode(_$SyncStatusEnumMap, json['status']),
  dataPointsSynced: (json['dataPointsSynced'] as num?)?.toInt() ?? 0,
  errorMessage: json['errorMessage'] as String?,
  duration: json['duration'] == null
      ? null
      : Duration(microseconds: (json['duration'] as num).toInt()),
);

Map<String, dynamic> _$SyncRecordToJson(SyncRecord instance) =>
    <String, dynamic>{
      'syncId': instance.syncId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'status': _$SyncStatusEnumMap[instance.status]!,
      'dataPointsSynced': instance.dataPointsSynced,
      'errorMessage': instance.errorMessage,
      'duration': instance.duration?.inMicroseconds,
    };

const _$SyncStatusEnumMap = {
  SyncStatus.inProgress: 'inProgress',
  SyncStatus.completed: 'completed',
  SyncStatus.failed: 'failed',
  SyncStatus.partialSync: 'partialSync',
  SyncStatus.cancelled: 'cancelled',
};

DevicePairingInfo _$DevicePairingInfoFromJson(Map<String, dynamic> json) =>
    DevicePairingInfo(
      deviceId: json['deviceId'] as String,
      pairingCode: json['pairingCode'] as String,
      pairingDate: DateTime.parse(json['pairingDate'] as String),
      pairingMethod: json['pairingMethod'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
      pairingMetadata:
          (json['pairingMetadata'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$DevicePairingInfoToJson(DevicePairingInfo instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'pairingCode': instance.pairingCode,
      'pairingDate': instance.pairingDate.toIso8601String(),
      'pairingMethod': instance.pairingMethod,
      'isVerified': instance.isVerified,
      'pairingMetadata': instance.pairingMetadata,
    };
