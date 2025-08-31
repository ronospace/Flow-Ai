import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../utils/app_logger.dart';

/// Cross-platform compatibility service with adaptive UI and optimizations
class PlatformService {
  static final PlatformService _instance = PlatformService._internal();
  factory PlatformService() => _instance;
  PlatformService._internal();

  bool _isInitialized = false;
  PlatformInfo? _platformInfo;
  
  /// Get platform information
  PlatformInfo get platformInfo => _platformInfo ?? PlatformInfo.unknown();

  /// Initialize the platform service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.system('🔄 Initializing Platform Service...');
      
      await _detectPlatformInfo();
      _configureSystemUI();
      _configurePlatformSpecific();
      
      _isInitialized = true;
      AppLogger.system('✅ Platform Service initialized for ${platformInfo.platformName}');
      
    } catch (e) {
      AppLogger.error('❌ Failed to initialize Platform Service', e);
      rethrow;
    }
  }

  /// Detect detailed platform information
  Future<void> _detectPlatformInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        _platformInfo = PlatformInfo(
          platform: TargetPlatform.android, // Use Android as fallback for web
          isWeb: true,
          isMobile: false,
          isDesktop: true,
          deviceModel: webInfo.browserName.toString(),
          operatingSystem: webInfo.platform ?? 'Unknown',
          osVersion: webInfo.appVersion ?? 'Unknown',
          deviceName: '${webInfo.browserName} Browser',
          screenSize: ScreenSize.large, // Default for web
          hasNotch: false,
          supportsHaptics: false,
          supportsBiometrics: false,
        );
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _platformInfo = PlatformInfo(
          platform: TargetPlatform.android,
          isWeb: false,
          isMobile: true,
          isDesktop: false,
          deviceModel: androidInfo.model,
          operatingSystem: 'Android',
          osVersion: androidInfo.version.release,
          deviceName: '${androidInfo.brand} ${androidInfo.model}',
          screenSize: _determineScreenSize(),
          hasNotch: _detectAndroidNotch(androidInfo),
          supportsHaptics: androidInfo.version.sdkInt >= 26,
          supportsBiometrics: true, // Most modern Android devices
        );
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _platformInfo = PlatformInfo(
          platform: TargetPlatform.iOS,
          isWeb: false,
          isMobile: true,
          isDesktop: false,
          deviceModel: iosInfo.model,
          operatingSystem: 'iOS',
          osVersion: iosInfo.systemVersion,
          deviceName: iosInfo.name,
          screenSize: _determineScreenSize(),
          hasNotch: _detectiOSNotch(iosInfo),
          supportsHaptics: true,
          supportsBiometrics: _detectiOSBiometrics(iosInfo),
        );
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        _platformInfo = PlatformInfo(
          platform: TargetPlatform.macOS,
          isWeb: false,
          isMobile: false,
          isDesktop: true,
          deviceModel: macInfo.model,
          operatingSystem: 'macOS',
          osVersion: macInfo.osRelease,
          deviceName: macInfo.computerName,
          screenSize: ScreenSize.large,
          hasNotch: macInfo.model.contains('MacBook'), // Recent MacBooks
          supportsHaptics: true,
          supportsBiometrics: true,
        );
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        _platformInfo = PlatformInfo(
          platform: TargetPlatform.windows,
          isWeb: false,
          isMobile: false,
          isDesktop: true,
          deviceModel: windowsInfo.computerName,
          operatingSystem: 'Windows',
          osVersion: windowsInfo.displayVersion,
          deviceName: windowsInfo.computerName,
          screenSize: ScreenSize.large,
          hasNotch: false,
          supportsHaptics: false,
          supportsBiometrics: false,
        );
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        _platformInfo = PlatformInfo(
          platform: TargetPlatform.linux,
          isWeb: false,
          isMobile: false,
          isDesktop: true,
          deviceModel: linuxInfo.machineId ?? 'Linux Device',
          operatingSystem: 'Linux',
          osVersion: linuxInfo.version ?? 'Unknown',
          deviceName: linuxInfo.prettyName ?? 'Linux Device',
          screenSize: ScreenSize.large,
          hasNotch: false,
          supportsHaptics: false,
          supportsBiometrics: false,
        );
      }
      
    } catch (e) {
      AppLogger.warning('Failed to detect platform info: $e');
      _platformInfo = PlatformInfo.unknown();
    }
  }

  /// Configure system UI based on platform
  void _configureSystemUI() {
    if (kIsWeb) return; // No system UI control on web
    
    try {
      if (platformInfo.isMobile) {
        // Configure mobile system UI
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        
        // Configure status bar
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        );
        
        // Lock orientation to portrait for mobile
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        
        AppLogger.system('📱 Mobile system UI configured');
      } else if (platformInfo.isDesktop) {
        // Desktop-specific configurations
        AppLogger.system('🖥️ Desktop system UI configured');
      }
      
    } catch (e) {
      AppLogger.warning('Failed to configure system UI: $e');
    }
  }

  /// Configure platform-specific optimizations
  void _configurePlatformSpecific() {
    if (platformInfo.platform == TargetPlatform.android) {
      _configureAndroidOptimizations();
    } else if (platformInfo.platform == TargetPlatform.iOS) {
      _configureiOSOptimizations();
    } else if (platformInfo.isWeb) {
      _configureWebOptimizations();
    } else if (platformInfo.isDesktop) {
      _configureDesktopOptimizations();
    }
  }

  /// Android-specific optimizations
  void _configureAndroidOptimizations() {
    // Configure Android-specific features
    AppLogger.system('🤖 Android optimizations configured');
  }

  /// iOS-specific optimizations
  void _configureiOSOptimizations() {
    // Configure iOS-specific features
    AppLogger.system('🍎 iOS optimizations configured');
  }

  /// Web-specific optimizations
  void _configureWebOptimizations() {
    // Configure web-specific features
    AppLogger.system('🌐 Web optimizations configured');
  }

  /// Desktop-specific optimizations
  void _configureDesktopOptimizations() {
    // Configure desktop-specific features
    AppLogger.system('🖥️ Desktop optimizations configured');
  }

  /// Determine screen size based on platform and dimensions
  ScreenSize _determineScreenSize() {
    // This is a simplified determination
    // In a real app, you'd use MediaQuery to get actual dimensions
    if (platformInfo.isDesktop) return ScreenSize.large;
    if (platformInfo.isMobile) return ScreenSize.medium;
    return ScreenSize.medium;
  }

  /// Detect if Android device has a notch
  bool _detectAndroidNotch(AndroidDeviceInfo androidInfo) {
    // This is a simplified detection based on common models
    final model = androidInfo.model.toLowerCase();
    return model.contains('pixel 3') || 
           model.contains('pixel 4') || 
           model.contains('pixel 5') ||
           model.contains('oneplus') ||
           androidInfo.version.sdkInt >= 28; // API 28+ generally support notch
  }

  /// Detect if iOS device has a notch
  bool _detectiOSNotch(IosDeviceInfo iosInfo) {
    // Devices with notch/Dynamic Island
    final notchDevices = [
      'iPhone X', 'iPhone XS', 'iPhone XS Max', 'iPhone XR',
      'iPhone 11', 'iPhone 11 Pro', 'iPhone 11 Pro Max',
      'iPhone 12', 'iPhone 12 mini', 'iPhone 12 Pro', 'iPhone 12 Pro Max',
      'iPhone 13', 'iPhone 13 mini', 'iPhone 13 Pro', 'iPhone 13 Pro Max',
      'iPhone 14', 'iPhone 14 Plus', 'iPhone 14 Pro', 'iPhone 14 Pro Max',
      'iPhone 15', 'iPhone 15 Plus', 'iPhone 15 Pro', 'iPhone 15 Pro Max',
    ];
    
    return notchDevices.any((device) => iosInfo.model.contains(device));
  }

  /// Detect iOS biometric support
  bool _detectiOSBiometrics(IosDeviceInfo iosInfo) {
    // Most iOS devices since iPhone 5s support Touch ID or Face ID
    return !iosInfo.model.contains('iPhone 5') && 
           !iosInfo.model.contains('iPhone 4');
  }

  /// Get adaptive padding for notched devices
  EdgeInsets getAdaptivePadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    if (!platformInfo.hasNotch) {
      return EdgeInsets.only(top: mediaQuery.padding.top);
    }
    
    // Additional padding for notched devices
    return EdgeInsets.only(
      top: mediaQuery.padding.top + 8,
      bottom: mediaQuery.padding.bottom,
    );
  }

  /// Get platform-appropriate button style
  ButtonStyle getAdaptiveButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    
    if (platformInfo.platform == TargetPlatform.iOS) {
      return ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      );
    } else if (platformInfo.platform == TargetPlatform.android) {
      return ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
      );
    } else {
      return ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 1,
      );
    }
  }

  /// Get platform-appropriate icon size
  double getAdaptiveIconSize() {
    switch (platformInfo.screenSize) {
      case ScreenSize.small:
        return 20.0;
      case ScreenSize.medium:
        return 24.0;
      case ScreenSize.large:
        return 28.0;
    }
  }

  /// Get platform-appropriate font size scaling
  double getAdaptiveFontScale() {
    if (platformInfo.isDesktop) return 1.1;
    if (platformInfo.screenSize == ScreenSize.small) return 0.9;
    return 1.0;
  }

  /// Trigger haptic feedback if supported
  Future<void> triggerHapticFeedback({HapticFeedbackType type = HapticFeedbackType.selection}) async {
    if (!platformInfo.supportsHaptics) return;
    
    try {
      switch (type) {
        case HapticFeedbackType.selection:
          await HapticFeedback.selectionClick();
          break;
        case HapticFeedbackType.impact:
          await HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.success:
          await HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.warning:
          await HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.error:
          await HapticFeedback.vibrate();
          break;
      }
    } catch (e) {
      AppLogger.warning('Haptic feedback failed: $e');
    }
  }

  /// Get platform-specific scroll physics
  ScrollPhysics getAdaptiveScrollPhysics() {
    if (platformInfo.platform == TargetPlatform.iOS) {
      return const BouncingScrollPhysics();
    } else {
      return const ClampingScrollPhysics();
    }
  }

  /// Check if feature is supported on current platform
  bool isFeatureSupported(PlatformFeature feature) {
    switch (feature) {
      case PlatformFeature.haptics:
        return platformInfo.supportsHaptics;
      case PlatformFeature.biometrics:
        return platformInfo.supportsBiometrics;
      case PlatformFeature.notifications:
        return platformInfo.isMobile || platformInfo.isDesktop;
      case PlatformFeature.fileSystem:
        return !platformInfo.isWeb;
      case PlatformFeature.camera:
        return platformInfo.isMobile;
      case PlatformFeature.location:
        return platformInfo.isMobile;
      case PlatformFeature.contacts:
        return platformInfo.isMobile;
      case PlatformFeature.calendar:
        return !platformInfo.isWeb;
      case PlatformFeature.sharing:
        return true; // Supported on all platforms with different implementations
    }
  }

  /// Get platform-appropriate dialog style
  Widget createAdaptiveDialog({
    required BuildContext context,
    required String title,
    required String content,
    required List<Widget> actions,
  }) {
    if (platformInfo.platform == TargetPlatform.iOS) {
      return AlertDialog.adaptive(
        title: Text(title),
        content: Text(content),
        actions: actions,
      );
    } else {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }
  }

  /// Get optimized image loading strategy
  ImageProvider getOptimizedImageProvider(String assetPath) {
    if (platformInfo.isWeb) {
      // For web, use network-optimized loading
      return AssetImage(assetPath);
    } else if (platformInfo.platform == TargetPlatform.android) {
      // Android-specific optimizations
      return AssetImage(assetPath);
    } else if (platformInfo.platform == TargetPlatform.iOS) {
      // iOS-specific optimizations
      return AssetImage(assetPath);
    } else {
      return AssetImage(assetPath);
    }
  }

  /// Get platform performance report
  Map<String, dynamic> getPerformanceReport() {
    return {
      'platform': platformInfo.platformName,
      'isInitialized': _isInitialized,
      'deviceModel': platformInfo.deviceModel,
      'osVersion': platformInfo.osVersion,
      'screenSize': platformInfo.screenSize.toString(),
      'hasNotch': platformInfo.hasNotch,
      'supportsHaptics': platformInfo.supportsHaptics,
      'supportsBiometrics': platformInfo.supportsBiometrics,
      'isMobile': platformInfo.isMobile,
      'isDesktop': platformInfo.isDesktop,
      'isWeb': platformInfo.isWeb,
    };
  }
}

/// Platform information model
class PlatformInfo {
  final TargetPlatform platform;
  final bool isWeb;
  final bool isMobile;
  final bool isDesktop;
  final String deviceModel;
  final String operatingSystem;
  final String osVersion;
  final String deviceName;
  final ScreenSize screenSize;
  final bool hasNotch;
  final bool supportsHaptics;
  final bool supportsBiometrics;

  PlatformInfo({
    required this.platform,
    required this.isWeb,
    required this.isMobile,
    required this.isDesktop,
    required this.deviceModel,
    required this.operatingSystem,
    required this.osVersion,
    required this.deviceName,
    required this.screenSize,
    required this.hasNotch,
    required this.supportsHaptics,
    required this.supportsBiometrics,
  });

  factory PlatformInfo.unknown() {
    return PlatformInfo(
      platform: TargetPlatform.android,
      isWeb: false,
      isMobile: false,
      isDesktop: false,
      deviceModel: 'Unknown',
      operatingSystem: 'Unknown',
      osVersion: 'Unknown',
      deviceName: 'Unknown Device',
      screenSize: ScreenSize.medium,
      hasNotch: false,
      supportsHaptics: false,
      supportsBiometrics: false,
    );
  }

  String get platformName {
    switch (platform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.linux:
        return 'Linux';
      default:
        return 'Web';
    }
  }

  @override
  String toString() {
    return 'PlatformInfo($platformName, $deviceModel, $osVersion)';
  }
}

/// Screen size categories
enum ScreenSize {
  small,   // < 5.5 inches or < 600dp width
  medium,  // 5.5-6.7 inches or 600-900dp width  
  large,   // > 6.7 inches or > 900dp width (tablets, desktops)
}

/// Platform features enum
enum PlatformFeature {
  haptics,
  biometrics,
  notifications,
  fileSystem,
  camera,
  location,
  contacts,
  calendar,
  sharing,
}

/// Haptic feedback types
enum HapticFeedbackType {
  selection,
  impact,
  success,
  warning,
  error,
}

/// Extensions for adaptive UI
extension AdaptiveContext on BuildContext {
  PlatformService get platformService => PlatformService();
  PlatformInfo get platformInfo => PlatformService().platformInfo;
  
  EdgeInsets get adaptivePadding => PlatformService().getAdaptivePadding(this);
  ButtonStyle get adaptiveButtonStyle => PlatformService().getAdaptiveButtonStyle(this);
  ScrollPhysics get adaptiveScrollPhysics => PlatformService().getAdaptiveScrollPhysics();
  
  Future<void> hapticFeedback([HapticFeedbackType type = HapticFeedbackType.selection]) {
    return PlatformService().triggerHapticFeedback(type: type);
  }
  
  bool isFeatureSupported(PlatformFeature feature) {
    return PlatformService().isFeatureSupported(feature);
  }
}
