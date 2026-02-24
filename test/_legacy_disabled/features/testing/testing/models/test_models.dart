
// === ENUMS ===

enum TestType {
  unit,
  widget,
  integration,
  performance,
  golden,
  accessibility,
  smoke,
  regression,
}

enum TestStatus {
  pending,
  running,
  passed,
  failed,
  skipped,
  timeout,
  error,
}

enum TestPriority {
  low,
  medium,
  high,
  critical,
}

enum TestCategory {
  authentication,
  dataStorage,
  userInterface,
  networking,
  biometric,
  notification,
  analytics,
  performance,
  security,
  accessibility,
}

enum MockDataType {
  cycleData,
  symptomData,
  moodData,
  userProfile,
  notifications,
  healthMetrics,
  predictions,
  clinicalData,
}

enum AssertionType {
  equals,
  notEquals,
  greaterThan,
  lessThan,
  contains,
  notContains,
  isEmpty,
  isNotEmpty,
  isNull,
  isNotNull,
  isTrue,
  isFalse,
  throws,
  doesNotThrow,
}

// === CORE TEST MODELS ===

class TestCase {
  final String id;
  final String name;
  final String description;
  final TestType type;
  final TestCategory category;
  final TestPriority priority;
  final List<String> tags;
  final Duration timeout;
  final bool enabled;
  final Map<String, dynamic> metadata;
  
  // Test execution details
  TestStatus status;
  Duration? executionTime;
  String? errorMessage;
  String? stackTrace;
  DateTime? startTime;
  DateTime? endTime;
  
  TestCase({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    this.priority = TestPriority.medium,
    this.tags = const [],
    this.timeout = const Duration(seconds: 30),
    this.enabled = true,
    this.metadata = const {},
    this.status = TestStatus.pending,
    this.executionTime,
    this.errorMessage,
    this.stackTrace,
    this.startTime,
    this.endTime,
  });

  bool get isPassed => status == TestStatus.passed;
  bool get isFailed => status == TestStatus.failed;
  bool get isRunning => status == TestStatus.running;
  bool get isCompleted => status == TestStatus.passed || status == TestStatus.failed;

  TestCase copyWith({
    TestStatus? status,
    Duration? executionTime,
    String? errorMessage,
    String? stackTrace,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return TestCase(
      id: id,
      name: name,
      description: description,
      type: type,
      category: category,
      priority: priority,
      tags: tags,
      timeout: timeout,
      enabled: enabled,
      metadata: metadata,
      status: status ?? this.status,
      executionTime: executionTime ?? this.executionTime,
      errorMessage: errorMessage ?? this.errorMessage,
      stackTrace: stackTrace ?? this.stackTrace,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'category': category.name,
      'priority': priority.name,
      'tags': tags,
      'timeout_ms': timeout.inMilliseconds,
      'enabled': enabled,
      'metadata': metadata,
      'status': status.name,
      'execution_time_ms': executionTime?.inMilliseconds,
      'error_message': errorMessage,
      'stack_trace': stackTrace,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
    };
  }

  factory TestCase.fromJson(Map<String, dynamic> json) {
    return TestCase(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: TestType.values.firstWhere((e) => e.name == json['type']),
      category: TestCategory.values.firstWhere((e) => e.name == json['category']),
      priority: TestPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TestPriority.medium,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      timeout: Duration(milliseconds: json['timeout_ms'] ?? 30000),
      enabled: json['enabled'] ?? true,
      metadata: json['metadata'] ?? {},
      status: TestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TestStatus.pending,
      ),
      executionTime: json['execution_time_ms'] != null 
          ? Duration(milliseconds: json['execution_time_ms'])
          : null,
      errorMessage: json['error_message'],
      stackTrace: json['stack_trace'],
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time'])
          : null,
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time'])
          : null,
    );
  }
}

// === TEST SUITE ===

class TestSuite {
  final String id;
  final String name;
  final String description;
  final List<TestCase> testCases;
  final Map<String, dynamic> configuration;
  final bool parallel;
  final int maxConcurrency;
  
  // Execution state
  TestStatus status;
  DateTime? startTime;
  DateTime? endTime;
  int passedCount;
  int failedCount;
  int skippedCount;
  Duration totalExecutionTime;

  TestSuite({
    required this.id,
    required this.name,
    required this.description,
    required this.testCases,
    this.configuration = const {},
    this.parallel = false,
    this.maxConcurrency = 4,
    this.status = TestStatus.pending,
    this.startTime,
    this.endTime,
    this.passedCount = 0,
    this.failedCount = 0,
    this.skippedCount = 0,
    this.totalExecutionTime = Duration.zero,
  });

  int get totalTests => testCases.length;
  int get enabledTests => testCases.where((t) => t.enabled).length;
  double get successRate => totalTests > 0 ? passedCount / totalTests : 0.0;
  bool get isCompleted => status == TestStatus.passed || status == TestStatus.failed;

  List<TestCase> getTestsByType(TestType type) {
    return testCases.where((test) => test.type == type).toList();
  }

  List<TestCase> getTestsByCategory(TestCategory category) {
    return testCases.where((test) => test.category == category).toList();
  }

  List<TestCase> getTestsByStatus(TestStatus status) {
    return testCases.where((test) => test.status == status).toList();
  }

  List<TestCase> getTestsByTag(String tag) {
    return testCases.where((test) => test.tags.contains(tag)).toList();
  }

  void updateStats() {
    passedCount = testCases.where((t) => t.status == TestStatus.passed).length;
    failedCount = testCases.where((t) => t.status == TestStatus.failed).length;
    skippedCount = testCases.where((t) => t.status == TestStatus.skipped).length;
    
    totalExecutionTime = testCases
        .where((t) => t.executionTime != null)
        .fold(Duration.zero, (sum, test) => sum + test.executionTime!);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'test_cases': testCases.map((t) => t.toJson()).toList(),
      'configuration': configuration,
      'parallel': parallel,
      'max_concurrency': maxConcurrency,
      'status': status.name,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'passed_count': passedCount,
      'failed_count': failedCount,
      'skipped_count': skippedCount,
      'total_execution_time_ms': totalExecutionTime.inMilliseconds,
      'total_tests': totalTests,
      'success_rate': successRate,
    };
  }
}

// === TEST CONFIGURATION ===

class TestConfiguration {
  final bool enableUnitTests;
  final bool enableWidgetTests;
  final bool enableIntegrationTests;
  final bool enablePerformanceTests;
  final bool enableGoldenTests;
  final bool enableAccessibilityTests;
  final bool generateCodeCoverage;
  final bool enableParallelExecution;
  final int maxConcurrency;
  final Duration defaultTimeout;
  final String testDataPath;
  final String outputPath;
  final List<String> excludePatterns;
  final Map<String, dynamic> customSettings;

  const TestConfiguration({
    this.enableUnitTests = true,
    this.enableWidgetTests = true,
    this.enableIntegrationTests = true,
    this.enablePerformanceTests = false,
    this.enableGoldenTests = false,
    this.enableAccessibilityTests = true,
    this.generateCodeCoverage = true,
    this.enableParallelExecution = true,
    this.maxConcurrency = 4,
    this.defaultTimeout = const Duration(seconds: 30),
    this.testDataPath = 'test/fixtures',
    this.outputPath = 'test/reports',
    this.excludePatterns = const [],
    this.customSettings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'enable_unit_tests': enableUnitTests,
      'enable_widget_tests': enableWidgetTests,
      'enable_integration_tests': enableIntegrationTests,
      'enable_performance_tests': enablePerformanceTests,
      'enable_golden_tests': enableGoldenTests,
      'enable_accessibility_tests': enableAccessibilityTests,
      'generate_code_coverage': generateCodeCoverage,
      'enable_parallel_execution': enableParallelExecution,
      'max_concurrency': maxConcurrency,
      'default_timeout_ms': defaultTimeout.inMilliseconds,
      'test_data_path': testDataPath,
      'output_path': outputPath,
      'exclude_patterns': excludePatterns,
      'custom_settings': customSettings,
    };
  }

  factory TestConfiguration.fromJson(Map<String, dynamic> json) {
    return TestConfiguration(
      enableUnitTests: json['enable_unit_tests'] ?? true,
      enableWidgetTests: json['enable_widget_tests'] ?? true,
      enableIntegrationTests: json['enable_integration_tests'] ?? true,
      enablePerformanceTests: json['enable_performance_tests'] ?? false,
      enableGoldenTests: json['enable_golden_tests'] ?? false,
      enableAccessibilityTests: json['enable_accessibility_tests'] ?? true,
      generateCodeCoverage: json['generate_code_coverage'] ?? true,
      enableParallelExecution: json['enable_parallel_execution'] ?? true,
      maxConcurrency: json['max_concurrency'] ?? 4,
      defaultTimeout: Duration(milliseconds: json['default_timeout_ms'] ?? 30000),
      testDataPath: json['test_data_path'] ?? 'test/fixtures',
      outputPath: json['output_path'] ?? 'test/reports',
      excludePatterns: List<String>.from(json['exclude_patterns'] ?? []),
      customSettings: json['custom_settings'] ?? {},
    );
  }
}

// === MOCK DATA MODELS ===

class MockDataGenerator {
  final MockDataType type;
  final Map<String, dynamic> parameters;
  final int count;
  final bool randomize;

  const MockDataGenerator({
    required this.type,
    this.parameters = const {},
    this.count = 1,
    this.randomize = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'parameters': parameters,
      'count': count,
      'randomize': randomize,
    };
  }
}

class TestAssertion {
  final String id;
  final String description;
  final AssertionType type;
  final dynamic expected;
  final dynamic actual;
  final bool passed;
  final String? message;

  const TestAssertion({
    required this.id,
    required this.description,
    required this.type,
    this.expected,
    this.actual,
    required this.passed,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'type': type.name,
      'expected': expected?.toString(),
      'actual': actual?.toString(),
      'passed': passed,
      'message': message,
    };
  }
}

// === TEST RESULT MODELS ===

class TestResult {
  final String testCaseId;
  final TestStatus status;
  final Duration executionTime;
  final List<TestAssertion> assertions;
  final String? errorMessage;
  final String? stackTrace;
  final Map<String, dynamic> metrics;
  final DateTime timestamp;

  const TestResult({
    required this.testCaseId,
    required this.status,
    required this.executionTime,
    required this.assertions,
    this.errorMessage,
    this.stackTrace,
    this.metrics = const {},
    required this.timestamp,
  });

  bool get isPassed => status == TestStatus.passed;
  bool get isFailed => status == TestStatus.failed;
  int get passedAssertions => assertions.where((a) => a.passed).length;
  int get failedAssertions => assertions.where((a) => !a.passed).length;

  Map<String, dynamic> toJson() {
    return {
      'test_case_id': testCaseId,
      'status': status.name,
      'execution_time_ms': executionTime.inMilliseconds,
      'assertions': assertions.map((a) => a.toJson()).toList(),
      'error_message': errorMessage,
      'stack_trace': stackTrace,
      'metrics': metrics,
      'timestamp': timestamp.toIso8601String(),
      'passed_assertions': passedAssertions,
      'failed_assertions': failedAssertions,
    };
  }
}

class TestReport {
  final String id;
  final String name;
  final DateTime generatedAt;
  final Duration totalExecutionTime;
  final List<TestSuite> testSuites;
  final Map<String, dynamic> summary;
  final List<String> tags;
  final String environment;

  TestReport({
    required this.id,
    required this.name,
    required this.generatedAt,
    required this.totalExecutionTime,
    required this.testSuites,
    required this.summary,
    this.tags = const [],
    this.environment = 'test',
  });

  int get totalTests => testSuites.fold(0, (sum, suite) => sum + suite.totalTests);
  int get totalPassed => testSuites.fold(0, (sum, suite) => sum + suite.passedCount);
  int get totalFailed => testSuites.fold(0, (sum, suite) => sum + suite.failedCount);
  int get totalSkipped => testSuites.fold(0, (sum, suite) => sum + suite.skippedCount);
  double get overallSuccessRate => totalTests > 0 ? totalPassed / totalTests : 0.0;

  Map<TestType, int> get testsByType {
    final map = <TestType, int>{};
    for (final suite in testSuites) {
      for (final testCase in suite.testCases) {
        map[testCase.type] = (map[testCase.type] ?? 0) + 1;
      }
    }
    return map;
  }

  Map<TestCategory, int> get testsByCategory {
    final map = <TestCategory, int>{};
    for (final suite in testSuites) {
      for (final testCase in suite.testCases) {
        map[testCase.category] = (map[testCase.category] ?? 0) + 1;
      }
    }
    return map;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'generated_at': generatedAt.toIso8601String(),
      'total_execution_time_ms': totalExecutionTime.inMilliseconds,
      'test_suites': testSuites.map((s) => s.toJson()).toList(),
      'summary': summary,
      'tags': tags,
      'environment': environment,
      'total_tests': totalTests,
      'total_passed': totalPassed,
      'total_failed': totalFailed,
      'total_skipped': totalSkipped,
      'overall_success_rate': overallSuccessRate,
      'tests_by_type': testsByType.map((k, v) => MapEntry(k.name, v)),
      'tests_by_category': testsByCategory.map((k, v) => MapEntry(k.name, v)),
    };
  }
}

// === COVERAGE MODELS ===

class CoverageInfo {
  final String filePath;
  final int totalLines;
  final int coveredLines;
  final int uncoveredLines;
  final double coverage;
  final List<int> coveredLineNumbers;
  final List<int> uncoveredLineNumbers;

  CoverageInfo({
    required this.filePath,
    required this.totalLines,
    required this.coveredLines,
    required this.uncoveredLines,
    required this.coverage,
    required this.coveredLineNumbers,
    required this.uncoveredLineNumbers,
  });

  Map<String, dynamic> toJson() {
    return {
      'file_path': filePath,
      'total_lines': totalLines,
      'covered_lines': coveredLines,
      'uncovered_lines': uncoveredLines,
      'coverage': coverage,
      'covered_line_numbers': coveredLineNumbers,
      'uncovered_line_numbers': uncoveredLineNumbers,
    };
  }
}

class CoverageReport {
  final DateTime generatedAt;
  final List<CoverageInfo> files;
  final double overallCoverage;
  final int totalLines;
  final int totalCoveredLines;
  final Map<String, double> packageCoverage;

  CoverageReport({
    required this.generatedAt,
    required this.files,
    required this.overallCoverage,
    required this.totalLines,
    required this.totalCoveredLines,
    required this.packageCoverage,
  });

  Map<String, dynamic> toJson() {
    return {
      'generated_at': generatedAt.toIso8601String(),
      'files': files.map((f) => f.toJson()).toList(),
      'overall_coverage': overallCoverage,
      'total_lines': totalLines,
      'total_covered_lines': totalCoveredLines,
      'package_coverage': packageCoverage,
    };
  }
}

// === PERFORMANCE TEST MODELS ===

class PerformanceMetric {
  final String name;
  final double value;
  final String unit;
  final double? threshold;
  final bool passed;

  const PerformanceMetric({
    required this.name,
    required this.value,
    required this.unit,
    this.threshold,
    required this.passed,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'threshold': threshold,
      'passed': passed,
    };
  }
}

class PerformanceTestResult {
  final String testId;
  final Duration executionTime;
  final List<PerformanceMetric> metrics;
  final Map<String, dynamic> systemInfo;
  final DateTime timestamp;

  const PerformanceTestResult({
    required this.testId,
    required this.executionTime,
    required this.metrics,
    required this.systemInfo,
    required this.timestamp,
  });

  bool get allMetricsPassed => metrics.every((m) => m.passed);
  List<PerformanceMetric> get failedMetrics => metrics.where((m) => !m.passed).toList();

  Map<String, dynamic> toJson() {
    return {
      'test_id': testId,
      'execution_time_ms': executionTime.inMilliseconds,
      'metrics': metrics.map((m) => m.toJson()).toList(),
      'system_info': systemInfo,
      'timestamp': timestamp.toIso8601String(),
      'all_metrics_passed': allMetricsPassed,
      'failed_metrics_count': failedMetrics.length,
    };
  }
}
