import 'package:json_annotation/json_annotation.dart';
import 'biometric_data.dart';

part 'wearable_device.g.dart';

/// Wearable Device Model
/// Represents connected health devices and fitness trackers
@JsonSerializable()
class WearableDevice {
  final String deviceId;
  final String name;
  final DeviceType type;
  final String manufacturer;
  final bool isConnected;
  final int? batteryLevel;
  final DateTime? lastSync;
  final List<BiometricType> supportedMetrics;
  final String? firmwareVersion;
  final String? hardwareVersion;
  final DeviceStatus status;
  final ConnectionType connectionType;
  final Map<String, dynamic> capabilities;
  final DeviceSettings settings;

  WearableDevice({
    required this.deviceId,
    required this.name,
    required this.type,
    required this.manufacturer,
    this.isConnected = false,
    this.batteryLevel,
    this.lastSync,
    this.supportedMetrics = const [],
    this.firmwareVersion,
    this.hardwareVersion,
    this.status = DeviceStatus.active,
    this.connectionType = ConnectionType.bluetooth,
    this.capabilities = const {},
    this.settings = const DeviceSettings(),
  });

  // Computed properties
  bool get needsCharging => batteryLevel != null && batteryLevel! < 20;
  bool get isLowBattery => batteryLevel != null && batteryLevel! < 10;
  bool get isRecentlySync => lastSync != null && 
      DateTime.now().difference(lastSync!).inMinutes < 30;
  bool get needsSync => lastSync != null && 
      DateTime.now().difference(lastSync!).inHours > 24;
  
  /// Get time since last sync
  Duration? get timeSinceSync => lastSync != null ? DateTime.now().difference(lastSync!) : null;

  /// Get device health status based on battery, connectivity, and sync
  DeviceHealth get deviceHealth {
    if (!isConnected) return DeviceHealth.disconnected;
    if (isLowBattery) return DeviceHealth.critical;
    if (needsCharging) return DeviceHealth.warning;
    if (needsSync) return DeviceHealth.warning;
    return DeviceHealth.good;
  }

  /// Get formatted battery status
  String get batteryStatus {
    if (batteryLevel == null) return 'Unknown';
    
    final level = batteryLevel!;
    if (level >= 80) return 'Excellent ($level%)';
    if (level >= 50) return 'Good ($level%)';
    if (level >= 20) return 'Low ($level%)';
    return 'Critical ($level%)';
  }

  /// Get connection status message
  String get connectionStatus {
    if (!isConnected) return 'Disconnected';
    
    switch (connectionType) {
      case ConnectionType.bluetooth:
        return 'Connected via Bluetooth';
      case ConnectionType.wifi:
        return 'Connected via Wi-Fi';
      case ConnectionType.cellular:
        return 'Connected via Cellular';
      case ConnectionType.cloud:
        return 'Syncing with Cloud';
      case ConnectionType.usb:
        return 'Connected via USB';
    }
  }

  /// Get last sync status message
  String get syncStatusMessage {
    if (lastSync == null) return 'Never synced';
    
    final timeSince = timeSinceSync!;
    
    if (timeSince.inMinutes < 1) return 'Just synced';
    if (timeSince.inMinutes < 60) return '${timeSince.inMinutes}m ago';
    if (timeSince.inHours < 24) return '${timeSince.inHours}h ago';
    if (timeSince.inDays < 7) return '${timeSince.inDays}d ago';
    return 'Over a week ago';
  }

  /// Check if device supports specific biometric type
  bool supportsMetric(BiometricType metric) {
    return supportedMetrics.contains(metric);
  }

  /// Get supported metrics by category
  Map<BiometricCategory, List<BiometricType>> getSupportedMetricsByCategory() {
    final categoryMap = <BiometricCategory, List<BiometricType>>{};
    
    for (final metric in supportedMetrics) {
      if (!categoryMap.containsKey(metric.category)) {
        categoryMap[metric.category] = [];
      }
      categoryMap[metric.category]!.add(metric);
    }
    
    return categoryMap;
  }

  /// Get device compatibility score (0-100)
  int get compatibilityScore {
    var score = 0;
    
    // Base score for connection
    if (isConnected) score += 30;
    
    // Battery score
    if (batteryLevel != null) {
      score += (batteryLevel! / 5).round(); // Max 20 points
    }
    
    // Metrics support score
    score += (supportedMetrics.length * 2).clamp(0, 30);
    
    // Firmware/sync score
    if (isRecentlySync) score += 10;
    if (firmwareVersion != null) score += 10;
    
    return score.clamp(0, 100);
  }

  /// Get device capabilities summary
  DeviceCapabilities get deviceCapabilities {
    return DeviceCapabilities(
      hasGPS: capabilities['gps'] ?? false,
      hasHeartRateSensor: supportsMetric(BiometricType.heartRate),
      hasAccelerometer: capabilities['accelerometer'] ?? false,
      hasGyroscope: capabilities['gyroscope'] ?? false,
      hasAltimeter: capabilities['altimeter'] ?? false,
      hasThermometer: supportsMetric(BiometricType.bodyTemperature),
      hasWaterResistance: capabilities['waterResistance'] ?? false,
      hasSleepTracking: supportsMetric(BiometricType.sleep),
      hasStressMonitoring: supportsMetric(BiometricType.stressLevel),
      hasBloodOxygenSensor: supportsMetric(BiometricType.bloodOxygen),
    );
  }

  factory WearableDevice.fromJson(Map<String, dynamic> json) => _$WearableDeviceFromJson(json);
  Map<String, dynamic> toJson() => _$WearableDeviceToJson(this);

  WearableDevice copyWith({
    String? deviceId,
    String? name,
    DeviceType? type,
    String? manufacturer,
    bool? isConnected,
    int? batteryLevel,
    DateTime? lastSync,
    List<BiometricType>? supportedMetrics,
    String? firmwareVersion,
    String? hardwareVersion,
    DeviceStatus? status,
    ConnectionType? connectionType,
    Map<String, dynamic>? capabilities,
    DeviceSettings? settings,
  }) {
    return WearableDevice(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      type: type ?? this.type,
      manufacturer: manufacturer ?? this.manufacturer,
      isConnected: isConnected ?? this.isConnected,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      lastSync: lastSync ?? this.lastSync,
      supportedMetrics: supportedMetrics ?? this.supportedMetrics,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      hardwareVersion: hardwareVersion ?? this.hardwareVersion,
      status: status ?? this.status,
      connectionType: connectionType ?? this.connectionType,
      capabilities: capabilities ?? this.capabilities,
      settings: settings ?? this.settings,
    );
  }
}

/// Device Types
enum DeviceType {
  appleWatch('Apple Watch', '⌚', 'Apple'),
  fitbit('Fitbit', '⌚', 'Fitbit'),
  garmin('Garmin', '⌚', 'Garmin'),
  samsung('Samsung Galaxy Watch', '⌚', 'Samsung'),
  polar('Polar', '⌚', 'Polar'),
  suunto('Suunto', '⌚', 'Suunto'),
  ouraRing('Oura Ring', '💍', 'Oura'),
  whoopBand('WHOOP Strap', '📿', 'WHOOP'),
  xiaomi('Mi Band', '📿', 'Xiaomi'),
  huawei('Huawei Watch', '⌚', 'Huawei'),
  smartScale('Smart Scale', '⚖️', 'Various'),
  chestStrap('Heart Rate Monitor', '❤️', 'Various'),
  glucoseMeter('Glucose Monitor', '🩸', 'Various'),
  bloodPressureMonitor('Blood Pressure Monitor', '🩺', 'Various'),
  thermometer('Smart Thermometer', '🌡️', 'Various');

  const DeviceType(this.displayName, this.icon, this.defaultManufacturer);

  final String displayName;
  final String icon;
  final String defaultManufacturer;

  /// Get typical battery life for device type
  Duration get typicalBatteryLife {
    switch (this) {
      case DeviceType.appleWatch:
        return const Duration(hours: 18);
      case DeviceType.fitbit:
        return const Duration(days: 6);
      case DeviceType.garmin:
        return const Duration(days: 7);
      case DeviceType.ouraRing:
        return const Duration(days: 7);
      case DeviceType.whoopBand:
        return const Duration(days: 5);
      case DeviceType.xiaomi:
        return const Duration(days: 14);
      case DeviceType.polar:
        return const Duration(hours: 30);
      case DeviceType.smartScale:
        return const Duration(days: 365); // Battery scales
      default:
        return const Duration(days: 7);
    }
  }

  /// Get common metrics supported by device type
  List<BiometricType> get commonMetrics {
    switch (this) {
      case DeviceType.appleWatch:
        return [
          BiometricType.heartRate,
          BiometricType.steps,
          BiometricType.activeCalories,
          BiometricType.sleep,
          BiometricType.bloodOxygen,
          BiometricType.heartRateVariability,
        ];
      case DeviceType.fitbit:
        return [
          BiometricType.heartRate,
          BiometricType.steps,
          BiometricType.activeCalories,
          BiometricType.sleep,
          BiometricType.stressLevel,
        ];
      case DeviceType.ouraRing:
        return [
          BiometricType.heartRate,
          BiometricType.heartRateVariability,
          BiometricType.bodyTemperature,
          BiometricType.sleep,
          BiometricType.readiness,
        ];
      case DeviceType.smartScale:
        return [
          BiometricType.weight,
          BiometricType.bodyFat,
          BiometricType.muscleMass,
        ];
      case DeviceType.bloodPressureMonitor:
        return [
          BiometricType.bloodPressureSystolic,
          BiometricType.bloodPressureDiastolic,
        ];
      default:
        return [BiometricType.heartRate, BiometricType.steps];
    }
  }
}

/// Device Status
enum DeviceStatus {
  active('Active', 'Device is functioning normally'),
  inactive('Inactive', 'Device is not in use'),
  charging('Charging', 'Device is currently charging'),
  updating('Updating', 'Firmware update in progress'),
  error('Error', 'Device has encountered an error'),
  maintenance('Maintenance', 'Device is in maintenance mode');

  const DeviceStatus(this.displayName, this.description);

  final String displayName;
  final String description;

  int get color {
    switch (this) {
      case DeviceStatus.active:
        return 0xFF4CAF50; // Green
      case DeviceStatus.charging:
        return 0xFF2196F3; // Blue
      case DeviceStatus.updating:
        return 0xFFFF9800; // Orange
      case DeviceStatus.inactive:
        return 0xFF9E9E9E; // Grey
      case DeviceStatus.error:
        return 0xFFF44336; // Red
      case DeviceStatus.maintenance:
        return 0xFFFF5722; // Deep Orange
    }
  }
}

/// Connection Types
enum ConnectionType {
  bluetooth('Bluetooth', '📶'),
  wifi('Wi-Fi', '📶'),
  cellular('Cellular', '📱'),
  cloud('Cloud Sync', '☁️'),
  usb('USB', '🔌');

  const ConnectionType(this.displayName, this.icon);

  final String displayName;
  final String icon;
}

/// Device Health Status
enum DeviceHealth {
  good('Good', 'Device is working optimally', 0xFF4CAF50),
  warning('Warning', 'Minor issues detected', 0xFFFF9800),
  critical('Critical', 'Immediate attention required', 0xFFF44336),
  disconnected('Disconnected', 'Device is not connected', 0xFF9E9E9E);

  const DeviceHealth(this.displayName, this.description, this.color);

  final String displayName;
  final String description;
  final int color;

  String get icon {
    switch (this) {
      case DeviceHealth.good:
        return '✅';
      case DeviceHealth.warning:
        return '⚠️';
      case DeviceHealth.critical:
        return '🚨';
      case DeviceHealth.disconnected:
        return '📵';
    }
  }
}

/// Device Settings
@JsonSerializable()
class DeviceSettings {
  final bool autoSync;
  final int syncInterval; // minutes
  final bool notificationsEnabled;
  final bool batteryOptimization;
  final Map<BiometricType, bool> enabledMetrics;
  final SyncQuality syncQuality;
  final bool backgroundSync;

  const DeviceSettings({
    this.autoSync = true,
    this.syncInterval = 15,
    this.notificationsEnabled = true,
    this.batteryOptimization = false,
    this.enabledMetrics = const {},
    this.syncQuality = SyncQuality.balanced,
    this.backgroundSync = true,
  });

  factory DeviceSettings.fromJson(Map<String, dynamic> json) => _$DeviceSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceSettingsToJson(this);
}

/// Sync Quality Options
enum SyncQuality {
  minimal('Minimal', 'Basic data only, saves battery'),
  balanced('Balanced', 'Good balance of data and battery'),
  comprehensive('Comprehensive', 'All available data, higher battery usage');

  const SyncQuality(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Device Capabilities
class DeviceCapabilities {
  final bool hasGPS;
  final bool hasHeartRateSensor;
  final bool hasAccelerometer;
  final bool hasGyroscope;
  final bool hasAltimeter;
  final bool hasThermometer;
  final bool hasWaterResistance;
  final bool hasSleepTracking;
  final bool hasStressMonitoring;
  final bool hasBloodOxygenSensor;

  DeviceCapabilities({
    this.hasGPS = false,
    this.hasHeartRateSensor = false,
    this.hasAccelerometer = false,
    this.hasGyroscope = false,
    this.hasAltimeter = false,
    this.hasThermometer = false,
    this.hasWaterResistance = false,
    this.hasSleepTracking = false,
    this.hasStressMonitoring = false,
    this.hasBloodOxygenSensor = false,
  });

  /// Get total capability count
  int get totalCapabilities {
    var count = 0;
    if (hasGPS) count++;
    if (hasHeartRateSensor) count++;
    if (hasAccelerometer) count++;
    if (hasGyroscope) count++;
    if (hasAltimeter) count++;
    if (hasThermometer) count++;
    if (hasWaterResistance) count++;
    if (hasSleepTracking) count++;
    if (hasStressMonitoring) count++;
    if (hasBloodOxygenSensor) count++;
    return count;
  }

  /// Get capabilities as list of strings
  List<String> get capabilitiesList {
    final capabilities = <String>[];
    if (hasGPS) capabilities.add('GPS');
    if (hasHeartRateSensor) capabilities.add('Heart Rate');
    if (hasAccelerometer) capabilities.add('Accelerometer');
    if (hasGyroscope) capabilities.add('Gyroscope');
    if (hasAltimeter) capabilities.add('Altimeter');
    if (hasThermometer) capabilities.add('Temperature');
    if (hasWaterResistance) capabilities.add('Water Resistant');
    if (hasSleepTracking) capabilities.add('Sleep Tracking');
    if (hasStressMonitoring) capabilities.add('Stress Monitoring');
    if (hasBloodOxygenSensor) capabilities.add('Blood Oxygen');
    return capabilities;
  }
}

/// Device Sync History
@JsonSerializable()
class DeviceSyncHistory {
  final String deviceId;
  final List<SyncRecord> syncHistory;
  final DateTime lastSuccessfulSync;
  final int totalSyncAttempts;
  final int successfulSyncs;
  final int failedSyncs;

  DeviceSyncHistory({
    required this.deviceId,
    this.syncHistory = const [],
    required this.lastSuccessfulSync,
    this.totalSyncAttempts = 0,
    this.successfulSyncs = 0,
    this.failedSyncs = 0,
  });

  /// Get sync success rate
  double get syncSuccessRate {
    if (totalSyncAttempts == 0) return 0.0;
    return successfulSyncs / totalSyncAttempts;
  }

  /// Get average sync duration
  Duration? get averageSyncDuration {
    final completedSyncs = syncHistory.where((s) => s.duration != null).toList();
    if (completedSyncs.isEmpty) return null;
    
    final totalDuration = completedSyncs
        .map((s) => s.duration!.inMilliseconds)
        .reduce((a, b) => a + b);
    
    return Duration(milliseconds: (totalDuration / completedSyncs.length).round());
  }

  factory DeviceSyncHistory.fromJson(Map<String, dynamic> json) => _$DeviceSyncHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceSyncHistoryToJson(this);
}

/// Sync Record
@JsonSerializable()
class SyncRecord {
  final String syncId;
  final DateTime startTime;
  final DateTime? endTime;
  final SyncStatus status;
  final int dataPointsSynced;
  final String? errorMessage;
  final Duration? duration;

  SyncRecord({
    required this.syncId,
    required this.startTime,
    this.endTime,
    required this.status,
    this.dataPointsSynced = 0,
    this.errorMessage,
    this.duration,
  });

  factory SyncRecord.fromJson(Map<String, dynamic> json) => _$SyncRecordFromJson(json);
  Map<String, dynamic> toJson() => _$SyncRecordToJson(this);
}

/// Sync Status
enum SyncStatus {
  inProgress('In Progress', '⏳'),
  completed('Completed', '✅'),
  failed('Failed', '❌'),
  partialSync('Partial', '⚠️'),
  cancelled('Cancelled', '🚫');

  const SyncStatus(this.displayName, this.icon);

  final String displayName;
  final String icon;
}

/// Device Pairing Information
@JsonSerializable()
class DevicePairingInfo {
  final String deviceId;
  final String pairingCode;
  final DateTime pairingDate;
  final String pairingMethod;
  final bool isVerified;
  final Map<String, String> pairingMetadata;

  DevicePairingInfo({
    required this.deviceId,
    required this.pairingCode,
    required this.pairingDate,
    required this.pairingMethod,
    this.isVerified = false,
    this.pairingMetadata = const {},
  });

  factory DevicePairingInfo.fromJson(Map<String, dynamic> json) => _$DevicePairingInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DevicePairingInfoToJson(this);
}
