import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/platform_service.dart';
import '../utils/app_logger.dart';

/// Build configuration manager for handling platform-specific build settings
class BuildConfig {
  static final BuildConfig _instance = BuildConfig._internal();
  factory BuildConfig() => _instance;
  BuildConfig._internal();

  final PlatformService _platformService = PlatformService();

  /// Get required dependencies for each platform
  Map<String, List<String>> getRequiredDependencies() {
    final platformInfo = _platformService.platformInfo;
    
    return {
      'common': [
        'flutter',
        'provider',
        'shared_preferences',
        'firebase_core',
        'firebase_auth',
        'firebase_firestore',
        'firebase_analytics',
        'firebase_crashlytics',
        'device_info_plus',
        'package_info_plus',
        'flutter_animate',
        'flutter_localizations',
        'intl',
        'http',
        'go_router',
        'logger',
      ],
      'mobile': [
        'firebase_messaging',
        'flutter_local_notifications',
        'permission_handler',
        'image_picker',
        'camera',
        'geolocator',
        'contacts_service',
        'add_2_calendar',
        'share_plus',
        'path_provider',
        'sqflite',
        'biometric_storage',
        'local_auth',
        'vibration',
        'haptic_feedback',
      ],
      'ios': [
        'sign_in_with_apple',
        'cupertino_icons',
        'health',
      ],
      'android': [
        'google_sign_in',
        'android_intent_plus',
        'health',
      ],
      'web': [
        'firebase_auth_web',
        'firebase_firestore_web',
        'js',
        'url_launcher_web',
        'file_picker_web',
      ],
      'desktop': [
        'window_manager',
        'screen_retriever',
        'flutter_native_splash',
        'bitsdojo_window',
      ],
    };
  }

  /// Get development dependencies
  List<String> getDevDependencies() {
    return [
      'flutter_test',
      'flutter_lints',
      'build_runner',
      'json_annotation',
      'json_serializable',
      'mockito',
      'fake_async',
      'test',
      'integration_test',
      'flutter_driver',
    ];
  }

  /// Get platform-specific compiler definitions
  Map<String, String> getCompilerDefinitions() {
    final platformInfo = _platformService.platformInfo;
    
    final definitions = <String, String>{
      'FLUTTER_COMPILED': 'true',
      'APP_VERSION': '1.0.0',
      'BUILD_NUMBER': '1',
      'ENVIRONMENT': kDebugMode ? 'development' : 'production',
    };

    if (platformInfo.isWeb) {
      definitions.addAll({
        'FLUTTER_WEB': 'true',
        'FLUTTER_WEB_USE_SKIA': 'true',
        'FLUTTER_WEB_AUTO_DETECT': 'true',
      });
    }

    if (platformInfo.platform == TargetPlatform.android) {
      definitions.addAll({
        'ANDROID_PLATFORM': 'true',
        'ENABLE_IMPELLER': 'true',
      });
    }

    if (platformInfo.platform == TargetPlatform.iOS) {
      definitions.addAll({
        'IOS_PLATFORM': 'true',
        'ENABLE_IMPELLER': 'true',
      });
    }

    return definitions;
  }

  /// Get build arguments for different platforms
  Map<String, List<String>> getBuildArguments() {
    final platformInfo = _platformService.platformInfo;
    
    final args = <String, List<String>>{};

    if (platformInfo.platform == TargetPlatform.android) {
      args['android'] = [
        '--split-debug-info=build/android-debug-info',
        '--obfuscate',
        '--enable-impeller',
        if (!kDebugMode) '--release',
        if (kDebugMode) '--debug',
      ];
    }

    if (platformInfo.platform == TargetPlatform.iOS) {
      args['ios'] = [
        '--split-debug-info=build/ios-debug-info',
        '--obfuscate',
        '--enable-impeller',
        if (!kDebugMode) '--release',
        if (kDebugMode) '--debug',
      ];
    }

    if (platformInfo.isWeb) {
      args['web'] = [
        '--web-renderer=canvaskit',
        '--split-debug-info=build/web-debug-info',
        '--source-maps',
        if (!kDebugMode) '--release',
        if (kDebugMode) '--debug',
      ];
    }

    return args;
  }

  /// Get platform-specific Gradle configurations for Android
  Map<String, dynamic> getAndroidGradleConfig() {
    return {
      'compileSdkVersion': 34,
      'minSdkVersion': 21,
      'targetSdkVersion': 34,
      'ndkVersion': '23.1.7779620',
      'javaVersion': '11',
      'kotlinVersion': '1.7.10',
      'gradleVersion': '7.5',
      'agpVersion': '7.3.0',
      'enableR8': !kDebugMode,
      'enableShrinkResources': !kDebugMode,
      'enableMinifyEnabled': !kDebugMode,
      'enableProguard': !kDebugMode,
      'multiDexEnabled': true,
      'buildToolsVersion': '34.0.0',
    };
  }

  /// Get iOS deployment configurations
  Map<String, dynamic> getiOSDeploymentConfig() {
    return {
      'iosDeploymentTarget': '12.0',
      'enableBitcode': false, // Disabled as per Apple's recommendation
      'enableModules': true,
      'enableSwiftVersion': '5.0',
      'enableObjectiveCBridgingHeader': true,
      'enableCocoaPods': true,
      'podVersion': '1.11.0',
      'xcodeVersion': '14.0',
      'enableAppTransportSecurity': false,
    };
  }

  /// Get web build configurations
  Map<String, dynamic> getWebBuildConfig() {
    return {
      'enableServiceWorker': !kDebugMode,
      'enableManifest': true,
      'enablePwa': !kDebugMode,
      'webRenderer': 'canvaskit',
      'enableSourceMaps': kDebugMode,
      'enableTreeShaking': !kDebugMode,
      'enableMinification': !kDebugMode,
      'enableCompression': !kDebugMode,
      'baseHref': '/',
    };
  }

  /// Get desktop build configurations
  Map<String, dynamic> getDesktopBuildConfig() {
    final platformInfo = _platformService.platformInfo;
    
    final config = <String, dynamic>{
      'enableAOT': !kDebugMode,
      'enableTreeShaking': !kDebugMode,
      'enableObfuscation': !kDebugMode,
    };

    if (platformInfo.platform == TargetPlatform.windows) {
      config.addAll({
        'enableMSVC': true,
        'enableUWP': false,
        'windowsVersion': '10.0.17763.0',
      });
    }

    if (platformInfo.platform == TargetPlatform.macOS) {
      config.addAll({
        'macOSDeploymentTarget': '10.14',
        'enableHardening': !kDebugMode,
        'enableSandbox': false,
      });
    }

    if (platformInfo.platform == TargetPlatform.linux) {
      config.addAll({
        'enableGTK': true,
        'gtkVersion': '3.0',
      });
    }

    return config;
  }

  /// Generate pubspec.yaml dependencies section
  String generatePubspecDependencies() {
    final dependencies = getRequiredDependencies();
    final platformInfo = _platformService.platformInfo;
    
    final buffer = StringBuffer();
    buffer.writeln('dependencies:');
    buffer.writeln('  flutter:');
    buffer.writeln('    sdk: flutter');
    buffer.writeln();
    
    // Add common dependencies
    for (final dep in dependencies['common']!) {
      if (dep != 'flutter') {
        buffer.writeln('  $dep: ^latest');
      }
    }
    
    // Add platform-specific dependencies
    if (platformInfo.isMobile) {
      buffer.writeln();
      buffer.writeln('  # Mobile-specific dependencies');
      for (final dep in dependencies['mobile']!) {
        buffer.writeln('  $dep: ^latest');
      }
    }
    
    if (platformInfo.platform == TargetPlatform.iOS) {
      buffer.writeln();
      buffer.writeln('  # iOS-specific dependencies');
      for (final dep in dependencies['ios']!) {
        buffer.writeln('  $dep: ^latest');
      }
    }
    
    if (platformInfo.platform == TargetPlatform.android) {
      buffer.writeln();
      buffer.writeln('  # Android-specific dependencies');
      for (final dep in dependencies['android']!) {
        buffer.writeln('  $dep: ^latest');
      }
    }
    
    if (platformInfo.isWeb) {
      buffer.writeln();
      buffer.writeln('  # Web-specific dependencies');
      for (final dep in dependencies['web']!) {
        buffer.writeln('  $dep: ^latest');
      }
    }
    
    if (platformInfo.isDesktop) {
      buffer.writeln();
      buffer.writeln('  # Desktop-specific dependencies');
      for (final dep in dependencies['desktop']!) {
        buffer.writeln('  $dep: ^latest');
      }
    }
    
    // Add dev dependencies
    buffer.writeln();
    buffer.writeln('dev_dependencies:');
    for (final dep in getDevDependencies()) {
      buffer.writeln('  $dep: ^latest');
    }
    
    return buffer.toString();
  }

  /// Generate Android build.gradle configurations
  String generateAndroidBuildGradle() {
    final config = getAndroidGradleConfig();
    
    return '''
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "\$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"
apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.google.firebase.crashlytics'

android {
    namespace 'com.example.zyraflow'
    compileSdkVersion ${config['compileSdkVersion']}
    ndkVersion "${config['ndkVersion']}"

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_${config['javaVersion'].toString().replaceAll('.', '_')}
        targetCompatibility JavaVersion.VERSION_${config['javaVersion'].toString().replaceAll('.', '_')}
    }

    kotlinOptions {
        jvmTarget = '${config['javaVersion']}'
    }

    defaultConfig {
        applicationId 'com.example.zyraflow'
        minSdkVersion ${config['minSdkVersion']}
        targetSdkVersion ${config['targetSdkVersion']}
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled ${config['multiDexEnabled']}
    }

    buildTypes {
        release {
            minifyEnabled ${config['enableMinifyEnabled']}
            shrinkResources ${config['enableShrinkResources']}
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.debug
        }
        debug {
            minifyEnabled false
            shrinkResources false
            debuggable true
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:\$kotlin_version"
    implementation 'androidx.multidex:multidex:2.0.1'
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-crashlytics'
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'
    implementation 'com.google.firebase:firebase-messaging'
}
''';
  }

  /// Generate iOS Info.plist configurations
  String generateiOSInfoPlist() {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleDisplayName</key>
	<string>Flow AI</string>
	<key>CFBundleExecutable</key>
	<string>\$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>Flow AI</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>\$(FLUTTER_BUILD_NAME)</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>\$(FLUTTER_BUILD_NUMBER)</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UILaunchStoryboardName</key>
	<string>LaunchScreen</string>
	<key>UIMainStoryboardFile</key>
	<string>Main</string>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UIViewControllerBasedStatusBarAppearance</key>
	<false/>
	
	<!-- Privacy Permissions -->
	<key>NSCameraUsageDescription</key>
	<string>This app needs camera access to capture cycle-related photos and documents.</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>This app needs photo library access to save and access cycle-related images.</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>This app uses location to provide localized health insights and reminders.</string>
	<key>NSContactsUsageDescription</key>
	<string>This app can access contacts to share cycle information with healthcare providers.</string>
	<key>NSCalendarsUsageDescription</key>
	<string>This app can add cycle events and reminders to your calendar.</string>
	<key>NSFaceIDUsageDescription</key>
	<string>This app uses Face ID for secure authentication and data protection.</string>
	<key>NSHealthShareUsageDescription</key>
	<string>This app can read health data to provide better cycle tracking insights.</string>
	<key>NSHealthUpdateUsageDescription</key>
	<string>This app can write cycle data to HealthKit for comprehensive health tracking.</string>
	
	<!-- Firebase and Authentication -->
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string>REVERSED_CLIENT_ID</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>\$(REVERSED_CLIENT_ID)</string>
			</array>
		</dict>
	</array>
	
	<!-- App Transport Security -->
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<false/>
		<key>NSExceptionDomains</key>
		<dict>
			<key>localhost</key>
			<dict>
				<key>NSExceptionAllowsInsecureHTTPLoads</key>
				<true/>
			</dict>
		</dict>
	</dict>
</dict>
</plist>
''';
  }

  /// Generate Android manifest configurations
  String generateAndroidManifest() {
    return '''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Network permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Device permissions -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.VIBRATE" />
    
    <!-- Biometric permissions -->
    <uses-permission android:name="android.permission.USE_FINGERPRINT" />
    <uses-permission android:name="android.permission.USE_BIOMETRIC" />
    
    <!-- Storage permissions -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                     android:maxSdkVersion="28" />
    
    <!-- Camera and media permissions -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    
    <!-- Location permissions -->
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    
    <!-- Calendar and contacts permissions -->
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.READ_CALENDAR" />
    <uses-permission android:name="android.permission.WRITE_CALENDAR" />
    
    <!-- Health permissions -->
    <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
    
    <!-- Notification permissions -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <application
        android:label="Flow AI"
        android:name="\${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:enableOnBackInvokedCallback="true"
        android:exported="true">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:orientation="portrait"
            android:screenOrientation="portrait"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <!-- Standard launch intent filter -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
            
            <!-- Deep link intent filters -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="https"
                      android:host="zyraflow.com" />
            </intent-filter>
        </activity>
        
        <!-- Firebase Messaging Service -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
        
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
            
        <meta-data 
            android:name="com.google.firebase.messaging.default_notification_icon" 
            android:resource="@drawable/ic_notification" />
            
        <meta-data 
            android:name="com.google.firebase.messaging.default_notification_color" 
            android:resource="@color/notification_color" />
            
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="default_notification_channel" />
    </application>
    
    <!-- Declare features -->
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
    <uses-feature android:name="android.hardware.location" android:required="false" />
    <uses-feature android:name="android.hardware.location.gps" android:required="false" />
    <uses-feature android:name="android.hardware.fingerprint" android:required="false" />
    <uses-feature android:name="android.hardware.biometrics" android:required="false" />
    
    <!-- Network security config -->
    <application android:networkSecurityConfig="@xml/network_security_config">
    </application>
</manifest>
''';
  }

  /// Generate build scripts for different platforms
  Map<String, String> generateBuildScripts() {
    final scripts = <String, String>{};
    
    // Android build script
    scripts['build_android.sh'] = '''
#!/bin/bash
set -e

echo "🤖 Building Android app..."

# Clean previous builds
flutter clean
flutter pub get

# Build APK for testing
flutter build apk --split-per-abi ${getBuildArguments()['android']?.join(' ') ?? ''}

# Build App Bundle for Play Store
flutter build appbundle ${getBuildArguments()['android']?.join(' ') ?? ''}

echo "✅ Android build completed"
''';

    // iOS build script
    scripts['build_ios.sh'] = '''
#!/bin/bash
set -e

echo "🍎 Building iOS app..."

# Clean previous builds
flutter clean
flutter pub get

# Update iOS dependencies
cd ios && pod install --repo-update && cd ..

# Build iOS app
flutter build ios ${getBuildArguments()['ios']?.join(' ') ?? ''}

echo "✅ iOS build completed"
''';

    // Web build script
    scripts['build_web.sh'] = '''
#!/bin/bash
set -e

echo "🌐 Building Web app..."

# Clean previous builds
flutter clean
flutter pub get

# Build web app
flutter build web ${getBuildArguments()['web']?.join(' ') ?? ''}

echo "✅ Web build completed"
''';

    // Universal build script
    scripts['build_all.sh'] = '''
#!/bin/bash
set -e

echo "🚀 Building for all platforms..."

# Clean and prepare
flutter clean
flutter pub get

# Build for each platform
if [[ "\$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building iOS..."
    ./scripts/build_ios.sh
fi

echo "🤖 Building Android..."
./scripts/build_android.sh

echo "🌐 Building Web..."
./scripts/build_web.sh

echo "✅ All platform builds completed"
''';

    return scripts;
  }

  /// Get Firebase configuration template
  Map<String, String> getFirebaseConfigTemplates() {
    return {
      'google-services.json': '''
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "YOUR_PROJECT_ID",
    "storage_bucket": "YOUR_PROJECT_ID.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_ANDROID_APP_ID",
        "android_client_info": {
          "package_name": "com.example.zyraflow"
        }
      },
      "oauth_client": [
        {
          "client_id": "YOUR_ANDROID_CLIENT_ID",
          "client_type": 1,
          "android_info": {
            "package_name": "com.example.zyraflow",
            "certificate_hash": "YOUR_SHA1_HASH"
          }
        }
      ],
      "api_key": [
        {
          "current_key": "YOUR_ANDROID_API_KEY"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
''',
      'GoogleService-Info.plist': '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>API_KEY</key>
	<string>YOUR_IOS_API_KEY</string>
	<key>GCM_SENDER_ID</key>
	<string>YOUR_SENDER_ID</string>
	<key>PLIST_VERSION</key>
	<string>1</string>
	<key>BUNDLE_ID</key>
	<string>com.example.zyraflow</string>
	<key>PROJECT_ID</key>
	<string>YOUR_PROJECT_ID</string>
	<key>STORAGE_BUCKET</key>
	<string>YOUR_PROJECT_ID.appspot.com</string>
	<key>IS_ADS_ENABLED</key>
	<false/>
	<key>IS_ANALYTICS_ENABLED</key>
	<true/>
	<key>IS_APPINVITE_ENABLED</key>
	<true/>
	<key>IS_GCM_ENABLED</key>
	<true/>
	<key>IS_SIGNIN_ENABLED</key>
	<true/>
	<key>GOOGLE_APP_ID</key>
	<string>YOUR_IOS_APP_ID</string>
</dict>
</plist>
''',
    };
  }

  /// Generate environment-specific configuration
  String generateEnvironmentConfig(String environment) {
    return '''
// Generated environment configuration for $environment
// This file is auto-generated by BuildConfig

const String ENVIRONMENT = '$environment';
const bool IS_PRODUCTION = ${environment == 'production'};
const bool IS_DEVELOPMENT = ${environment == 'development'};
const bool IS_STAGING = ${environment == 'staging'};

// API Configuration
const String API_BASE_URL = IS_PRODUCTION 
    ? 'https://api.zyraflow.com'
    : IS_STAGING
        ? 'https://staging-api.zyraflow.com'
        : 'http://localhost:3000/api';

// Feature Flags
const Map<String, bool> FEATURE_FLAGS = {
  'enableAnalytics': IS_PRODUCTION,
  'enableCrashReporting': IS_PRODUCTION,
  'enablePerformanceMonitoring': IS_PRODUCTION,
  'enableDebugLogging': IS_DEVELOPMENT,
  'enableTestMode': IS_DEVELOPMENT,
  'enableMockData': IS_DEVELOPMENT,
};

// Build Information
const String BUILD_TIMESTAMP = '${DateTime.now().toIso8601String()}';
const String BUILD_ENVIRONMENT = ENVIRONMENT;
''';
  }
}

/// Build utilities for fixing common platform issues
class BuildUtilities {
  static final PlatformService _platformService = PlatformService();
  
  /// Fix common iOS build issues
  static List<String> getiOSBuildFixes() {
    return [
      'Update CocoaPods: pod repo update && pod install',
      'Clean iOS build: rm -rf ios/Pods ios/Podfile.lock && pod install',
      'Fix signing issues: Check bundle identifier and provisioning profiles',
      'Update iOS deployment target to 12.0 minimum',
      'Enable Impeller renderer: --enable-impeller',
      'Disable Bitcode if causing issues',
      'Check Xcode version compatibility (14.0+)',
      'Verify Firebase configuration files are present',
    ];
  }
  
  /// Fix common Android build issues
  static List<String> getAndroidBuildFixes() {
    return [
      'Update Android SDK and build tools',
      'Clean Android build: flutter clean && flutter pub get',
      'Update Gradle wrapper: gradle wrapper --gradle-version 7.5',
      'Fix MultiDex issues: Enable multiDexEnabled true',
      'Update compile SDK version to 34',
      'Fix R8/ProGuard issues: Add keep rules',
      'Update Kotlin version to 1.7.10+',
      'Check Android permissions in manifest',
      'Verify Firebase configuration files are present',
    ];
  }
  
  /// Fix common web build issues
  static List<String> getWebBuildFixes() {
    return [
      'Use CanvasKit renderer: --web-renderer=canvaskit',
      'Fix CORS issues: Configure web server properly',
      'Update web dependencies: firebase_auth_web, etc.',
      'Fix service worker issues: Check manifest.json',
      'Enable source maps for debugging',
      'Fix Firebase web configuration',
      'Check base href configuration',
      'Optimize bundle size: Enable tree shaking',
    ];
  }
  
  /// Fix common desktop build issues
  static List<String> getDesktopBuildFixes() {
    return [
      'Update desktop dependencies',
      'Fix CMake configuration for Windows/Linux',
      'Update macOS deployment target',
      'Fix signing issues on macOS',
      'Enable desktop support: flutter config --enable-windows/macos/linux-desktop',
      'Check native dependencies',
      'Fix library linking issues',
      'Update platform-specific configurations',
    ];
  }
}
