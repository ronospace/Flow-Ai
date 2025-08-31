import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/platform_service.dart';
import '../utils/app_logger.dart';

/// Platform-specific configuration manager
class PlatformConfig {
  static final PlatformConfig _instance = PlatformConfig._internal();
  factory PlatformConfig() => _instance;
  PlatformConfig._internal();

  final PlatformService _platformService = PlatformService();
  
  /// Get platform-specific Firebase configuration
  Map<String, dynamic> getFirebaseConfig() {
    final platformInfo = _platformService.platformInfo;
    
    final baseConfig = {
      'apiKey': _getApiKey(),
      'authDomain': _getAuthDomain(),
      'projectId': _getProjectId(),
      'storageBucket': _getStorageBucket(),
      'messagingSenderId': _getMessagingSenderId(),
      'appId': _getAppId(),
    };
    
    if (platformInfo.isWeb) {
      baseConfig.addAll({
        'measurementId': _getMeasurementId(),
      });
    }
    
    if (platformInfo.platform == TargetPlatform.iOS) {
      baseConfig.addAll({
        'iosBundleId': _getiOSBundleId(),
      });
    }
    
    if (platformInfo.platform == TargetPlatform.android) {
      baseConfig.addAll({
        'androidPackageName': _getAndroidPackageName(),
      });
    }
    
    return baseConfig;
  }

  /// Get platform-specific API endpoints
  Map<String, String> getApiEndpoints() {
    final platformInfo = _platformService.platformInfo;
    
    final baseUrl = _getBaseApiUrl();
    
    return {
      'base': baseUrl,
      'auth': '$baseUrl/auth',
      'cycles': '$baseUrl/cycles',
      'analytics': '$baseUrl/analytics',
      'sync': '$baseUrl/sync',
      'health': '$baseUrl/health',
      // Platform-specific endpoints
      if (platformInfo.isMobile) 'push': '$baseUrl/push',
      if (platformInfo.isWeb) 'web': '$baseUrl/web',
      if (platformInfo.isDesktop) 'desktop': '$baseUrl/desktop',
    };
  }

  /// Get platform-specific caching configuration
  Map<String, dynamic> getCacheConfig() {
    final platformInfo = _platformService.platformInfo;
    
    if (platformInfo.isWeb) {
      return {
        'maxSize': 50 * 1024 * 1024, // 50MB for web
        'maxAge': const Duration(hours: 24),
        'enablePersistentCache': false,
        'enableMemoryCache': true,
        'compressionEnabled': true,
      };
    } else if (platformInfo.isMobile) {
      return {
        'maxSize': 200 * 1024 * 1024, // 200MB for mobile
        'maxAge': const Duration(days: 7),
        'enablePersistentCache': true,
        'enableMemoryCache': true,
        'compressionEnabled': false,
      };
    } else {
      return {
        'maxSize': 500 * 1024 * 1024, // 500MB for desktop
        'maxAge': const Duration(days: 30),
        'enablePersistentCache': true,
        'enableMemoryCache': true,
        'compressionEnabled': false,
      };
    }
  }

  /// Get platform-specific performance settings
  Map<String, dynamic> getPerformanceConfig() {
    final platformInfo = _platformService.platformInfo;
    
    return {
      'enableImageCaching': true,
      'maxImageCacheSize': platformInfo.isMobile ? 100 : 200,
      'enablePreloading': !platformInfo.isWeb,
      'backgroundTasksEnabled': platformInfo.isMobile,
      'animationDuration': platformInfo.isWeb 
          ? const Duration(milliseconds: 200)
          : const Duration(milliseconds: 300),
      'enableHapticFeedback': platformInfo.supportsHaptics,
      'enableAnalytics': true,
      'crashReportingEnabled': !kDebugMode,
      'performanceMonitoringEnabled': !kDebugMode,
    };
  }

  /// Get platform-specific security settings
  Map<String, dynamic> getSecurityConfig() {
    final platformInfo = _platformService.platformInfo;
    
    return {
      'enableBiometrics': platformInfo.supportsBiometrics,
      'enableEncryption': true,
      'encryptionStrength': platformInfo.isMobile ? 256 : 512,
      'enableCertificatePinning': !platformInfo.isWeb,
      'sessionTimeout': platformInfo.isMobile 
          ? const Duration(hours: 24)
          : const Duration(hours: 8),
      'enableSecureStorage': !platformInfo.isWeb,
      'allowScreenshots': kDebugMode,
      'enableNetworkSecurity': true,
    };
  }

  /// Get platform-specific UI configuration
  Map<String, dynamic> getUIConfig() {
    final platformInfo = _platformService.platformInfo;
    
    return {
      'enableCustomTheme': true,
      'enableDynamicColors': platformInfo.platform == TargetPlatform.android,
      'enableMaterialYou': platformInfo.platform == TargetPlatform.android,
      'adaptiveNavigation': true,
      'enableTransitions': true,
      'transitionDuration': platformInfo.isWeb 
          ? const Duration(milliseconds: 200)
          : const Duration(milliseconds: 300),
      'enableScrollPhysics': true,
      'enableOverscroll': platformInfo.platform == TargetPlatform.iOS,
      'enableRipple': platformInfo.platform == TargetPlatform.android,
      'cardElevation': platformInfo.isDesktop ? 8.0 : 4.0,
      'borderRadius': platformInfo.platform == TargetPlatform.iOS ? 12.0 : 16.0,
    };
  }

  /// Get platform-specific feature flags
  Map<String, bool> getFeatureFlags() {
    final platformInfo = _platformService.platformInfo;
    
    return {
      'enableAppleSignIn': platformInfo.platform == TargetPlatform.iOS,
      'enableGoogleSignIn': true,
      'enableFacebookSignIn': platformInfo.isMobile,
      'enableBiometricAuth': platformInfo.supportsBiometrics,
      'enablePushNotifications': platformInfo.isMobile || platformInfo.isDesktop,
      'enableLocalNotifications': !platformInfo.isWeb,
      'enableBackgroundSync': platformInfo.isMobile,
      'enableOfflineMode': !platformInfo.isWeb,
      'enableExportData': true,
      'enableImportData': true,
      'enableDataSharing': true,
      'enableCrashReporting': !kDebugMode,
      'enableAnalytics': !kDebugMode,
      'enablePerformanceMonitoring': !kDebugMode,
      'enableDeepLinking': true,
      'enableUniversalLinks': platformInfo.platform == TargetPlatform.iOS,
      'enableAppLinks': platformInfo.platform == TargetPlatform.android,
      'enableWebSharing': platformInfo.isWeb,
      'enableFilePicker': !platformInfo.isWeb,
      'enableImagePicker': platformInfo.isMobile,
      'enableCameraPicker': platformInfo.isMobile,
      'enableLocationServices': platformInfo.isMobile,
      'enableContactsAccess': platformInfo.isMobile,
      'enableCalendarIntegration': !platformInfo.isWeb,
      'enableHealthKitIntegration': platformInfo.platform == TargetPlatform.iOS,
      'enableGoogleFitIntegration': platformInfo.platform == TargetPlatform.android,
    };
  }

  /// Get platform-specific build configuration
  Map<String, dynamic> getBuildConfig() {
    final platformInfo = _platformService.platformInfo;
    
    return {
      'enableCodePush': platformInfo.isMobile && !kDebugMode,
      'enableMinification': !kDebugMode,
      'enableObfuscation': !kDebugMode && platformInfo.isMobile,
      'enableR8': platformInfo.platform == TargetPlatform.android && !kDebugMode,
      'enableBitcode': platformInfo.platform == TargetPlatform.iOS && !kDebugMode,
      'enableSplitApk': platformInfo.platform == TargetPlatform.android && !kDebugMode,
      'enableAppBundle': platformInfo.platform == TargetPlatform.android && !kDebugMode,
      'enableTreeShaking': !kDebugMode,
      'enableDeferredComponents': platformInfo.isWeb && !kDebugMode,
      'targetSdkVersion': platformInfo.platform == TargetPlatform.android ? 34 : null,
      'minSdkVersion': platformInfo.platform == TargetPlatform.android ? 21 : null,
      'deploymentTarget': platformInfo.platform == TargetPlatform.iOS ? '12.0' : null,
    };
  }

  /// Get development/debug configuration
  Map<String, dynamic> getDebugConfig() {
    return {
      'enableDebugMode': kDebugMode,
      'enableProfiling': kProfileMode,
      'enableLogging': true,
      'logLevel': kDebugMode ? 'debug' : 'info',
      'enableDevTools': kDebugMode,
      'enableHotReload': kDebugMode,
      'enableAssertions': kDebugMode,
      'enableInspector': kDebugMode,
      'enablePerformanceOverlay': false,
      'showCheckerboardRasterCacheImages': false,
      'showCheckerboardOffscreenLayers': false,
    };
  }

  /// Initialize platform-specific configurations
  Future<void> initialize() async {
    try {
      AppLogger.system('🔄 Initializing Platform Configuration...');
      
      final configs = {
        'firebase': getFirebaseConfig(),
        'api': getApiEndpoints(),
        'cache': getCacheConfig(),
        'performance': getPerformanceConfig(),
        'security': getSecurityConfig(),
        'ui': getUIConfig(),
        'features': getFeatureFlags(),
        'build': getBuildConfig(),
        'debug': getDebugConfig(),
      };
      
      AppLogger.system('✅ Platform Configuration initialized');
      AppLogger.debug('Platform configs: $configs');
      
    } catch (e) {
      AppLogger.error('❌ Failed to initialize Platform Configuration', e);
      rethrow;
    }
  }

  // Private methods to get configuration values
  // These would typically come from environment variables or secure storage
  
  String _getApiKey() {
    if (kIsWeb) {
      return const String.fromEnvironment('FIREBASE_API_KEY_WEB', 
          defaultValue: 'your-web-api-key');
    } else if (Platform.isAndroid) {
      return const String.fromEnvironment('FIREBASE_API_KEY_ANDROID',
          defaultValue: 'your-android-api-key');
    } else if (Platform.isIOS) {
      return const String.fromEnvironment('FIREBASE_API_KEY_IOS',
          defaultValue: 'your-ios-api-key');
    }
    return 'your-default-api-key';
  }

  String _getAuthDomain() {
    return const String.fromEnvironment('FIREBASE_AUTH_DOMAIN',
        defaultValue: 'your-project.firebaseapp.com');
  }

  String _getProjectId() {
    return const String.fromEnvironment('FIREBASE_PROJECT_ID',
        defaultValue: 'your-project-id');
  }

  String _getStorageBucket() {
    return const String.fromEnvironment('FIREBASE_STORAGE_BUCKET',
        defaultValue: 'your-project.appspot.com');
  }

  String _getMessagingSenderId() {
    return const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID',
        defaultValue: 'your-sender-id');
  }

  String _getAppId() {
    if (kIsWeb) {
      return const String.fromEnvironment('FIREBASE_APP_ID_WEB',
          defaultValue: 'your-web-app-id');
    } else if (Platform.isAndroid) {
      return const String.fromEnvironment('FIREBASE_APP_ID_ANDROID',
          defaultValue: 'your-android-app-id');
    } else if (Platform.isIOS) {
      return const String.fromEnvironment('FIREBASE_APP_ID_IOS',
          defaultValue: 'your-ios-app-id');
    }
    return 'your-default-app-id';
  }

  String _getMeasurementId() {
    return const String.fromEnvironment('FIREBASE_MEASUREMENT_ID',
        defaultValue: 'your-measurement-id');
  }

  String _getiOSBundleId() {
    return const String.fromEnvironment('IOS_BUNDLE_ID',
        defaultValue: 'com.zyraflow.app');
  }

  String _getAndroidPackageName() {
    return const String.fromEnvironment('ANDROID_PACKAGE_NAME',
        defaultValue: 'com.zyraflow.flowai');
  }

  String _getBaseApiUrl() {
    if (kDebugMode) {
      return const String.fromEnvironment('API_URL_DEBUG',
          defaultValue: 'http://localhost:3000/api');
    } else {
      return const String.fromEnvironment('API_URL_PROD',
          defaultValue: 'https://api.flowai.com');
    }
  }
}

/// Platform-specific constants
class PlatformConstants {
  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Spacing constants
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Border radius constants
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  // Elevation constants
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;
  
  // Icon sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Text sizes
  static const double textXS = 12.0;
  static const double textS = 14.0;
  static const double textM = 16.0;
  static const double textL = 18.0;
  static const double textXL = 24.0;
  
  // Breakpoints
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;
  
  // Platform-specific constants
  static double getAdaptiveSpacing(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.small:
        return spacingS;
      case ScreenSize.medium:
        return spacingM;
      case ScreenSize.large:
        return spacingL;
    }
  }
  
  static double getAdaptiveRadius(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
        return radiusM;
      case TargetPlatform.android:
        return radiusL;
      default:
        return radiusM;
    }
  }
  
  static double getAdaptiveElevation(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
        return 0.0; // iOS prefers flat design
      case TargetPlatform.android:
        return elevationM;
      default:
        return elevationS;
    }
  }
}

/// Platform-specific permissions
class PlatformPermissions {
  static final PlatformService _platformService = PlatformService();
  
  /// Get required permissions for each platform
  static List<String> getRequiredPermissions() {
    final platformInfo = _platformService.platformInfo;
    final permissions = <String>[];
    
    if (platformInfo.platform == TargetPlatform.android) {
      permissions.addAll([
        'android.permission.INTERNET',
        'android.permission.ACCESS_NETWORK_STATE',
        'android.permission.WAKE_LOCK',
        'android.permission.RECEIVE_BOOT_COMPLETED',
        'android.permission.VIBRATE',
        'android.permission.USE_FINGERPRINT',
        'android.permission.USE_BIOMETRIC',
        'android.permission.CAMERA',
        'android.permission.READ_EXTERNAL_STORAGE',
        'android.permission.WRITE_EXTERNAL_STORAGE',
        'android.permission.ACCESS_COARSE_LOCATION',
        'android.permission.ACCESS_FINE_LOCATION',
        'android.permission.READ_CONTACTS',
        'android.permission.READ_CALENDAR',
        'android.permission.WRITE_CALENDAR',
      ]);
    }
    
    if (platformInfo.platform == TargetPlatform.iOS) {
      permissions.addAll([
        'NSCameraUsageDescription',
        'NSPhotoLibraryUsageDescription',
        'NSLocationWhenInUseUsageDescription',
        'NSLocationAlwaysAndWhenInUseUsageDescription',
        'NSContactsUsageDescription',
        'NSCalendarsUsageDescription',
        'NSRemindersUsageDescription',
        'NSFaceIDUsageDescription',
        'NSAppleMusicUsageDescription',
        'NSHealthShareUsageDescription',
        'NSHealthUpdateUsageDescription',
      ]);
    }
    
    return permissions;
  }

  /// Get optional permissions
  static List<String> getOptionalPermissions() {
    final platformInfo = _platformService.platformInfo;
    final permissions = <String>[];
    
    if (platformInfo.platform == TargetPlatform.android) {
      permissions.addAll([
        'android.permission.READ_PHONE_STATE',
        'android.permission.RECORD_AUDIO',
        'android.permission.BLUETOOTH',
        'android.permission.BLUETOOTH_ADMIN',
      ]);
    }
    
    if (platformInfo.platform == TargetPlatform.iOS) {
      permissions.addAll([
        'NSMicrophoneUsageDescription',
        'NSBluetoothAlwaysUsageDescription',
        'NSBluetoothPeripheralUsageDescription',
      ]);
    }
    
    return permissions;
  }
}

/// Platform-specific build tools and settings
class PlatformBuildConfig {
  static final PlatformService _platformService = PlatformService();
  
  /// Get platform-specific compiler flags
  static Map<String, List<String>> getCompilerFlags() {
    final platformInfo = _platformService.platformInfo;
    
    final flags = <String, List<String>>{};
    
    if (platformInfo.platform == TargetPlatform.android) {
      flags['android'] = [
        '--enable-software-rendering',
        '--skia-deterministic-rendering',
        '--enable-impeller',
      ];
    }
    
    if (platformInfo.platform == TargetPlatform.iOS) {
      flags['ios'] = [
        '--enable-impeller',
        '--ios-deterministic-rendering',
      ];
    }
    
    if (platformInfo.isWeb) {
      flags['web'] = [
        '--web-renderer=canvaskit',
        '--dart-define=FLUTTER_WEB_USE_SKIA=true',
      ];
    }
    
    return flags;
  }

  /// Get platform-specific optimization settings
  static Map<String, dynamic> getOptimizationSettings() {
    final platformInfo = _platformService.platformInfo;
    
    return {
      'enableShrinking': !kDebugMode,
      'enableMinification': !kDebugMode,
      'enableOptimization': !kDebugMode,
      'enableTreeShaking': !kDebugMode,
      'enableDeadCodeElimination': !kDebugMode,
      'enableCodeSplitting': platformInfo.isWeb && !kDebugMode,
      'enableLazyLoading': platformInfo.isWeb,
      'enablePrecompilation': !kDebugMode,
      'enableAOT': !kDebugMode && !platformInfo.isWeb,
      'enableJIT': kDebugMode || platformInfo.isWeb,
    };
  }
}
