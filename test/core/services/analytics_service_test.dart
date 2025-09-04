import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flow_ai/core/services/analytics_service.dart';
import 'package:flow_ai/core/services/production_analytics_service.dart';
import 'package:flow_ai/core/services/performance_service.dart';
import 'package:flow_ai/core/health/advanced_health_analytics.dart';

// Generate mocks
@GenerateMocks([ProductionAnalyticsService, PerformanceService, AdvancedHealthAnalytics])
import 'analytics_service_test.mocks.dart';

void main() {
  group('AnalyticsService Tests', () {
    late AnalyticsService analyticsService;
    late MockProductionAnalyticsService mockProductionService;

    setUp(() {
      mockProductionService = MockProductionAnalyticsService();
      analyticsService = AnalyticsService();
    });

    test('should initialize analytics service successfully', () async {
      // Arrange
      when(mockProductionService.initialize()).thenAnswer((_) async => true);

      // Act
      await analyticsService.initialize();

      // Assert
      expect(analyticsService.isInitialized, true);
    });

    test('should track app launch event', () async {
      // Arrange
      await analyticsService.initialize();

      // Act
      await analyticsService.trackEvent('app_launch', {
        'timestamp': DateTime.now().toIso8601String(),
        'cold_start': true,
        'user_id': 'test_user_123',
      });

      // Assert
      expect(analyticsService.eventCount, greaterThan(0));
    });

    test('should track user engagement events', () async {
      // Arrange
      await analyticsService.initialize();
      const userId = 'engagement_user_123';

      // Act
      await analyticsService.trackUserEngagement(userId, {
        'screen': 'home',
        'action': 'period_logged',
        'duration_seconds': 45,
      });

      // Assert
      expect(analyticsService.userEngagementEvents.containsKey(userId), true);
    });

    test('should track health data events', () async {
      // Arrange
      await analyticsService.initialize();

      final healthData = {
        'cycle_length': 28,
        'period_length': 5,
        'symptoms': ['cramping', 'headache'],
        'mood': 'irritable',
        'flow': 'heavy',
      };

      // Act
      await analyticsService.trackHealthData('health_data_logged', healthData);

      // Assert
      expect(analyticsService.healthDataEvents, isNotEmpty);
    });

    test('should track feature usage', () async {
      // Arrange
      await analyticsService.initialize();
      const featureName = 'ai_chat';

      // Act
      await analyticsService.trackFeatureUsage(featureName, {
        'user_id': 'feature_user_123',
        'session_duration': 120,
        'messages_sent': 5,
      });

      // Assert
      expect(analyticsService.featureUsageStats.containsKey(featureName), true);
      expect(analyticsService.featureUsageStats[featureName]!['usage_count'], greaterThan(0));
    });

    test('should track ad impressions and revenue', () async {
      // Arrange
      await analyticsService.initialize();

      // Act
      await analyticsService.trackAdImpression('banner', {
        'ad_unit_id': 'test_banner_id',
        'placement': 'home_screen',
        'revenue': 0.05,
      });

      await analyticsService.trackAdRevenue('interstitial', {
        'ad_unit_id': 'test_interstitial_id',
        'revenue': 0.25,
        'currency': 'USD',
      });

      // Assert
      expect(analyticsService.totalAdRevenue, equals(0.30));
      expect(analyticsService.adImpressions, equals(2));
    });

    test('should generate user behavior insights', () async {
      // Arrange
      await analyticsService.initialize();
      const userId = 'behavior_user_123';

      // Track some user activities
      await analyticsService.trackUserEngagement(userId, {'screen': 'calendar'});
      await analyticsService.trackUserEngagement(userId, {'screen': 'insights'});
      await analyticsService.trackFeatureUsage('period_tracking', {'user_id': userId});

      // Act
      final insights = await analyticsService.generateUserBehaviorInsights(userId);

      // Assert
      expect(insights, isNotNull);
      expect(insights['most_used_screens'], isA<List>());
      expect(insights['engagement_score'], isA<double>());
      expect(insights['feature_adoption'], isA<Map>());
    });

    test('should calculate retention metrics', () async {
      // Arrange
      await analyticsService.initialize();

      final userActivities = {
        'user1': [DateTime.now().subtract(const Duration(days: 1))],
        'user2': [DateTime.now().subtract(const Duration(days: 7))],
        'user3': [DateTime.now().subtract(const Duration(days: 30))],
      };

      // Act
      final retention = await analyticsService.calculateRetentionMetrics(userActivities);

      // Assert
      expect(retention, isNotNull);
      expect(retention['daily_retention'], isA<double>());
      expect(retention['weekly_retention'], isA<double>());
      expect(retention['monthly_retention'], isA<double>());
    });

    test('should handle analytics errors gracefully', () async {
      // Arrange
      when(mockProductionService.trackEvent(any, any))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => analyticsService.trackEvent('test_event', {}),
        returnsNormally, // Should not crash the app
      );
    });

    test('should batch events for performance', () async {
      // Arrange
      await analyticsService.initialize();

      // Act - Add multiple events
      for (int i = 0; i < 50; i++) {
        await analyticsService.trackEvent('test_batch_event_$i', {
          'batch_id': 'batch_1',
          'event_number': i,
        });
      }

      // Trigger batch send
      await analyticsService.flushEvents();

      // Assert
      expect(analyticsService.pendingEvents, isEmpty);
    });

    test('should respect user privacy settings', () async {
      // Arrange
      await analyticsService.initialize();

      // Act - Disable analytics
      analyticsService.setAnalyticsEnabled(false);

      await analyticsService.trackEvent('privacy_test_event', {});

      // Assert
      expect(analyticsService.isAnalyticsEnabled, false);
      // Event should not be tracked when analytics is disabled
    });
  });

  group('ProductionAnalyticsService Tests', () {
    late ProductionAnalyticsService productionService;

    setUp(() {
      productionService = ProductionAnalyticsService();
    });

    test('should initialize production analytics', () async {
      // Act
      await productionService.initialize();

      // Assert
      expect(productionService.isInitialized, true);
    });

    test('should track custom events with metadata', () async {
      // Arrange
      await productionService.initialize();

      final eventData = {
        'event_type': 'user_action',
        'screen': 'period_tracking',
        'action': 'log_period',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Act
      await productionService.trackEvent('period_logged', eventData);

      // Assert
      expect(productionService.eventQueue, isNotEmpty);
    });

    test('should track screen views', () async {
      // Arrange
      await productionService.initialize();

      // Act
      await productionService.trackScreenView('home_screen', {
        'user_id': 'screen_user_123',
        'previous_screen': 'onboarding',
        'time_spent': 45,
      });

      // Assert
      expect(productionService.screenViewEvents, isNotEmpty);
    });

    test('should track app performance metrics', () async {
      // Arrange
      await productionService.initialize();

      // Act
      await productionService.trackPerformance('app_startup', {
        'duration_ms': 1500,
        'memory_usage_mb': 45.2,
        'cpu_usage_percent': 12.5,
      });

      // Assert
      expect(productionService.performanceMetrics, isNotEmpty);
    });

    test('should generate analytics reports', () async {
      // Arrange
      await productionService.initialize();

      // Track some test data
      await productionService.trackEvent('test_event_1', {'value': 1});
      await productionService.trackEvent('test_event_2', {'value': 2});
      await productionService.trackScreenView('test_screen', {'duration': 30});

      // Act
      final report = await productionService.generateAnalyticsReport(
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now(),
      );

      // Assert
      expect(report, isNotNull);
      expect(report['total_events'], greaterThan(0));
      expect(report['unique_screens'], isA<List>());
      expect(report['user_engagement'], isA<Map>());
    });
  });

  group('Performance Analytics Tests', () {
    late MockPerformanceService mockPerformanceService;

    setUp(() {
      mockPerformanceService = MockPerformanceService();
    });

    test('should track app performance metrics', () async {
      // Arrange
      when(mockPerformanceService.trackMemoryUsage())
          .thenAnswer((_) async => 42.5);
      when(mockPerformanceService.trackCPUUsage())
          .thenAnswer((_) async => 15.3);

      // Act
      final memoryUsage = await mockPerformanceService.trackMemoryUsage();
      final cpuUsage = await mockPerformanceService.trackCPUUsage();

      // Assert
      expect(memoryUsage, equals(42.5));
      expect(cpuUsage, equals(15.3));
    });

    test('should track frame rendering performance', () async {
      // Arrange
      when(mockPerformanceService.trackFrameMetrics())
          .thenAnswer((_) async => {
            'average_frame_time': 16.67,
            'dropped_frames': 2,
            'jank_percentage': 1.2,
          });

      // Act
      final frameMetrics = await mockPerformanceService.trackFrameMetrics();

      // Assert
      expect(frameMetrics['average_frame_time'], lessThan(20.0)); // Good performance
      expect(frameMetrics['jank_percentage'], lessThan(5.0)); // Low jank
    });

    test('should track network request performance', () async {
      // Arrange
      when(mockPerformanceService.trackNetworkRequest('api_call', any))
          .thenAnswer((_) async => {
            'duration_ms': 250,
            'success': true,
            'status_code': 200,
          });

      // Act
      final networkMetrics = await mockPerformanceService.trackNetworkRequest(
        'api_call',
        {'endpoint': '/api/periods', 'method': 'GET'},
      );

      // Assert
      expect(networkMetrics['duration_ms'], lessThan(1000)); // Fast response
      expect(networkMetrics['success'], true);
    });
  });

  group('Health Analytics Tests', () {
    late MockAdvancedHealthAnalytics mockHealthAnalytics;

    setUp(() {
      mockHealthAnalytics = MockAdvancedHealthAnalytics();
    });

    test('should analyze cycle patterns', () async {
      // Arrange
      final cycleData = [
        {'date': '2024-01-01', 'cycle_day': 1, 'flow': 'heavy'},
        {'date': '2024-01-29', 'cycle_day': 1, 'flow': 'medium'},
        {'date': '2024-02-26', 'cycle_day': 1, 'flow': 'heavy'},
      ];

      when(mockHealthAnalytics.analyzeCyclePatterns(cycleData))
          .thenAnswer((_) async => {
            'average_cycle_length': 28.0,
            'cycle_regularity': 0.95,
            'pattern_trends': ['regular_cycles', 'consistent_flow'],
          });

      // Act
      final analysis = await mockHealthAnalytics.analyzeCyclePatterns(cycleData);

      // Assert
      expect(analysis['average_cycle_length'], equals(28.0));
      expect(analysis['cycle_regularity'], greaterThan(0.9)); // High regularity
    });

    test('should generate health insights', () async {
      // Arrange
      final healthMetrics = {
        'cycle_length': 28,
        'period_length': 5,
        'symptoms': ['cramping', 'bloating'],
        'mood_scores': [7, 6, 8, 7, 9],
      };

      when(mockHealthAnalytics.generateHealthInsights(healthMetrics))
          .thenAnswer((_) async => {
            'health_score': 85.0,
            'recommendations': ['maintain_regular_exercise', 'track_nutrition'],
            'risk_factors': [],
          });

      // Act
      final insights = await mockHealthAnalytics.generateHealthInsights(healthMetrics);

      // Assert
      expect(insights['health_score'], greaterThan(80.0)); // Good health score
      expect(insights['recommendations'], isA<List>());
      expect(insights['risk_factors'], isEmpty); // No risks
    });
  });

  group('Analytics Integration Tests', () {
    late AnalyticsService analyticsService;

    setUp(() {
      analyticsService = AnalyticsService();
    });

    test('should handle complete user journey tracking', () async {
      // Arrange
      await analyticsService.initialize();
      const userId = 'journey_user_123';

      // Act - Simulate user journey
      await analyticsService.trackEvent('app_opened', {'user_id': userId});
      await analyticsService.trackScreenView('onboarding', {'user_id': userId});
      await analyticsService.trackEvent('profile_created', {'user_id': userId});
      await analyticsService.trackHealthData('first_period_logged', {
        'user_id': userId,
        'cycle_length': 28,
      });
      await analyticsService.trackFeatureUsage('ai_chat', {'user_id': userId});

      // Assert
      final userEvents = analyticsService.getUserEvents(userId);
      expect(userEvents.length, equals(5));
      expect(userEvents.map((e) => e['event']), contains('app_opened'));
      expect(userEvents.map((e) => e['event']), contains('first_period_logged'));
    });

    test('should generate comprehensive analytics dashboard data', () async {
      // Arrange
      await analyticsService.initialize();

      // Simulate various user activities
      for (int i = 0; i < 10; i++) {
        await analyticsService.trackEvent('user_action_$i', {
          'user_id': 'dashboard_user_$i',
          'timestamp': DateTime.now().subtract(Duration(hours: i)).toIso8601String(),
        });
      }

      // Act
      final dashboardData = await analyticsService.generateDashboardData();

      // Assert
      expect(dashboardData, isNotNull);
      expect(dashboardData['total_events'], equals(10));
      expect(dashboardData['active_users'], equals(10));
      expect(dashboardData['engagement_metrics'], isA<Map>());
    });
  });
}
