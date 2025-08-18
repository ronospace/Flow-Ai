import 'package:flutter/foundation.dart';
import '../../../core/services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();
  
  // State
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Analytics data
  CycleAnalytics? _cycleAnalytics;
  HealthAnalytics? _healthAnalytics;
  PredictionAnalytics? _predictionAnalytics;
  TrendAnalytics? _trendAnalytics;
  List<PersonalizedRecommendation> _recommendations = [];
  
  // Getters
  bool get isLoading => _isLoading;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  CycleAnalytics? get cycleAnalytics => _cycleAnalytics;
  HealthAnalytics? get healthAnalytics => _healthAnalytics;
  PredictionAnalytics? get predictionAnalytics => _predictionAnalytics;
  TrendAnalytics? get trendAnalytics => _trendAnalytics;
  List<PersonalizedRecommendation> get recommendations => _recommendations;
  
  // Load all analytics data
  Future<void> loadAllAnalytics() async {
    _setLoading(true);
    try {
      await Future.wait([
        loadCycleAnalytics(),
        loadHealthAnalytics(),
        loadPredictionAnalytics(),
        loadTrendAnalytics(),
        loadRecommendations(),
      ]);
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load cycle analytics
  Future<void> loadCycleAnalytics() async {
    try {
      _cycleAnalytics = await _analyticsService.getCycleAnalytics(
        startDate: _startDate,
        endDate: _endDate,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cycle analytics: $e');
    }
  }
  
  // Load health analytics
  Future<void> loadHealthAnalytics() async {
    try {
      _healthAnalytics = await _analyticsService.getHealthAnalytics(
        startDate: _startDate,
        endDate: _endDate,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading health analytics: $e');
    }
  }
  
  // Load prediction analytics
  Future<void> loadPredictionAnalytics() async {
    try {
      _predictionAnalytics = await _analyticsService.getPredictionAnalytics();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading prediction analytics: $e');
    }
  }
  
  // Load trend analytics
  Future<void> loadTrendAnalytics() async {
    try {
      _trendAnalytics = await _analyticsService.getTrendAnalytics(
        startDate: _startDate,
        endDate: _endDate,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading trend analytics: $e');
    }
  }
  
  // Load personalized recommendations
  Future<void> loadRecommendations() async {
    try {
      _recommendations = await _analyticsService.getPersonalizedRecommendations();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
    }
  }
  
  // Set time range for analytics
  void setTimeRange(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    loadAllAnalytics();
  }
  
  // Refresh analytics data
  Future<void> refresh() async {
    await loadAllAnalytics();
  }
  
  // Clear analytics data
  void clearData() {
    _cycleAnalytics = null;
    _healthAnalytics = null;
    _predictionAnalytics = null;
    _trendAnalytics = null;
    _recommendations = [];
    notifyListeners();
  }
  
  // Get analytics summary
  Map<String, dynamic> getAnalyticsSummary() {
    return {
      'cycleRegularity': _cycleAnalytics?.regularityScore ?? 0.0,
      'healthScore': _healthAnalytics?.overallHealthScore ?? 0.0,
      'predictionAccuracy': _predictionAnalytics?.confidenceScore ?? 0.0,
      'totalCycles': _cycleAnalytics?.totalCycles ?? 0,
      'recommendationsCount': _recommendations.length,
      'lastUpdated': DateTime.now(),
    };
  }
  
  // Get trend direction for specific metric
  TrendDirection? getTrendDirection(String metric) {
    final trends = _trendAnalytics?.trends;
    if (trends == null) return null;
    return trends[metric]?.direction;
  }
  
  // Check if analytics data is available
  bool get hasData {
    return _cycleAnalytics != null || 
           _healthAnalytics != null || 
           _predictionAnalytics != null || 
           _trendAnalytics != null;
  }
  
  // Get insights count
  int get insightsCount {
    int count = 0;
    if (_cycleAnalytics != null) count++;
    if (_healthAnalytics != null) count++;
    if (_predictionAnalytics != null) count++;
    if (_trendAnalytics != null) count++;
    return count;
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
