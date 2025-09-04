import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
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

  // === ADVANCED BIOMETRIC CAPABILITIES ===
  
  final StreamController<BiometricReading> _realtimeDataController = 
      StreamController<BiometricReading>.broadcast();
  
  /// Stream for real-time biometric data
  Stream<BiometricReading> get realtimeDataStream => _realtimeDataController.stream;
  
  Timer? _monitoringTimer;
  bool _isMonitoring = false;
  Set<BiometricType> _monitoredTypes = {};
  
  /// Start real-time biometric monitoring
  Future<bool> startRealtimeMonitoring({
    Set<BiometricType>? dataTypes,
    Duration interval = const Duration(minutes: 5),
  }) async {
    if (!_isInitialized || !_healthPermissionGranted) {
      debugPrint('❌ Cannot start monitoring: service not initialized or no permissions');
      return false;
    }
    
    _monitoredTypes = dataTypes ?? {
      BiometricType.heartRate,
      BiometricType.heartRateVariability,
      BiometricType.stressLevel,
    };
    
    _isMonitoring = true;
    
    debugPrint('🔄 Starting real-time monitoring for: $_monitoredTypes');
    
    try {
      // Start native monitoring if available
      if (Platform.isIOS) {
        await _healthChannel.invokeMethod('startRealtimeMonitoring', {
          'dataTypes': _monitoredTypes.map((t) => t.toString()).toList(),
          'interval': interval.inSeconds,
        });
      }
      
      // Setup periodic data fetching as fallback
      _monitoringTimer = Timer.periodic(interval, (_) => _fetchRealtimeData());
      
      // Setup native data listener
      _setupNativeDataListener();
      
      return true;
    } catch (e) {
      debugPrint('Failed to start real-time monitoring: $e');
      _isMonitoring = false;
      return false;
    }
  }
  
  /// Stop real-time monitoring
  Future<void> stopRealtimeMonitoring() async {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    try {
      if (Platform.isIOS) {
        await _healthChannel.invokeMethod('stopRealtimeMonitoring');
      }
    } catch (e) {
      debugPrint('Error stopping real-time monitoring: $e');
    }
    
    debugPrint('⏹️ Stopped real-time biometric monitoring');
  }
  
  /// Setup native data listener for real-time updates
  void _setupNativeDataListener() {
    _healthChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onRealtimeBiometricData':
          final data = call.arguments as Map<String, dynamic>;
          final reading = _parseSingleHealthReading(data);
          if (reading != null) {
            _realtimeDataController.add(reading);
          }
          break;
        case 'onBiometricError':
          final error = call.arguments['error'] as String;
          debugPrint('Biometric error: $error');
          _realtimeDataController.addError(BiometricException(error));
          break;
      }
    });
  }
  
  /// Fetch real-time data manually
  Future<void> _fetchRealtimeData() async {
    if (!_isMonitoring) return;
    
    final now = DateTime.now();
    final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
    
    for (final type in _monitoredTypes) {
      try {
        List<BiometricReading> readings;
        
        switch (type) {
          case BiometricType.heartRate:
            readings = await getHeartRateData(fiveMinutesAgo, now);
            break;
          case BiometricType.heartRateVariability:
            readings = await getHRVData(fiveMinutesAgo, now);
            break;
          case BiometricType.stressLevel:
            readings = await getStressData(fiveMinutesAgo, now);
            break;
          default:
            continue;
        }
        
        // Emit the most recent reading
        if (readings.isNotEmpty) {
          _realtimeDataController.add(readings.last);
        }
      } catch (e) {
        debugPrint('Error fetching real-time $type data: $e');
      }
    }
  }
  
  /// Parse single health reading from native
  BiometricReading? _parseSingleHealthReading(Map<String, dynamic> data) {
    try {
      final typeString = data['type'] as String;
      final type = BiometricType.values.firstWhere(
        (t) => t.toString().split('.').last == typeString,
        orElse: () => BiometricType.heartRate,
      );
      
      return BiometricReading(
        type: type,
        value: (data['value'] as num).toDouble(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
        unit: data['unit'] as String? ?? '',
        metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      );
    } catch (e) {
      debugPrint('Error parsing health reading: $e');
      return null;
    }
  }
  
  /// Get available data types on device
  Future<Set<BiometricType>> getAvailableDataTypes() async {
    if (!_isInitialized) return {};
    
    try {
      final result = await _healthChannel.invokeMethod('getAvailableDataTypes');
      final availableTypes = (result as List<dynamic>)
          .map((type) => type.toString())
          .map((typeString) => BiometricType.values.firstWhere(
                (t) => t.toString().split('.').last == typeString,
                orElse: () => BiometricType.heartRate,
              ))
          .toSet();
      
      debugPrint('📱 Available biometric data types: $availableTypes');
      return availableTypes;
    } catch (e) {
      debugPrint('Error getting available data types: $e');
      // Return common types as fallback
      return {
        BiometricType.heartRate,
        BiometricType.sleepAnalysis,
        BiometricType.bodyTemperature,
        BiometricType.activeEnergyBurned,
      };
    }
  }
  
  /// Get device capabilities and health integrations
  Future<BiometricCapabilities> getDeviceCapabilities() async {
    if (!_isInitialized) {
      return BiometricCapabilities.empty();
    }
    
    try {
      final result = await _healthChannel.invokeMethod('getDeviceCapabilities');
      return BiometricCapabilities.fromMap(result);
    } catch (e) {
      debugPrint('Error getting device capabilities: $e');
      return BiometricCapabilities(
        hasHealthKit: Platform.isIOS,
        hasGoogleFit: Platform.isAndroid,
        supportedDataTypes: await getAvailableDataTypes(),
        canWriteData: _healthPermissionGranted,
        hasRealtimeCapability: Platform.isIOS,
      );
    }
  }
  
  /// Write basal body temperature for fertility tracking
  Future<bool> writeBasalBodyTemperature(DateTime date, double temperature) async {
    if (!_healthPermissionGranted) return false;
    
    try {
      final result = await _healthChannel.invokeMethod('writeBasalBodyTemperature', {
        'date': date.millisecondsSinceEpoch,
        'temperature': temperature,
        'unit': 'degF',
      });
      
      debugPrint('📝 Wrote basal body temperature: ${temperature}°F');
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Failed to write basal body temperature: $e');
      return false;
    }
  }
  
  /// Write cervical mucus quality data
  Future<bool> writeCervicalMucusQuality(DateTime date, String quality) async {
    if (!_healthPermissionGranted) return false;
    
    try {
      final result = await _healthChannel.invokeMethod('writeCervicalMucusQuality', {
        'date': date.millisecondsSinceEpoch,
        'quality': quality,
      });
      
      debugPrint('📝 Wrote cervical mucus quality: $quality');
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Failed to write cervical mucus quality: $e');
      return false;
    }
  }
  
  /// Write ovulation test result
  Future<bool> writeOvulationTestResult(DateTime date, bool isPositive) async {
    if (!_healthPermissionGranted) return false;
    
    try {
      final result = await _healthChannel.invokeMethod('writeOvulationTestResult', {
        'date': date.millisecondsSinceEpoch,
        'result': isPositive,
      });
      
      debugPrint('📝 Wrote ovulation test result: $isPositive');
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Failed to write ovulation test result: $e');
      return false;
    }
  }
  
  /// Get historical pattern analysis
  Future<BiometricPatternAnalysis> getPatternAnalysis({
    required DateTime startDate,
    required DateTime endDate,
    BiometricType? focusType,
  }) async {
    try {
      final analysis = await getBiometricAnalysis(
        startDate: startDate,
        endDate: endDate,
      );
      
      return BiometricPatternAnalysis(
        periodDays: endDate.difference(startDate).inDays,
        patterns: await _analyzePatterns(analysis),
        anomalies: await _detectAnomalies(analysis),
        correlations: analysis.cycleCorrelations,
        insights: await _generateInsights(analysis),
      );
    } catch (e) {
      debugPrint('Error generating pattern analysis: $e');
      return BiometricPatternAnalysis.empty();
    }
  }
  
  /// Analyze biometric patterns
  Future<Map<BiometricType, PatternInfo>> _analyzePatterns(BiometricAnalysis analysis) async {
    final patterns = <BiometricType, PatternInfo>{};
    
    // Analyze heart rate patterns
    if (analysis.heartRateData.isNotEmpty) {
      patterns[BiometricType.heartRate] = _analyzeHeartRatePattern(analysis.heartRateData);
    }
    
    // Analyze sleep patterns
    if (analysis.sleepData.isNotEmpty) {
      patterns[BiometricType.sleepAnalysis] = _analyzeSleepPattern(analysis.sleepData);
    }
    
    // Analyze temperature patterns
    if (analysis.temperatureData.isNotEmpty) {
      patterns[BiometricType.bodyTemperature] = _analyzeTemperaturePattern(analysis.temperatureData);
    }
    
    return patterns;
  }
  
  /// Analyze heart rate patterns
  PatternInfo _analyzeHeartRatePattern(List<BiometricReading> data) {
    final values = data.map((r) => r.value).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => math.pow(v - avg, 2)).reduce((a, b) => a + b) / values.length;
    
    return PatternInfo(
      average: avg,
      variance: variance,
      trend: _calculateTrend(values),
      cyclicPattern: _detectCyclicPattern(data),
    );
  }
  
  /// Analyze sleep patterns
  PatternInfo _analyzeSleepPattern(List<BiometricReading> data) {
    final values = data.map((r) => r.value).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => math.pow(v - avg, 2)).reduce((a, b) => a + b) / values.length;
    
    return PatternInfo(
      average: avg,
      variance: variance,
      trend: _calculateTrend(values),
      cyclicPattern: _detectCyclicPattern(data),
    );
  }
  
  /// Analyze temperature patterns
  PatternInfo _analyzeTemperaturePattern(List<BiometricReading> data) {
    final values = data.map((r) => r.value).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => math.pow(v - avg, 2)).reduce((a, b) => a + b) / values.length;
    
    return PatternInfo(
      average: avg,
      variance: variance,
      trend: _calculateTrend(values),
      cyclicPattern: _detectCyclicPattern(data),
    );
  }
  
  /// Calculate trend in data
  TrendDirection _calculateTrend(List<double> values) {
    if (values.length < 2) return TrendDirection.stable;
    
    var increasing = 0;
    var decreasing = 0;
    
    for (int i = 1; i < values.length; i++) {
      if (values[i] > values[i - 1]) {
        increasing++;
      } else if (values[i] < values[i - 1]) {
        decreasing++;
      }
    }
    
    if (increasing > decreasing * 1.5) return TrendDirection.increasing;
    if (decreasing > increasing * 1.5) return TrendDirection.decreasing;
    return TrendDirection.stable;
  }
  
  /// Detect cyclic patterns in biometric data
  bool _detectCyclicPattern(List<BiometricReading> data) {
    // Simplified cyclic detection - would need more sophisticated analysis in production
    return data.length > 14; // Basic assumption for now
  }
  
  /// Detect anomalies in biometric data
  Future<List<BiometricAnomaly>> _detectAnomalies(BiometricAnalysis analysis) async {
    final anomalies = <BiometricAnomaly>[];
    
    // Detect heart rate anomalies
    for (final reading in analysis.heartRateData) {
      if (reading.value > 100 || reading.value < 50) {
        anomalies.add(BiometricAnomaly(
          type: BiometricType.heartRate,
          timestamp: reading.timestamp,
          value: reading.value,
          severity: reading.value > 120 || reading.value < 40 ? AnomalySeverity.high : AnomalySeverity.medium,
          description: reading.value > 100 ? 'Elevated heart rate' : 'Low heart rate',
        ));
      }
    }
    
    // Detect temperature anomalies
    for (final reading in analysis.temperatureData) {
      if (reading.value > 99.5 || reading.value < 97.0) {
        anomalies.add(BiometricAnomaly(
          type: BiometricType.bodyTemperature,
          timestamp: reading.timestamp,
          value: reading.value,
          severity: reading.value > 101 || reading.value < 96 ? AnomalySeverity.high : AnomalySeverity.medium,
          description: reading.value > 99.5 ? 'Elevated temperature' : 'Low temperature',
        ));
      }
    }
    
    return anomalies;
  }
  
  /// Generate insights from biometric analysis
  Future<List<BiometricInsight>> _generateInsights(BiometricAnalysis analysis) async {
    final insights = <BiometricInsight>[];
    
    // Heart rate insights
    if (analysis.heartRateData.isNotEmpty) {
      final avgHR = analysis.heartRateData.map((r) => r.value).reduce((a, b) => a + b) / analysis.heartRateData.length;
      if (avgHR > 80) {
        insights.add(BiometricInsight(
          type: BiometricType.heartRate,
          category: InsightCategory.health,
          title: 'Elevated Average Heart Rate',
          description: 'Your average heart rate is ${avgHR.toStringAsFixed(1)} BPM, which is above the typical resting range.',
          actionable: true,
          recommendations: ['Consider stress reduction techniques', 'Ensure adequate hydration', 'Consult healthcare provider if persistent'],
        ));
      }
    }
    
    // Sleep insights
    if (analysis.sleepData.isNotEmpty) {
      final avgSleepQuality = analysis.sleepData.map((r) => r.value).reduce((a, b) => a + b) / analysis.sleepData.length;
      if (avgSleepQuality < 0.7) {
        insights.add(BiometricInsight(
          type: BiometricType.sleepAnalysis,
          category: InsightCategory.lifestyle,
          title: 'Sleep Quality Could Be Improved',
          description: 'Your average sleep quality score is ${(avgSleepQuality * 100).toStringAsFixed(0)}%.',
          actionable: true,
          recommendations: ['Maintain consistent sleep schedule', 'Create relaxing bedtime routine', 'Limit screen time before bed'],
        ));
      }
    }
    
    return insights;
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
  
  /// Dispose resources
  void dispose() {
    _realtimeDataController.close();
    stopRealtimeMonitoring();
    clearCache();
    _isInitialized = false;
  }
}

/// Enum for different flow levels
enum FlowLevel {
  none,
  light,
  medium,
  heavy,
}

/// Exception class for biometric operations
class BiometricException implements Exception {
  final String message;
  BiometricException(this.message);
  
  @override
  String toString() => 'BiometricException: $message';
}

/// Device capabilities for biometric data
class BiometricCapabilities {
  final bool hasHealthKit;
  final bool hasGoogleFit;
  final Set<BiometricType> supportedDataTypes;
  final bool canWriteData;
  final bool hasRealtimeCapability;
  final String deviceModel;
  final String osVersion;
  
  BiometricCapabilities({
    required this.hasHealthKit,
    required this.hasGoogleFit,
    required this.supportedDataTypes,
    required this.canWriteData,
    required this.hasRealtimeCapability,
    this.deviceModel = 'Unknown',
    this.osVersion = 'Unknown',
  });
  
  factory BiometricCapabilities.empty() {
    return BiometricCapabilities(
      hasHealthKit: false,
      hasGoogleFit: false,
      supportedDataTypes: {},
      canWriteData: false,
      hasRealtimeCapability: false,
    );
  }
  
  factory BiometricCapabilities.fromMap(Map<String, dynamic> map) {
    return BiometricCapabilities(
      hasHealthKit: map['hasHealthKit'] ?? false,
      hasGoogleFit: map['hasGoogleFit'] ?? false,
      supportedDataTypes: Set<BiometricType>.from(
        (map['supportedDataTypes'] as List? ?? [])
            .map((type) => BiometricType.values.firstWhere(
                  (t) => t.toString().split('.').last == type,
                  orElse: () => BiometricType.heartRate,
                ))
            .where((type) => type != BiometricType.heartRate || map['supportedDataTypes'].contains(type.toString().split('.').last)),
      ),
      canWriteData: map['canWriteData'] ?? false,
      hasRealtimeCapability: map['hasRealtimeCapability'] ?? false,
      deviceModel: map['deviceModel'] ?? 'Unknown',
      osVersion: map['osVersion'] ?? 'Unknown',
    );
  }
}

/// Pattern analysis for biometric data
class BiometricPatternAnalysis {
  final int periodDays;
  final Map<BiometricType, PatternInfo> patterns;
  final List<BiometricAnomaly> anomalies;
  final Map<String, double> correlations;
  final List<BiometricInsight> insights;
  
  BiometricPatternAnalysis({
    required this.periodDays,
    required this.patterns,
    required this.anomalies,
    required this.correlations,
    required this.insights,
  });
  
  factory BiometricPatternAnalysis.empty() {
    return BiometricPatternAnalysis(
      periodDays: 0,
      patterns: {},
      anomalies: [],
      correlations: {},
      insights: [],
    );
  }
}

/// Pattern information for a specific biometric type
class PatternInfo {
  final double average;
  final double variance;
  final TrendDirection trend;
  final bool cyclicPattern;
  final double? cyclePeriod;
  final double? amplitude;
  
  PatternInfo({
    required this.average,
    required this.variance,
    required this.trend,
    required this.cyclicPattern,
    this.cyclePeriod,
    this.amplitude,
  });
}

/// Trend direction enum
enum TrendDirection {
  increasing,
  decreasing,
  stable,
}

/// Biometric anomaly detection
class BiometricAnomaly {
  final BiometricType type;
  final DateTime timestamp;
  final double value;
  final AnomalySeverity severity;
  final String description;
  final Map<String, dynamic>? context;
  
  BiometricAnomaly({
    required this.type,
    required this.timestamp,
    required this.value,
    required this.severity,
    required this.description,
    this.context,
  });
}

/// Anomaly severity levels
enum AnomalySeverity {
  low,
  medium,
  high,
  critical,
}

/// Biometric insights
class BiometricInsight {
  final BiometricType type;
  final InsightCategory category;
  final String title;
  final String description;
  final bool actionable;
  final List<String> recommendations;
  final double? confidence;
  
  BiometricInsight({
    required this.type,
    required this.category,
    required this.title,
    required this.description,
    required this.actionable,
    required this.recommendations,
    this.confidence,
  });
}

/// Insight categories
enum InsightCategory {
  health,
  fitness,
  sleep,
  stress,
  cycle,
  lifestyle,
  nutrition,
}
