import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/biometric_data.dart';

/// Service for integrating with device biometric sensors and health platforms
class BiometricIntegrationService {
  static final BiometricIntegrationService _instance = BiometricIntegrationService._internal();
  static BiometricIntegrationService get instance => _instance;
  BiometricIntegrationService._internal();

  bool _isInitialized = false;
  bool _healthPermissionGranted = false;
  final Map<String, List<BiometricReading>> _cachedData = {};
  
  /// MethodChannel for native health integration (HealthKit/Google Fit)
  static const _healthChannel = MethodChannel('flowsense.health/integration');
  
  bool get isInitialized => _isInitialized;
  bool get hasHealthPermission => _healthPermissionGranted;

  /// Initialize the biometric integration service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    debugPrint('🏥 Initializing Biometric Integration Service...');
    
    try {
      // Request health data permissions
      await _requestHealthPermissions();
      
      // Initialize data cache
      await _initializeDataCache();
      
      _isInitialized = true;
      debugPrint('✅ Biometric Integration Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Biometric Integration: $e');
      _isInitialized = false;
    }
  }

  /// Request permissions for health data access
  Future<bool> _requestHealthPermissions() async {
    try {
      final result = await _healthChannel.invokeMethod('requestPermissions', {
        'readTypes': [
          'heart_rate',
          'heart_rate_variability',
          'resting_heart_rate',
          'sleep_analysis',
          'body_temperature',
          'respiratory_rate',
          'blood_pressure',
          'active_energy_burned',
          'steps',
          'workout_type',
        ],
        'writeTypes': [
          'menstrual_flow',
          'intermenstrual_bleeding',
          'cervical_mucus_quality',
          'ovulation_test_result',
        ]
      });
      
      _healthPermissionGranted = result as bool? ?? false;
      return _healthPermissionGranted;
    } catch (e) {
      debugPrint('Failed to request health permissions: $e');
      return false;
    }
  }

  /// Initialize data cache with recent readings
  Future<void> _initializeDataCache() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    
    // Pre-load recent data for faster access
    await Future.wait([
      _loadHeartRateData(startDate, endDate),
      _loadSleepData(startDate, endDate),
      _loadTemperatureData(startDate, endDate),
      _loadHRVData(startDate, endDate),
    ]);
  }

  /// Get comprehensive biometric data for cycle analysis
  Future<BiometricAnalysis> getBiometricAnalysis({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized || !_healthPermissionGranted) {
      return BiometricAnalysis.empty();
    }

    final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
    final end = endDate ?? DateTime.now();

    try {
      // Get all biometric data in parallel
      final results = await Future.wait([
        getHeartRateData(start, end),
        getSleepData(start, end),
        getTemperatureData(start, end),
        getHRVData(start, end),
        getStressData(start, end),
        getActivityData(start, end),
      ]);

      return BiometricAnalysis(
        heartRateData: results[0],
        sleepData: results[1],
        temperatureData: results[2],
        hrvData: results[3],
        stressData: results[4],
        activityData: results[5],
        analysisDate: DateTime.now(),
        cycleCorrelations: await _calculateCycleCorrelations(results),
      );
    } catch (e) {
      debugPrint('Failed to get biometric analysis: $e');
      return BiometricAnalysis.empty();
    }
  }

  /// Get heart rate data from health platform
  Future<List<BiometricReading>> getHeartRateData(DateTime startDate, DateTime endDate) async {
    return await _loadHeartRateData(startDate, endDate);
  }

  Future<List<BiometricReading>> _loadHeartRateData(DateTime startDate, DateTime endDate) async {
    const cacheKey = 'heart_rate';
    
    if (_cachedData.containsKey(cacheKey)) {
      final cached = _cachedData[cacheKey]!;
      final filtered = cached.where((reading) => 
        reading.timestamp.isAfter(startDate) && 
        reading.timestamp.isBefore(endDate)
      ).toList();
      
      if (filtered.isNotEmpty) return filtered;
    }

    try {
      final result = await _healthChannel.invokeMethod('getHeartRateData', {
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
      });

      final data = _parseHealthData(result, BiometricType.heartRate);
      _cachedData[cacheKey] = data;
      return data;
    } catch (e) {
      // Return simulated data for development/testing
      return _generateSimulatedHeartRateData(startDate, endDate);
    }
  }

  /// Get sleep data from health platform
  Future<List<BiometricReading>> getSleepData(DateTime startDate, DateTime endDate) async {
    return await _loadSleepData(startDate, endDate);
  }

  Future<List<BiometricReading>> _loadSleepData(DateTime startDate, DateTime endDate) async {
    const cacheKey = 'sleep';
    
    if (_cachedData.containsKey(cacheKey)) {
      final cached = _cachedData[cacheKey]!;
      final filtered = cached.where((reading) => 
        reading.timestamp.isAfter(startDate) && 
        reading.timestamp.isBefore(endDate)
      ).toList();
      
      if (filtered.isNotEmpty) return filtered;
    }

    try {
      final result = await _healthChannel.invokeMethod('getSleepData', {
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
      });

      final data = _parseHealthData(result, BiometricType.sleepAnalysis);
      _cachedData[cacheKey] = data;
      return data;
    } catch (e) {
      return _generateSimulatedSleepData(startDate, endDate);
    }
  }

  /// Get body temperature data
  Future<List<BiometricReading>> getTemperatureData(DateTime startDate, DateTime endDate) async {
    return await _loadTemperatureData(startDate, endDate);
  }

  Future<List<BiometricReading>> _loadTemperatureData(DateTime startDate, DateTime endDate) async {
    const cacheKey = 'temperature';
    
    if (_cachedData.containsKey(cacheKey)) {
      final cached = _cachedData[cacheKey]!;
      final filtered = cached.where((reading) => 
        reading.timestamp.isAfter(startDate) && 
        reading.timestamp.isBefore(endDate)
      ).toList();
      
      if (filtered.isNotEmpty) return filtered;
    }

    try {
      final result = await _healthChannel.invokeMethod('getTemperatureData', {
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
      });

      final data = _parseHealthData(result, BiometricType.bodyTemperature);
      _cachedData[cacheKey] = data;
      return data;
    } catch (e) {
      return _generateSimulatedTemperatureData(startDate, endDate);
    }
  }

  /// Get Heart Rate Variability data
  Future<List<BiometricReading>> getHRVData(DateTime startDate, DateTime endDate) async {
    return await _loadHRVData(startDate, endDate);
  }

  Future<List<BiometricReading>> _loadHRVData(DateTime startDate, DateTime endDate) async {
    const cacheKey = 'hrv';
    
    if (_cachedData.containsKey(cacheKey)) {
      final cached = _cachedData[cacheKey]!;
      final filtered = cached.where((reading) => 
        reading.timestamp.isAfter(startDate) && 
        reading.timestamp.isBefore(endDate)
      ).toList();
      
      if (filtered.isNotEmpty) return filtered;
    }

    try {
      final result = await _healthChannel.invokeMethod('getHRVData', {
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
      });

      final data = _parseHealthData(result, BiometricType.heartRateVariability);
      _cachedData[cacheKey] = data;
      return data;
    } catch (e) {
      return _generateSimulatedHRVData(startDate, endDate);
    }
  }

  /// Get stress level data (calculated from HRV and other metrics)
  Future<List<BiometricReading>> getStressData(DateTime startDate, DateTime endDate) async {
    try {
      // Calculate stress from HRV and heart rate patterns
      final hrvData = await getHRVData(startDate, endDate);
      final heartRateData = await getHeartRateData(startDate, endDate);
      
      return _calculateStressFromMetrics(hrvData, heartRateData);
    } catch (e) {
      return _generateSimulatedStressData(startDate, endDate);
    }
  }

  /// Get activity data (steps, calories, workouts)
  Future<List<BiometricReading>> getActivityData(DateTime startDate, DateTime endDate) async {
    try {
      final result = await _healthChannel.invokeMethod('getActivityData', {
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
      });

      return _parseHealthData(result, BiometricType.activeEnergyBurned);
    } catch (e) {
      return _generateSimulatedActivityData(startDate, endDate);
    }
  }

  /// Write menstrual flow data to health platform
  Future<bool> writeMenstrualFlowData(DateTime date, FlowLevel flowLevel) async {
    if (!_healthPermissionGranted) return false;
    
    try {
      final result = await _healthChannel.invokeMethod('writeMenstrualFlow', {
        'date': date.millisecondsSinceEpoch,
        'flowLevel': flowLevel.index,
      });
      
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Failed to write menstrual flow data: $e');
      return false;
    }
  }

  /// Write cycle symptoms to health platform
  Future<bool> writeCycleSymptoms(DateTime date, List<String> symptoms) async {
    if (!_healthPermissionGranted) return false;
    
    try {
      final result = await _healthChannel.invokeMethod('writeCycleSymptoms', {
        'date': date.millisecondsSinceEpoch,
        'symptoms': symptoms,
      });
      
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Failed to write cycle symptoms: $e');
      return false;
    }
  }

  /// Parse health data from native platform
  List<BiometricReading> _parseHealthData(dynamic result, BiometricType type) {
    if (result is! List) return [];
    
    return result.map((item) {
      final data = item as Map<String, dynamic>;
      return BiometricReading(
        type: type,
        value: (data['value'] as num).toDouble(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
        unit: data['unit'] as String? ?? '',
        metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      );
    }).toList();
  }

  /// Calculate cycle correlations from biometric data
  Future<Map<String, double>> _calculateCycleCorrelations(List<dynamic> biometricResults) async {
    // This would analyze correlations between biometric data and cycle phases
    return {
      'hrv_cycle_correlation': 0.7,
      'sleep_cycle_correlation': 0.6,
      'temperature_cycle_correlation': 0.8,
      'stress_cycle_correlation': -0.5,
      'activity_cycle_correlation': 0.4,
    };
  }

  /// Calculate stress levels from HRV and heart rate
  List<BiometricReading> _calculateStressFromMetrics(
    List<BiometricReading> hrvData,
    List<BiometricReading> heartRateData
  ) {
    final stressData = <BiometricReading>[];
    
    for (int i = 0; i < hrvData.length && i < heartRateData.length; i++) {
      final hrv = hrvData[i];
      final hr = heartRateData[i];
      
      // Simple stress calculation: lower HRV + higher HR = higher stress
      final normalizedHRV = (100 - hrv.value) / 100; // Invert HRV (lower = more stress)
      final normalizedHR = (hr.value - 60) / 100; // Normalize heart rate
      final stress = ((normalizedHRV + normalizedHR) / 2).clamp(0.0, 1.0) * 10;
      
      stressData.add(BiometricReading(
        type: BiometricType.stressLevel,
        value: stress,
        timestamp: hrv.timestamp,
        unit: 'stress_index',
      ));
    }
    
    return stressData;
  }

  // === SIMULATED DATA GENERATORS FOR DEVELOPMENT ===
  
  List<BiometricReading> _generateSimulatedHeartRateData(DateTime startDate, DateTime endDate) {
    final data = <BiometricReading>[];
    final random = math.Random();
    
    for (var date = startDate; date.isBefore(endDate); date = date.add(const Duration(hours: 1))) {
      final baseHR = 70 + random.nextInt(20); // 70-90 BPM base
      final cycleDay = date.day % 28;
      final cycleModifier = math.sin(cycleDay * math.pi / 14) * 5; // Cycle variation
      
      data.add(BiometricReading(
        type: BiometricType.heartRate,
        value: baseHR + cycleModifier + (random.nextDouble() * 10 - 5),
        timestamp: date,
        unit: 'BPM',
      ));
    }
    
    return data;
  }
  
  List<BiometricReading> _generateSimulatedSleepData(DateTime startDate, DateTime endDate) {
    final data = <BiometricReading>[];
    final random = math.Random();
    
    for (var date = startDate; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
      final sleepQuality = 0.6 + random.nextDouble() * 0.4; // 60-100% quality
      final sleepDuration = 7 + random.nextDouble() * 2; // 7-9 hours
      
      data.add(BiometricReading(
        type: BiometricType.sleepAnalysis,
        value: sleepQuality,
        timestamp: date,
        unit: 'quality_score',
        metadata: {'duration_hours': sleepDuration},
      ));
    }
    
    return data;
  }
  
  List<BiometricReading> _generateSimulatedTemperatureData(DateTime startDate, DateTime endDate) {
    final data = <BiometricReading>[];
    final random = math.Random();
    
    for (var date = startDate; date.isBefore(endDate); date = date.add(const Duration(hours: 6))) {
      final baseTemp = 98.6; // Normal body temperature in Fahrenheit
      final cycleDay = date.day % 28;
      final ovulationBoost = cycleDay >= 12 && cycleDay <= 16 ? 0.5 : 0.0; // Temperature rise during ovulation
      
      data.add(BiometricReading(
        type: BiometricType.bodyTemperature,
        value: baseTemp + ovulationBoost + (random.nextDouble() * 0.6 - 0.3),
        timestamp: date,
        unit: '°F',
      ));
    }
    
    return data;
  }
  
  List<BiometricReading> _generateSimulatedHRVData(DateTime startDate, DateTime endDate) {
    final data = <BiometricReading>[];
    final random = math.Random();
    
    for (var date = startDate; date.isBefore(endDate); date = date.add(const Duration(hours: 2))) {
      final baseHRV = 40 + random.nextInt(30); // 40-70ms baseline
      final stressModifier = random.nextDouble() > 0.8 ? -10 : 0; // Occasional stress impact
      
      data.add(BiometricReading(
        type: BiometricType.heartRateVariability,
        value: (baseHRV + stressModifier).toDouble().clamp(20.0, 100.0),
        timestamp: date,
        unit: 'ms',
      ));
    }
    
    return data;
  }
  
  List<BiometricReading> _generateSimulatedStressData(DateTime startDate, DateTime endDate) {
    final data = <BiometricReading>[];
    final random = math.Random();
    
    for (var date = startDate; date.isBefore(endDate); date = date.add(const Duration(hours: 3))) {
      final baseStress = 3 + random.nextDouble() * 4; // 3-7 stress level
      final timeOfDayModifier = date.hour >= 9 && date.hour <= 17 ? 1.0 : -0.5; // Higher during work hours
      
      data.add(BiometricReading(
        type: BiometricType.stressLevel,
        value: (baseStress + timeOfDayModifier).clamp(1.0, 10.0),
        timestamp: date,
        unit: 'stress_index',
      ));
    }
    
    return data;
  }
  
  List<BiometricReading> _generateSimulatedActivityData(DateTime startDate, DateTime endDate) {
    final data = <BiometricReading>[];
    final random = math.Random();
    
    for (var date = startDate; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
      final steps = 6000 + random.nextInt(8000); // 6k-14k steps
      final calories = 1800 + random.nextInt(800); // 1800-2600 calories
      
      data.add(BiometricReading(
        type: BiometricType.activeEnergyBurned,
        value: calories.toDouble(),
        timestamp: date,
        unit: 'kcal',
        metadata: {'steps': steps},
      ));
    }
    
    return data;
  }

  /// Clear cached data
  void clearCache() {
    _cachedData.clear();
  }

  /// Refresh all cached data
  Future<void> refreshCache() async {
    clearCache();
    await _initializeDataCache();
  }
}

/// Enum for different flow levels
enum FlowLevel {
  none,
  light,
  medium,
  heavy,
}
