import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow_ai/core/services/auth_service.dart';
import 'package:flow_ai/core/services/app_enhancement_service.dart';
import 'package:flow_ai/features/settings/providers/settings_provider.dart';
import 'package:flow_ai/features/cycle/providers/cycle_provider.dart';
import 'package:flow_ai/features/insights/providers/insights_provider.dart';
import 'package:flow_ai/features/health/providers/health_provider.dart';

/// Comprehensive test helpers and utilities for Flow AI app testing
class TestHelpers {
  static late SharedPreferences sharedPreferences;
  static late MockAuthService mockAuthService;

  /// Initialize test environment
  static Future<void> setUp() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Initialize SharedPreferences with empty map for testing
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();

    // Initialize mock services
    mockAuthService = MockAuthService();
    
    // Setup App Enhancement Service for testing
    final enhancementService = AppEnhancementService();
    await enhancementService.initialize();
  }

  /// Clean up test environment
  static Future<void> tearDown() async {
    await sharedPreferences.clear();
    AppEnhancementService().dispose();
  }

  /// Create a widget wrapper with all necessary providers for testing
  static Widget createTestWidget({
    required Widget child,
    SettingsProvider? settingsProvider,
    CycleProvider? cycleProvider,
    InsightsProvider? insightsProvider,
    HealthProvider? healthProvider,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => settingsProvider ?? SettingsProvider(),
          ),
          ChangeNotifierProvider<CycleProvider>(
            create: (_) => cycleProvider ?? CycleProvider(),
          ),
          ChangeNotifierProvider<InsightsProvider>(
            create: (_) => insightsProvider ?? InsightsProvider(),
          ),
          ChangeNotifierProvider<HealthProvider>(
            create: (_) => healthProvider ?? HealthProvider(),
          ),
        ],
        child: child,
      ),
    );
  }

  /// Create a minimal test widget for simple widget tests
  static Widget createMinimalTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// Pump and settle with custom duration for animation testing
  static Future<void> pumpAndSettleAnimations(
    WidgetTester tester, {
    Duration duration = const Duration(seconds: 2),
  }) async {
    await tester.pumpAndSettle(duration);
  }

  /// Find widget by type and verify it exists
  static Finder findWidgetByType<T extends Widget>() {
    return find.byType(T);
  }

  /// Find widget by key and verify it exists
  static Finder findWidgetByKey(String key) {
    return find.byKey(Key(key));
  }

  /// Find text widget with specific content
  static Finder findTextWidget(String text) {
    return find.text(text);
  }

  /// Verify widget exists and is visible
  static void expectWidgetToExist(Finder finder) {
    expect(finder, findsOneWidget);
  }

  /// Verify widget doesn't exist
  static void expectWidgetNotToExist(Finder finder) {
    expect(finder, findsNothing);
  }

  /// Verify multiple widgets exist
  static void expectMultipleWidgets(Finder finder, int count) {
    expect(finder, findsNWidgets(count));
  }

  /// Tap widget and trigger rebuild
  static Future<void> tapWidget(
    WidgetTester tester,
    Finder finder, {
    bool pumpAndSettle = true,
  }) async {
    await tester.tap(finder);
    if (pumpAndSettle) {
      await tester.pumpAndSettle();
    }
  }

  /// Enter text into a text field
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text, {
    bool pumpAndSettle = true,
  }) async {
    await tester.enterText(finder, text);
    if (pumpAndSettle) {
      await tester.pumpAndSettle();
    }
  }

  /// Scroll widget in a specific direction
  static Future<void> scrollWidget(
    WidgetTester tester,
    Finder finder,
    Offset offset, {
    bool pumpAndSettle = true,
  }) async {
    await tester.drag(finder, offset);
    if (pumpAndSettle) {
      await tester.pumpAndSettle();
    }
  }

  /// Wait for a specific widget to appear
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpAndSettle();
    
    final endTime = DateTime.now().add(timeout);
    
    while (DateTime.now().isBefore(endTime)) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    
    throw TimeoutException('Widget not found within timeout', timeout);
  }

  /// Verify widget has specific text content
  static void expectWidgetHasText(Finder finder, String expectedText) {
    final widget = finder.evaluate().first.widget;
    if (widget is Text) {
      expect(widget.data, expectedText);
    } else {
      fail('Widget is not a Text widget');
    }
  }

  /// Verify widget is enabled/disabled
  static void expectWidgetEnabled(Finder finder, bool shouldBeEnabled) {
    final widget = finder.evaluate().first.widget;
    if (widget is ElevatedButton) {
      expect(widget.onPressed != null, shouldBeEnabled);
    } else if (widget is TextButton) {
      expect(widget.onPressed != null, shouldBeEnabled);
    } else if (widget is OutlinedButton) {
      expect(widget.onPressed != null, shouldBeEnabled);
    } else {
      fail('Widget does not support enabled/disabled state verification');
    }
  }

  /// Create mock auth result for testing
  static AuthResult createMockAuthResult({
    bool success = true,
    String? error,
    MockUser? user,
  }) {
    if (success) {
      return AuthResult.success(user);
    } else {
      return AuthResult.failure(error ?? 'Test error');
    }
  }

  /// Create test user data
  static Map<String, dynamic> createTestUserData({
    String uid = 'test-uid-123',
    String email = 'test@example.com',
    String displayName = 'Test User',
    String provider = 'email',
  }) {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'provider': provider,
      'createdAt': DateTime.now().toIso8601String(),
      'lastLogin': DateTime.now().toIso8601String(),
    };
  }

  /// Setup mock SharedPreferences with test data
  static Future<void> setupMockPreferences(Map<String, dynamic> data) async {
    SharedPreferences.setMockInitialValues(data);
    sharedPreferences = await SharedPreferences.getInstance();
  }

  /// Verify shared preferences contains specific data
  static void expectPreferencesContains(String key, dynamic value) {
    expect(sharedPreferences.get(key), value);
  }

  /// Test performance of a specific operation
  static Future<Duration> measurePerformance(Future<void> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Generate test cycle data for testing
  static List<Map<String, dynamic>> generateTestCycleData({int cycles = 3}) {
    final data = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    for (int i = 0; i < cycles; i++) {
      final cycleStart = now.subtract(Duration(days: (i * 28) + (28 - i)));
      data.add({
        'id': 'cycle-$i',
        'startDate': cycleStart.toIso8601String(),
        'endDate': cycleStart.add(const Duration(days: 5)).toIso8601String(),
        'length': 28,
        'flow': ['heavy', 'medium', 'light', 'spotting', 'none'][i % 5],
        'symptoms': ['cramps', 'mood_changes', 'bloating'],
        'notes': 'Test cycle $i',
      });
    }
    
    return data;
  }

  /// Generate test health data
  static Map<String, dynamic> generateTestHealthData() {
    return {
      'weight': 65.5,
      'height': 165.0,
      'bmi': 24.1,
      'lastUpdated': DateTime.now().toIso8601String(),
      'sleepHours': 7.5,
      'waterIntake': 2.1,
      'exercise': {
        'type': 'cardio',
        'duration': 30,
        'intensity': 'moderate',
      },
    };
  }
}

/// Mock classes for testing
class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock {
  @override
  String get uid => 'test-uid-123';
  
  @override
  String? get email => 'test@example.com';
  
  @override
  String? get displayName => 'Test User';
  
  @override
  bool get emailVerified => true;
}

/// Custom timeout exception for widget testing
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;
  
  TimeoutException(this.message, this.timeout);
  
  @override
  String toString() => 'TimeoutException: $message (${timeout.inMilliseconds}ms)';
}

/// Test data generators
class TestDataGenerator {
  /// Generate random test email
  static String generateTestEmail() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return 'test$random@example.com';
  }
  
  /// Generate random display name
  static String generateDisplayName() {
    final names = ['Alice', 'Bob', 'Carol', 'David', 'Eve', 'Frank'];
    final surnames = ['Smith', 'Johnson', 'Brown', 'Davis', 'Wilson', 'Miller'];
    return '${names[DateTime.now().millisecond % names.length]} ${surnames[DateTime.now().second % surnames.length]}';
  }
  
  /// Generate random password
  static String generatePassword({int length = 12}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(length, (index) => chars[(random + index) % chars.length]).join();
  }
}

/// Test matchers for custom assertions
class CustomMatchers {
  /// Matcher to verify widget has specific color
  static Matcher hasColor(Color expectedColor) {
    return _ColorMatcher(expectedColor);
  }
  
  /// Matcher to verify text has specific font weight
  static Matcher hasFontWeight(FontWeight expectedWeight) {
    return _FontWeightMatcher(expectedWeight);
  }
}

class _ColorMatcher extends Matcher {
  final Color expectedColor;
  
  _ColorMatcher(this.expectedColor);
  
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is Container && item.decoration is BoxDecoration) {
      final decoration = item.decoration as BoxDecoration;
      return decoration.color == expectedColor;
    }
    return false;
  }
  
  @override
  Description describe(Description description) {
    return description.add('has color $expectedColor');
  }
}

class _FontWeightMatcher extends Matcher {
  final FontWeight expectedWeight;
  
  _FontWeightMatcher(this.expectedWeight);
  
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is Text && item.style != null) {
      return item.style!.fontWeight == expectedWeight;
    }
    return false;
  }
  
  @override
  Description describe(Description description) {
    return description.add('has font weight $expectedWeight');
  }
}
