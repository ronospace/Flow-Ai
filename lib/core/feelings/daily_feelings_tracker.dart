import 'dart:async';
import 'dart:math' as math;
import '../database/database_service.dart';
import '../utils/app_logger.dart';
import '../security/security_manager.dart';

/// 💖 Daily Feelings Tracker
/// Smart daily feelings tracking system for both Flow AI (consumer) and Flow Ai (clinical)
/// Tracks user feelings twice daily on 1-10 scale with performance analytics
class DailyFeelingsTracker {
  static final DailyFeelingsTracker _instance = DailyFeelingsTracker._internal();
  static DailyFeelingsTracker get instance => _instance;
  DailyFeelingsTracker._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Tracking configuration
  static const int _morningHour = 9; // 9 AM
  static const int _eveningHour = 21; // 9 PM
  static const Duration _trackingWindow = Duration(hours: 3);
  
  // Data storage
  final List<FeelingsEntry> _feelingsHistory = [];
  Timer? _reminderTimer;
  
  // Analytics engine
  late FeelingsAnalytics _analytics;
  
  // Notification callbacks
  final List<Function(FeelingsReminder)> _reminderCallbacks = [];

  /// Initialize the feelings tracking system
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.success('💖 Initializing Daily Feelings Tracker...');

      // Initialize analytics engine
      _analytics = FeelingsAnalytics();
      await _analytics.initialize();

      // Load historical feelings data
      await _loadFeelingsHistory();

      // Setup reminder system
      _setupReminderSystem();

      // Schedule daily reminders
      _scheduleDailyReminders();

      _isInitialized = true;
      AppLogger.success('✅ Daily Feelings Tracker initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize Daily Feelings Tracker: $e');
      rethrow;
    }
  }

  /// Record a feelings entry
  Future<bool> recordFeelingsEntry({
    required String userId,
    required int feelingScore,
    required FeelingsTimeOfDay timeOfDay,
    String? notes,
    Map<String, dynamic>? contextData,
    bool isConsumerApp = true,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Validate feeling score
      if (feelingScore < 1 || feelingScore > 10) {
        throw ArgumentError('Feeling score must be between 1 and 10');
      }

      // Create feelings entry
      final entry = FeelingsEntry(
        id: _generateEntryId(),
        userId: userId,
        feelingScore: feelingScore,
        timeOfDay: timeOfDay,
        timestamp: DateTime.now(),
        notes: notes,
        contextData: contextData ?? {},
        appType: isConsumerApp ? AppType.consumer : AppType.clinical,
      );

      // Encrypt sensitive data if needed
      if (notes != null && notes.isNotEmpty) {
        final securityManager = SecurityManager.instance;
        entry.encryptedNotes = await securityManager.encryptHealthData(notes);
      }

      // Store entry
      await _storeFeelingsEntry(entry);
      
      // Add to local cache
      _feelingsHistory.add(entry);
      
      // Sort by timestamp (newest first)
      _feelingsHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Keep only last 365 days
      _maintainHistorySize();

      // Update analytics
      await _analytics.processNewEntry(entry);

      AppLogger.success('💖 Feelings entry recorded: ${entry.feelingScore}/10 (${timeOfDay.name})');
      
      return true;
    } catch (e) {
      AppLogger.error('Failed to record feelings entry: $e');
      return false;
    }
  }

  /// Get today's feelings entries
  List<FeelingsEntry> getTodaysFeelings({String? userId}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _feelingsHistory.where((entry) {
      if (userId != null && entry.userId != userId) return false;
      return entry.timestamp.isAfter(today) && entry.timestamp.isBefore(tomorrow);
    }).toList();
  }

  /// Check if user can record feelings now
  FeelingsTrackingStatus getTrackingStatus({String? userId}) {
    final now = DateTime.now();
    final todaysFeelings = getTodaysFeelings(userId: userId);
    
    // Check for morning entry
    final hasMorningEntry = todaysFeelings.any(
      (entry) => entry.timeOfDay == FeelingsTimeOfDay.morning
    );
    
    // Check for evening entry
    final hasEveningEntry = todaysFeelings.any(
      (entry) => entry.timeOfDay == FeelingsTimeOfDay.evening
    );

    // Determine current time period
    final currentHour = now.hour;
    FeelingsTimeOfDay? currentPeriod;
    
    if (currentHour >= _morningHour - 2 && currentHour <= _morningHour + 2) {
      currentPeriod = FeelingsTimeOfDay.morning;
    } else if (currentHour >= _eveningHour - 2 && currentHour <= _eveningHour + 2) {
      currentPeriod = FeelingsTimeOfDay.evening;
    }

    return FeelingsTrackingStatus(
      canRecordMorning: !hasMorningEntry && currentPeriod == FeelingsTimeOfDay.morning,
      canRecordEvening: !hasEveningEntry && currentPeriod == FeelingsTimeOfDay.evening,
      hasMorningEntry: hasMorningEntry,
      hasEveningEntry: hasEveningEntry,
      currentPeriod: currentPeriod,
      nextReminderTime: _calculateNextReminderTime(hasMorningEntry, hasEveningEntry),
    );
  }

  /// Get feelings analytics for a user
  Future<FeelingsAnalyticsReport> getAnalyticsReport({
    required String userId,
    int daysBack = 30,
    bool isConsumerApp = true,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: daysBack));
    
    final entries = _feelingsHistory.where((entry) {
      return entry.userId == userId &&
             entry.timestamp.isAfter(startDate) &&
             entry.timestamp.isBefore(endDate) &&
             entry.appType == (isConsumerApp ? AppType.consumer : AppType.clinical);
    }).toList();

    return await _analytics.generateReport(entries, daysBack, isConsumerApp);
  }

  /// Get feelings trends over time
  List<FeelingsDataPoint> getFeelingsPattern({
    required String userId,
    int daysBack = 14,
    bool isConsumerApp = true,
  }) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: daysBack));
    
    final entries = _feelingsHistory.where((entry) {
      return entry.userId == userId &&
             entry.timestamp.isAfter(startDate) &&
             entry.timestamp.isBefore(endDate) &&
             entry.appType == (isConsumerApp ? AppType.consumer : AppType.clinical);
    }).toList();

    // Group by date and calculate daily averages
    final Map<String, List<int>> dailyScores = {};
    
    for (final entry in entries) {
      final dateKey = '${entry.timestamp.year}-${entry.timestamp.month}-${entry.timestamp.day}';
      dailyScores[dateKey] ??= [];
      dailyScores[dateKey]!.add(entry.feelingScore);
    }

    // Convert to data points
    final dataPoints = <FeelingsDataPoint>[];
    
    for (final entry in dailyScores.entries) {
      final date = DateTime.parse(entry.key.replaceAll('-', '-'));
      final scores = entry.value;
      final averageScore = scores.reduce((a, b) => a + b) / scores.length;
      
      dataPoints.add(FeelingsDataPoint(
        date: date,
        score: averageScore,
        entryCount: scores.length,
      ));
    }

    // Sort by date
    dataPoints.sort((a, b) => a.date.compareTo(b.date));
    
    return dataPoints;
  }

  /// Register for reminder notifications
  void registerReminderCallback(Function(FeelingsReminder) callback) {
    _reminderCallbacks.add(callback);
  }

  /// Unregister reminder callback
  void unregisterReminderCallback(Function(FeelingsReminder) callback) {
    _reminderCallbacks.remove(callback);
  }

  /// Setup reminder system
  void _setupReminderSystem() {
    // Setup periodic check for reminders (every 30 minutes)
    _reminderTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _checkAndSendReminders();
    });
  }

  /// Schedule daily reminders
  void _scheduleDailyReminders() {
    final now = DateTime.now();
    
    // Schedule morning reminder
    final morningTime = DateTime(now.year, now.month, now.day, _morningHour, 0);
    final morningDelay = morningTime.isAfter(now) 
        ? morningTime.difference(now)
        : morningTime.add(const Duration(days: 1)).difference(now);
    
    Timer(morningDelay, () {
      _sendReminder(FeelingsTimeOfDay.morning);
    });

    // Schedule evening reminder
    final eveningTime = DateTime(now.year, now.month, now.day, _eveningHour, 0);
    final eveningDelay = eveningTime.isAfter(now)
        ? eveningTime.difference(now)
        : eveningTime.add(const Duration(days: 1)).difference(now);
    
    Timer(eveningDelay, () {
      _sendReminder(FeelingsTimeOfDay.evening);
    });
  }

  /// Check and send reminders
  void _checkAndSendReminders() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Check for morning reminder window
    if (hour >= _morningHour && hour <= _morningHour + 2) {
      final status = getTrackingStatus();
      if (status.canRecordMorning) {
        _sendReminder(FeelingsTimeOfDay.morning);
      }
    }
    
    // Check for evening reminder window
    if (hour >= _eveningHour && hour <= _eveningHour + 2) {
      final status = getTrackingStatus();
      if (status.canRecordEvening) {
        _sendReminder(FeelingsTimeOfDay.evening);
      }
    }
  }

  /// Send reminder to registered callbacks
  void _sendReminder(FeelingsTimeOfDay timeOfDay) {
    final reminder = FeelingsReminder(
      timeOfDay: timeOfDay,
      timestamp: DateTime.now(),
      message: _getReminderMessage(timeOfDay),
    );

    for (final callback in _reminderCallbacks) {
      try {
        callback(reminder);
      } catch (e) {
        AppLogger.warning('Failed to send feelings reminder: $e');
      }
    }
  }

  /// Get reminder message based on time of day
  String _getReminderMessage(FeelingsTimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case FeelingsTimeOfDay.morning:
        return "Good morning! How are you feeling today? Rate your mood from 1-10 💖";
      case FeelingsTimeOfDay.evening:
        return "How was your day? Take a moment to reflect and rate how you're feeling 🌙";
    }
  }

  /// Calculate next reminder time
  DateTime? _calculateNextReminderTime(bool hasMorning, bool hasEvening) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // If morning entry missing and we're before evening time
    if (!hasMorning && now.hour < _eveningHour) {
      return today.add(Duration(hours: _morningHour));
    }
    
    // If evening entry missing and we're in evening window
    if (!hasEvening && now.hour < _eveningHour + 3) {
      return today.add(Duration(hours: _eveningHour));
    }
    
    // Next morning
    return today.add(const Duration(days: 1, hours: _morningHour));
  }

  /// Load feelings history from storage
  Future<void> _loadFeelingsHistory() async {
    try {
      final entries = await DatabaseService.instance.getFeelingsHistory();
      _feelingsHistory.clear();
      _feelingsHistory.addAll(entries.cast<FeelingsEntry>());
      
      // Sort by timestamp (newest first)
      _feelingsHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      AppLogger.success('📊 Loaded ${_feelingsHistory.length} feelings entries');
    } catch (e) {
      AppLogger.warning('Failed to load feelings history: $e');
    }
  }

  /// Store feelings entry to database
  Future<void> _storeFeelingsEntry(FeelingsEntry entry) async {
    try {
      await DatabaseService.instance.storeFeelingsEntry(entry);
    } catch (e) {
      AppLogger.error('Failed to store feelings entry: $e');
      rethrow;
    }
  }

  /// Maintain history size (keep last 365 days)
  void _maintainHistorySize() {
    const maxDays = 365;
    final cutoffDate = DateTime.now().subtract(const Duration(days: maxDays));
    
    _feelingsHistory.removeWhere((entry) => entry.timestamp.isBefore(cutoffDate));
  }

  /// Generate unique entry ID
  String _generateEntryId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = math.Random().nextInt(10000);
    return 'feelings_${timestamp}_$random';
  }

  /// Get historical feelings for export
  List<FeelingsEntry> getHistoricalFeelings({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    bool isConsumerApp = true,
  }) {
    return _feelingsHistory.where((entry) {
      if (userId != null && entry.userId != userId) return false;
      if (startDate != null && entry.timestamp.isBefore(startDate)) return false;
      if (endDate != null && entry.timestamp.isAfter(endDate)) return false;
      if (entry.appType != (isConsumerApp ? AppType.consumer : AppType.clinical)) return false;
      return true;
    }).toList();
  }

  /// Dispose resources
  void dispose() {
    _reminderTimer?.cancel();
    _reminderCallbacks.clear();
  }
}

/// Feelings Analytics Engine
class FeelingsAnalytics {
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    AppLogger.success('📊 Feelings Analytics Engine initialized');
  }

  /// Process new entry for real-time analytics
  Future<void> processNewEntry(FeelingsEntry entry) async {
    // Update running analytics
    // This could trigger insights or alerts
    AppLogger.analytics('📊 Processing feelings entry: ${entry.feelingScore}/10');
  }

  /// Generate comprehensive analytics report
  Future<FeelingsAnalyticsReport> generateReport(
    List<FeelingsEntry> entries,
    int daysBack,
    bool isConsumerApp,
  ) async {
    if (entries.isEmpty) {
      return FeelingsAnalyticsReport.empty();
    }

    // Calculate basic metrics
    final scores = entries.map((e) => e.feelingScore).toList();
    final averageScore = scores.reduce((a, b) => a + b) / scores.length;
    final highestScore = scores.reduce(math.max);
    final lowestScore = scores.reduce(math.min);

    // Calculate trends
    final trend = _calculateTrend(entries);
    
    // Generate insights
    final insights = _generateInsights(entries, averageScore, trend, isConsumerApp);
    
    // Calculate completion rate
    final expectedEntries = daysBack * 2; // Twice daily
    final completionRate = entries.length / expectedEntries;

    return FeelingsAnalyticsReport(
      averageScore: averageScore,
      highestScore: highestScore,
      lowestScore: lowestScore,
      totalEntries: entries.length,
      completionRate: completionRate,
      trend: trend,
      insights: insights,
      periodDays: daysBack,
      lastUpdated: DateTime.now(),
    );
  }

  /// Calculate trend direction
  FeelingsTrend _calculateTrend(List<FeelingsEntry> entries) {
    if (entries.length < 4) return FeelingsTrend.stable;

    final sortedEntries = entries.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final firstHalf = sortedEntries.take(entries.length ~/ 2);
    final secondHalf = sortedEntries.skip(entries.length ~/ 2);

    final firstAvg = firstHalf.map((e) => e.feelingScore).reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.map((e) => e.feelingScore).reduce((a, b) => a + b) / secondHalf.length;

    const trendThreshold = 0.5;

    if (secondAvg - firstAvg > trendThreshold) {
      return FeelingsTrend.improving;
    } else if (firstAvg - secondAvg > trendThreshold) {
      return FeelingsTrend.declining;
    } else {
      return FeelingsTrend.stable;
    }
  }

  /// Generate insights based on data
  List<String> _generateInsights(
    List<FeelingsEntry> entries,
    double averageScore,
    FeelingsTrend trend,
    bool isConsumerApp,
  ) {
    final insights = <String>[];

    // Average score insights
    if (averageScore >= 8) {
      insights.add(isConsumerApp 
          ? "You're maintaining excellent emotional wellness! Keep up the great work 🌟"
          : "Patient shows consistently high mood scores indicating good emotional stability");
    } else if (averageScore >= 6) {
      insights.add(isConsumerApp 
          ? "Your overall mood is positive with room for growth 💪"
          : "Patient demonstrates moderate emotional stability with potential for improvement");
    } else if (averageScore >= 4) {
      insights.add(isConsumerApp 
          ? "Consider focusing on self-care activities to boost your mood 💖"
          : "Patient shows moderate mood concerns that may benefit from intervention");
    } else {
      insights.add(isConsumerApp 
          ? "Your mood patterns suggest you might benefit from additional support 🤗"
          : "Patient demonstrates concerning mood patterns requiring clinical attention");
    }

    // Trend insights
    switch (trend) {
      case FeelingsTrend.improving:
        insights.add(isConsumerApp 
            ? "Great progress! Your mood has been steadily improving 📈"
            : "Positive trend indicates improving emotional state over time");
        break;
      case FeelingsTrend.declining:
        insights.add(isConsumerApp 
            ? "Let's focus on activities that help you feel better 💝"
            : "Declining trend warrants attention and possible intervention");
        break;
      case FeelingsTrend.stable:
        insights.add(isConsumerApp 
            ? "Your mood has been consistent - that's a sign of emotional stability!"
            : "Stable mood patterns indicate consistent emotional state");
        break;
    }

    // Completion insights
    final completionRate = entries.length / 60.0; // 30 days * 2 entries
    if (completionRate >= 0.8) {
      insights.add(isConsumerApp 
          ? "Excellent tracking consistency! This data will help you understand your patterns better"
          : "High compliance with mood tracking indicates good patient engagement");
    } else if (completionRate < 0.5) {
      insights.add(isConsumerApp 
          ? "Try setting reminders to track your mood more consistently for better insights"
          : "Low tracking compliance may limit effectiveness of mood monitoring");
    }

    return insights;
  }
}

// Data Models

/// Feelings entry data model
class FeelingsEntry {
  final String id;
  final String userId;
  final int feelingScore; // 1-10 scale
  final FeelingsTimeOfDay timeOfDay;
  final DateTime timestamp;
  final String? notes;
  String? encryptedNotes;
  final Map<String, dynamic> contextData;
  final AppType appType;

  FeelingsEntry({
    required this.id,
    required this.userId,
    required this.feelingScore,
    required this.timeOfDay,
    required this.timestamp,
    this.notes,
    this.encryptedNotes,
    required this.contextData,
    required this.appType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'feeling_score': feelingScore,
      'time_of_day': timeOfDay.name,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'encrypted_notes': encryptedNotes,
      'context_data': contextData,
      'app_type': appType.name,
    };
  }

  static FeelingsEntry fromJson(Map<String, dynamic> json) {
    return FeelingsEntry(
      id: json['id'],
      userId: json['user_id'],
      feelingScore: json['feeling_score'],
      timeOfDay: FeelingsTimeOfDay.values.firstWhere(
        (e) => e.name == json['time_of_day'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
      encryptedNotes: json['encrypted_notes'],
      contextData: Map<String, dynamic>.from(json['context_data'] ?? {}),
      appType: AppType.values.firstWhere(
        (e) => e.name == json['app_type'],
      ),
    );
  }
}

/// Analytics report model
class FeelingsAnalyticsReport {
  final double averageScore;
  final int highestScore;
  final int lowestScore;
  final int totalEntries;
  final double completionRate;
  final FeelingsTrend trend;
  final List<String> insights;
  final int periodDays;
  final DateTime lastUpdated;

  FeelingsAnalyticsReport({
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    required this.totalEntries,
    required this.completionRate,
    required this.trend,
    required this.insights,
    required this.periodDays,
    required this.lastUpdated,
  });

  static FeelingsAnalyticsReport empty() {
    return FeelingsAnalyticsReport(
      averageScore: 0.0,
      highestScore: 0,
      lowestScore: 0,
      totalEntries: 0,
      completionRate: 0.0,
      trend: FeelingsTrend.stable,
      insights: ['No feelings data available yet. Start tracking to see insights!'],
      periodDays: 0,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Tracking status model
class FeelingsTrackingStatus {
  final bool canRecordMorning;
  final bool canRecordEvening;
  final bool hasMorningEntry;
  final bool hasEveningEntry;
  final FeelingsTimeOfDay? currentPeriod;
  final DateTime? nextReminderTime;

  FeelingsTrackingStatus({
    required this.canRecordMorning,
    required this.canRecordEvening,
    required this.hasMorningEntry,
    required this.hasEveningEntry,
    this.currentPeriod,
    this.nextReminderTime,
  });

  bool get isComplete => hasMorningEntry && hasEveningEntry;
  bool get canRecord => canRecordMorning || canRecordEvening;
}

/// Data point for trend visualization
class FeelingsDataPoint {
  final DateTime date;
  final double score;
  final int entryCount;

  FeelingsDataPoint({
    required this.date,
    required this.score,
    required this.entryCount,
  });
}

/// Reminder notification model
class FeelingsReminder {
  final FeelingsTimeOfDay timeOfDay;
  final DateTime timestamp;
  final String message;

  FeelingsReminder({
    required this.timeOfDay,
    required this.timestamp,
    required this.message,
  });
}

// Enums

enum FeelingsTimeOfDay {
  morning,
  evening,
}

enum FeelingsTrend {
  improving,
  stable,
  declining,
}

enum AppType {
  consumer,  // Flow AI
  clinical,  // Flow Ai
}
