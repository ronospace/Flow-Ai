import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/biometric_data.dart';
import '../models/wearable_device.dart';
import '../models/health_sync_status.dart';
import '../models/biometric_insights.dart';

/// Advanced Biometric Integration Service
/// Handles integration with Apple Health, Google Fit, and various wearable devices
class BiometricIntegrationService {
  static final BiometricIntegrationService _instance = BiometricIntegrationService._internal();
  factory BiometricIntegrationService() => _instance;
  BiometricIntegrationService._internal();

  bool _isInitialized = false;
  final Map<String, WearableDevice> _connectedDevices = {};
  final List<BiometricData> _biometricHistory = [];
  HealthSyncStatus _syncStatus = HealthSyncStatus.disconnected;
  final StreamController<BiometricData> _biometricStreamController = StreamController.broadcast();
  final StreamController<HealthSyncStatus> _syncStatusController = StreamController.broadcast();

  // Real-time data streams
  Stream<BiometricData> get biometricDataStream => _biometricStreamController.stream;
  Stream<HealthSyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Initialize biometric integration service
  Future<void> initialize() async {
    try {
      debugPrint('🫀 Initializing Biometric Integration Service...');
      
      // Check platform permissions
      await _requestHealthPermissions();
      
      // Initialize platform-specific health services
      await _initializePlatformHealth();
      
      // Discover and connect to available wearable devices
      await _discoverWearableDevices();
      
      // Start background sync
      await _startBackgroundSync();
      
      _isInitialized = true;
      _updateSyncStatus(HealthSyncStatus.connected);
      
      debugPrint('✅ Biometric Integration Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Biometric Integration Service: $e');
      _updateSyncStatus(HealthSyncStatus.error);
      rethrow;
    }
  }

  // === HEALTH PLATFORM INTEGRATION ===

  /// Connect to Apple Health
  Future<bool> connectAppleHealth() async {
    debugPrint('🍎 Connecting to Apple Health...');
    
    try {
      // Request Apple Health permissions
      final permissions = [
        HealthDataType.heartRate,
        HealthDataType.steps,
        HealthDataType.activeEnergyBurned,
        HealthDataType.restingHeartRate,
        HealthDataType.heartRateVariability,
        HealthDataType.sleepAnalysis,
        HealthDataType.bodyTemperature,
        HealthDataType.bloodOxygenSaturation,
        HealthDataType.respiratoryRate,
        HealthDataType.bodyMass,
        HealthDataType.bodyFatPercentage,
        HealthDataType.menstrualFlow,
        HealthDataType.ovulationTestResult,
        HealthDataType.basalBodyTemperature,
      ];
      
      // Simulate permission request (in real app, use health plugin)
      await Future.delayed(const Duration(seconds: 2));
      
      // Start syncing recent data
      await _syncAppleHealthData();
      
      debugPrint('✅ Apple Health connected successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to connect Apple Health: $e');
      return false;
    }
  }

  /// Connect to Google Fit
  Future<bool> connectGoogleFit() async {
    debugPrint('🏃‍♀️ Connecting to Google Fit...');
    
    try {
      // Request Google Fit permissions
      final scopes = [
        'FITNESS_ACTIVITY_READ',
        'FITNESS_BODY_READ',
        'FITNESS_HEART_RATE_READ',
        'FITNESS_SLEEP_READ',
        'FITNESS_REPRODUCTIVE_HEALTH_READ',
      ];
      
      // Simulate connection (in real app, use google_fit plugin)
      await Future.delayed(const Duration(seconds: 2));
      
      // Start syncing recent data
      await _syncGoogleFitData();
      
      debugPrint('✅ Google Fit connected successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to connect Google Fit: $e');
      return false;
    }
  }

  // === WEARABLE DEVICE INTEGRATION ===

  /// Discover and connect to wearable devices
  Future<List<WearableDevice>> discoverWearableDevices() async {
    debugPrint('🔍 Discovering wearable devices...');
    
    _updateSyncStatus(HealthSyncStatus.syncing);
    
    final devices = <WearableDevice>[];
    
    // Simulate device discovery
    await Future.delayed(const Duration(seconds: 3));
    
    // Mock discovered devices
    devices.addAll([
      WearableDevice(
        deviceId: 'apple_watch_1',
        name: 'Apple Watch Series 9',
        type: DeviceType.appleWatch,
        manufacturer: 'Apple',
        isConnected: true,
        batteryLevel: 85,
        lastSync: DateTime.now().subtract(const Duration(minutes: 5)),
        supportedMetrics: [
          BiometricType.heartRate,
          BiometricType.steps,
          BiometricType.activeCalories,
          BiometricType.sleep,
          BiometricType.heartRateVariability,
          BiometricType.bloodOxygen,
          BiometricType.respiratoryRate,
        ],
        firmwareVersion: '10.1.1',
      ),
      WearableDevice(
        deviceId: 'fitbit_sense_2',
        name: 'Fitbit Sense 2',
        type: DeviceType.fitbit,
        manufacturer: 'Fitbit',
        isConnected: false,
        batteryLevel: 62,
        lastSync: DateTime.now().subtract(const Duration(hours: 2)),
        supportedMetrics: [
          BiometricType.heartRate,
          BiometricType.steps,
          BiometricType.activeCalories,
          BiometricType.sleep,
          BiometricType.skinTemperature,
          BiometricType.stressLevel,
        ],
        firmwareVersion: '4.2.1',
      ),
      WearableDevice(
        deviceId: 'oura_ring_3',
        name: 'Oura Ring Gen 3',
        type: DeviceType.ouraRing,
        manufacturer: 'Oura',
        isConnected: true,
        batteryLevel: 45,
        lastSync: DateTime.now().subtract(const Duration(minutes: 15)),
        supportedMetrics: [
          BiometricType.heartRate,
          BiometricType.heartRateVariability,
          BiometricType.bodyTemperature,
          BiometricType.sleep,
          BiometricType.activity,
          BiometricType.readiness,
        ],
        firmwareVersion: '3.1.2',
      ),
    ]);
    
    // Store discovered devices
    for (final device in devices) {
      _connectedDevices[device.deviceId] = device;
    }
    
    _updateSyncStatus(HealthSyncStatus.connected);
    debugPrint('✅ Discovered ${devices.length} wearable devices');
    
    return devices;
  }

  /// Connect to specific wearable device
  Future<bool> connectWearableDevice(String deviceId) async {
    debugPrint('🔗 Connecting to device: $deviceId');
    
    final device = _connectedDevices[deviceId];
    if (device == null) {
      debugPrint('❌ Device not found: $deviceId');
      return false;
    }
    
    try {
      // Simulate device connection
      await Future.delayed(const Duration(seconds: 2));
      
      // Update device connection status
      final updatedDevice = device.copyWith(
        isConnected: true,
        lastSync: DateTime.now(),
      );
      _connectedDevices[deviceId] = updatedDevice;
      
      // Start syncing data from device
      await _syncWearableDeviceData(deviceId);
      
      debugPrint('✅ Connected to ${device.name}');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to connect to ${device.name}: $e');
      return false;
    }
  }

  /// Disconnect from wearable device
  Future<void> disconnectWearableDevice(String deviceId) async {
    debugPrint('🔌 Disconnecting from device: $deviceId');
    
    final device = _connectedDevices[deviceId];
    if (device != null) {
      final updatedDevice = device.copyWith(isConnected: false);
      _connectedDevices[deviceId] = updatedDevice;
      debugPrint('✅ Disconnected from ${device.name}');
    }
  }

  // === REAL-TIME DATA STREAMING ===

  /// Start real-time biometric data streaming
  Future<void> startRealTimeMonitoring() async {
    debugPrint('📡 Starting real-time biometric monitoring...');
    
    // Simulate real-time data streaming
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (_connectedDevices.values.any((device) => device.isConnected)) {
        final biometricData = await _generateRealtimeBiometricData();
        _biometricStreamController.add(biometricData);
        _biometricHistory.add(biometricData);
        
        // Trigger AI analysis for anomaly detection
        await _analyzeRealTimeData(biometricData);
      }
    });
  }

  /// Stop real-time monitoring
  void stopRealTimeMonitoring() {
    debugPrint('⏹️ Stopping real-time biometric monitoring...');
    // Implementation would stop timers and streams
  }

  // === DATA SYNCHRONIZATION ===

  /// Sync all biometric data
  Future<void> syncAllBiometricData() async {
    debugPrint('🔄 Syncing all biometric data...');
    _updateSyncStatus(HealthSyncStatus.syncing);
    
    try {
      // Sync from all connected sources
      await Future.wait([
        _syncAppleHealthData(),
        _syncGoogleFitData(),
        _syncConnectedWearableDevices(),
      ]);
      
      // Generate insights after sync
      await _generateBiometricInsights();
      
      _updateSyncStatus(HealthSyncStatus.connected);
      debugPrint('✅ All biometric data synced successfully');
    } catch (e) {
      debugPrint('❌ Failed to sync biometric data: $e');
      _updateSyncStatus(HealthSyncStatus.error);
    }
  }

  /// Get biometric data for date range
  Future<List<BiometricData>> getBiometricData({
    required DateTime startDate,
    required DateTime endDate,
    List<BiometricType>? types,
  }) async {
    debugPrint('📊 Retrieving biometric data from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
    
    var filteredData = _biometricHistory.where((data) {
      final isInRange = data.timestamp.isAfter(startDate) && data.timestamp.isBefore(endDate);
      final isTypeMatch = types == null || types.contains(data.type);
      return isInRange && isTypeMatch;
    }).toList();
    
    // Sort by timestamp
    filteredData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return filteredData;
  }

  /// Get latest biometric readings
  Map<BiometricType, BiometricData> getLatestReadings() {
    final latestReadings = <BiometricType, BiometricData>{};
    
    for (final data in _biometricHistory) {
      if (!latestReadings.containsKey(data.type) ||
          data.timestamp.isAfter(latestReadings[data.type]!.timestamp)) {
        latestReadings[data.type] = data;
      }
    }
    
    return latestReadings;
  }

  // === INSIGHTS AND ANALYTICS ===

  /// Generate comprehensive biometric insights
  Future<BiometricInsights> generateInsights({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    debugPrint('🧠 Generating biometric insights...');
    
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    final data = await getBiometricData(startDate: start, endDate: end);
    
    // Generate insights based on data patterns
    final insights = BiometricInsights(
      insightsId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user', // Replace with actual user ID
      generatedDate: DateTime.now(),
      periodStart: start,
      periodEnd: end,
      totalDataPoints: data.length,
      keyMetrics: _calculateKeyMetrics(data),
      trends: _analyzeTrends(data),
      anomalies: _detectAnomalies(data),
      correlations: _findCorrelations(data),
      healthScore: _calculateHealthScore(data),
      recommendations: _generateRecommendations(data),
      riskFactors: _identifyRiskFactors(data),
      summary: _generateInsightsSummary(data),
    );
    
    debugPrint('✅ Generated insights with ${insights.keyMetrics.length} key metrics');
    return insights;
  }

  /// Get health score based on biometric data
  double calculateHealthScore({DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final recentData = _biometricHistory.where((data) =>
        data.timestamp.isAfter(targetDate.subtract(const Duration(days: 7)))
    ).toList();
    
    return _calculateHealthScore(recentData);
  }

  /// Detect anomalies in biometric data
  Future<List<BiometricAnomaly>> detectAnomalies({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    debugPrint('🔍 Detecting biometric anomalies...');
    
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
    final end = endDate ?? DateTime.now();
    
    final data = await getBiometricData(startDate: start, endDate: end);
    return _detectAnomalies(data);
  }

  // === DEVICE MANAGEMENT ===

  /// Get all connected devices
  List<WearableDevice> getConnectedDevices() {
    return _connectedDevices.values.where((device) => device.isConnected).toList();
  }

  /// Get device battery levels
  Map<String, int> getDeviceBatteryLevels() {
    final batteryLevels = <String, int>{};
    for (final device in _connectedDevices.values) {
      batteryLevels[device.name] = device.batteryLevel ?? 0;
    }
    return batteryLevels;
  }

  /// Check device sync status
  Future<Map<String, DateTime?>> getDeviceSyncStatus() async {
    final syncStatus = <String, DateTime?>{};
    for (final device in _connectedDevices.values) {
      syncStatus[device.deviceId] = device.lastSync;
    }
    return syncStatus;
  }

  // === PRIVATE HELPER METHODS ===

  Future<void> _requestHealthPermissions() async {
    // Platform-specific permission requests would go here
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _initializePlatformHealth() async {
    // Initialize platform-specific health services
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await connectAppleHealth();
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      await connectGoogleFit();
    }
  }

  Future<void> _discoverWearableDevices() async {
    await discoverWearableDevices();
  }

  Future<void> _startBackgroundSync() async {
    // Start periodic background sync
    Timer.periodic(const Duration(minutes: 15), (timer) async {
      await _syncConnectedWearableDevices();
    });
  }

  Future<void> _syncAppleHealthData() async {
    // Simulate Apple Health data sync
    await Future.delayed(const Duration(seconds: 1));
    await _addMockBiometricData('Apple Health');
  }

  Future<void> _syncGoogleFitData() async {
    // Simulate Google Fit data sync
    await Future.delayed(const Duration(seconds: 1));
    await _addMockBiometricData('Google Fit');
  }

  Future<void> _syncConnectedWearableDevices() async {
    for (final device in _connectedDevices.values) {
      if (device.isConnected) {
        await _syncWearableDeviceData(device.deviceId);
      }
    }
  }

  Future<void> _syncWearableDeviceData(String deviceId) async {
    final device = _connectedDevices[deviceId];
    if (device != null && device.isConnected) {
      await _addMockBiometricData(device.name);
      
      // Update last sync time
      final updatedDevice = device.copyWith(lastSync: DateTime.now());
      _connectedDevices[deviceId] = updatedDevice;
    }
  }

  Future<BiometricData> _generateRealtimeBiometricData() async {
    final random = Random();
    final types = [
      BiometricType.heartRate,
      BiometricType.steps,
      BiometricType.activeCalories,
      BiometricType.bloodOxygen,
    ];
    
    final type = types[random.nextInt(types.length)];
    double value;
    String unit;
    
    switch (type) {
      case BiometricType.heartRate:
        value = 60 + random.nextDouble() * 40; // 60-100 bpm
        unit = 'bpm';
        break;
      case BiometricType.steps:
        value = random.nextDouble() * 100; // Steps per minute
        unit = 'steps';
        break;
      case BiometricType.activeCalories:
        value = random.nextDouble() * 10; // Calories per minute
        unit = 'cal';
        break;
      case BiometricType.bloodOxygen:
        value = 95 + random.nextDouble() * 5; // 95-100%
        unit = '%';
        break;
      default:
        value = random.nextDouble() * 100;
        unit = 'unit';
    }
    
    return BiometricData(
      dataId: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      value: value,
      unit: unit,
      timestamp: DateTime.now(),
      source: 'Real-time Monitor',
      deviceId: _connectedDevices.values.first.deviceId,
      confidence: 0.95,
    );
  }

  Future<void> _addMockBiometricData(String source) async {
    final random = Random();
    final now = DateTime.now();
    
    // Add various types of biometric data
    final mockData = [
      BiometricData(
        dataId: '${now.millisecondsSinceEpoch}_hr',
        type: BiometricType.heartRate,
        value: 65 + random.nextDouble() * 30,
        unit: 'bpm',
        timestamp: now.subtract(Duration(minutes: random.nextInt(60))),
        source: source,
        confidence: 0.95,
      ),
      BiometricData(
        dataId: '${now.millisecondsSinceEpoch}_steps',
        type: BiometricType.steps,
        value: random.nextDouble() * 10000,
        unit: 'steps',
        timestamp: now.subtract(Duration(hours: random.nextInt(24))),
        source: source,
        confidence: 0.98,
      ),
      BiometricData(
        dataId: '${now.millisecondsSinceEpoch}_cal',
        type: BiometricType.activeCalories,
        value: random.nextDouble() * 500,
        unit: 'cal',
        timestamp: now.subtract(Duration(hours: random.nextInt(24))),
        source: source,
        confidence: 0.92,
      ),
    ];
    
    _biometricHistory.addAll(mockData);
  }

  Future<void> _analyzeRealTimeData(BiometricData data) async {
    // Implement real-time anomaly detection
    final anomalies = await detectAnomalies(
      startDate: DateTime.now().subtract(const Duration(hours: 1)),
      endDate: DateTime.now(),
    );
    
    if (anomalies.isNotEmpty) {
      debugPrint('⚠️ Detected ${anomalies.length} anomalies in real-time data');
      // Trigger notifications or alerts
    }
  }

  Future<void> _generateBiometricInsights() async {
    final insights = await generateInsights();
    debugPrint('📈 Generated biometric insights: Health Score ${insights.healthScore}');
  }

  Map<BiometricType, double> _calculateKeyMetrics(List<BiometricData> data) {
    final metrics = <BiometricType, double>{};
    
    for (final type in BiometricType.values) {
      final typeData = data.where((d) => d.type == type).toList();
      if (typeData.isNotEmpty) {
        final average = typeData.map((d) => d.value).reduce((a, b) => a + b) / typeData.length;
        metrics[type] = average;
      }
    }
    
    return metrics;
  }

  Map<BiometricType, TrendDirection> _analyzeTrends(List<BiometricData> data) {
    final trends = <BiometricType, TrendDirection>{};
    
    for (final type in BiometricType.values) {
      final typeData = data.where((d) => d.type == type).toList();
      if (typeData.length >= 2) {
        typeData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        final first = typeData.first.value;
        final last = typeData.last.value;
        
        if (last > first * 1.05) {
          trends[type] = TrendDirection.increasing;
        } else if (last < first * 0.95) {
          trends[type] = TrendDirection.decreasing;
        } else {
          trends[type] = TrendDirection.stable;
        }
      }
    }
    
    return trends;
  }

  List<BiometricAnomaly> _detectAnomalies(List<BiometricData> data) {
    final anomalies = <BiometricAnomaly>[];
    
    for (final type in BiometricType.values) {
      final typeData = data.where((d) => d.type == type).toList();
      if (typeData.length >= 5) {
        final values = typeData.map((d) => d.value).toList();
        final mean = values.reduce((a, b) => a + b) / values.length;
        final variance = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
        final stdDev = sqrt(variance);
        
        for (final dataPoint in typeData) {
          final zScore = (dataPoint.value - mean) / stdDev;
          if (zScore.abs() > 2.5) {
            anomalies.add(BiometricAnomaly(
              anomalyId: dataPoint.dataId,
              type: type,
              value: dataPoint.value,
              expectedRange: Range(mean - 2 * stdDev, mean + 2 * stdDev),
              severity: zScore.abs() > 3.0 ? AnomalySeverity.high : AnomalySeverity.medium,
              timestamp: dataPoint.timestamp,
              description: 'Value ${dataPoint.value.toStringAsFixed(1)} is ${zScore.toStringAsFixed(1)} standard deviations from normal',
            ));
          }
        }
      }
    }
    
    return anomalies;
  }

  Map<String, double> _findCorrelations(List<BiometricData> data) {
    // Simplified correlation analysis
    final correlations = <String, double>{};
    
    // Example: Heart rate vs activity correlation
    final heartRateData = data.where((d) => d.type == BiometricType.heartRate).toList();
    final stepsData = data.where((d) => d.type == BiometricType.steps).toList();
    
    if (heartRateData.isNotEmpty && stepsData.isNotEmpty) {
      correlations['Heart Rate vs Steps'] = 0.65; // Mock correlation
    }
    
    return correlations;
  }

  double _calculateHealthScore(List<BiometricData> data) {
    if (data.isEmpty) return 0.0;
    
    var score = 0.0;
    var factors = 0;
    
    // Heart rate score
    final heartRateData = data.where((d) => d.type == BiometricType.heartRate).toList();
    if (heartRateData.isNotEmpty) {
      final avgHeartRate = heartRateData.map((d) => d.value).reduce((a, b) => a + b) / heartRateData.length;
      if (avgHeartRate >= 60 && avgHeartRate <= 100) {
        score += 25;
      } else {
        score += max(0, 25 - (avgHeartRate - 80).abs());
      }
      factors++;
    }
    
    // Steps score
    final stepsData = data.where((d) => d.type == BiometricType.steps).toList();
    if (stepsData.isNotEmpty) {
      final totalSteps = stepsData.map((d) => d.value).reduce((a, b) => a + b);
      final dailySteps = totalSteps / max(1, data.length / 1440); // Approximate daily steps
      score += min(25, dailySteps / 400); // Max 25 points for 10,000 steps
      factors++;
    }
    
    // Add other factors...
    if (factors > 0) {
      score = score / factors * 4; // Normalize to 100
    }
    
    return score.clamp(0.0, 100.0);
  }

  List<HealthRecommendation> _generateRecommendations(List<BiometricData> data) {
    final recommendations = <HealthRecommendation>[];
    
    // Heart rate recommendations
    final heartRateData = data.where((d) => d.type == BiometricType.heartRate).toList();
    if (heartRateData.isNotEmpty) {
      final avgHeartRate = heartRateData.map((d) => d.value).reduce((a, b) => a + b) / heartRateData.length;
      if (avgHeartRate > 100) {
        recommendations.add(HealthRecommendation(
          recommendationId: 'hr_high',
          type: RecommendationType.lifestyle,
          title: 'Elevated Heart Rate',
          description: 'Your average heart rate is elevated. Consider stress reduction techniques.',
          priority: RecommendationPriority.medium,
        ));
      }
    }
    
    // Steps recommendations
    final stepsData = data.where((d) => d.type == BiometricType.steps).toList();
    if (stepsData.isNotEmpty) {
      final totalSteps = stepsData.map((d) => d.value).reduce((a, b) => a + b);
      final dailySteps = totalSteps / max(1, data.length / 1440);
      if (dailySteps < 8000) {
        recommendations.add(HealthRecommendation(
          recommendationId: 'steps_low',
          type: RecommendationType.activity,
          title: 'Increase Daily Activity',
          description: 'Aim for at least 8,000-10,000 steps per day for optimal health.',
          priority: RecommendationPriority.high,
        ));
      }
    }
    
    return recommendations;
  }

  List<RiskFactor> _identifyRiskFactors(List<BiometricData> data) {
    final riskFactors = <RiskFactor>[];
    
    // Identify potential health risks based on biometric patterns
    final heartRateData = data.where((d) => d.type == BiometricType.heartRate).toList();
    if (heartRateData.isNotEmpty) {
      final avgHeartRate = heartRateData.map((d) => d.value).reduce((a, b) => a + b) / heartRateData.length;
      if (avgHeartRate > 100) {
        riskFactors.add(RiskFactor(
          factorId: 'elevated_hr',
          name: 'Elevated Resting Heart Rate',
          riskLevel: RiskLevel.medium,
          description: 'Consistently elevated heart rate may indicate cardiovascular stress.',
          relatedMetrics: [BiometricType.heartRate],
          riskScore: ((avgHeartRate - 100) / 100 * 75).clamp(0, 75),
          identifiedDate: DateTime.now(),
        ));
      }
    }
    
    return riskFactors;
  }
  
  InsightsSummary _generateInsightsSummary(List<BiometricData> data) {
    final healthScore = _calculateHealthScore(data);
    
    // Generate overall assessment
    String assessment;
    InsightsCategory category;
    if (healthScore >= 85) {
      assessment = 'Your biometric data shows excellent health patterns';
      category = InsightsCategory.excellent;
    } else if (healthScore >= 70) {
      assessment = 'Your health metrics are generally good with room for optimization';
      category = InsightsCategory.good;
    } else if (healthScore >= 55) {
      assessment = 'Your health data shows moderate patterns that could be improved';
      category = InsightsCategory.fair;
    } else {
      assessment = 'Your biometric data suggests several areas need attention';
      category = InsightsCategory.poor;
    }
    
    // Key findings
    final keyFindings = <String>[];
    final improvements = <String>[];
    final concerns = <String>[];
    
    final metrics = _calculateKeyMetrics(data);
    if (metrics.containsKey(BiometricType.steps)) {
      final avgSteps = metrics[BiometricType.steps]!;
      if (avgSteps > 8000) {
        improvements.add('Good daily step count average');
      } else {
        concerns.add('Daily step count could be improved');
      }
      keyFindings.add('Average daily steps: ${avgSteps.toInt()}');
    }
    
    if (metrics.containsKey(BiometricType.heartRate)) {
      final avgHR = metrics[BiometricType.heartRate]!;
      keyFindings.add('Average heart rate: ${avgHR.toInt()} bpm');
      if (avgHR > 100) {
        concerns.add('Elevated resting heart rate detected');
      } else if (avgHR >= 60 && avgHR <= 100) {
        improvements.add('Heart rate within healthy range');
      }
    }
    
    final nextSteps = concerns.isNotEmpty
        ? 'Focus on addressing identified concerns and continue regular tracking'
        : 'Continue maintaining your healthy patterns and regular tracking';
    
    return InsightsSummary(
      overallAssessment: assessment,
      keyFindings: keyFindings,
      improvements: improvements,
      concerns: concerns,
      nextSteps: nextSteps,
      category: category,
    );
  }

  void _updateSyncStatus(HealthSyncStatus status) {
    _syncStatus = status;
    _syncStatusController.add(status);
  }

  void dispose() {
    _biometricStreamController.close();
    _syncStatusController.close();
  }
}

// Health Data Types Enum
enum HealthDataType {
  heartRate,
  steps,
  activeEnergyBurned,
  restingHeartRate,
  heartRateVariability,
  sleepAnalysis,
  bodyTemperature,
  bloodOxygenSaturation,
  respiratoryRate,
  bodyMass,
  bodyFatPercentage,
  menstrualFlow,
  ovulationTestResult,
  basalBodyTemperature,
}
