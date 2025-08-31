import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'generated/app_localizations.dart';
import 'core/utils/app_logger.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/image_cache_config.dart';
import 'core/routing/app_router.dart';
import 'core/services/ai_engine.dart';
import 'core/services/notification_service.dart';
import 'core/services/admob_service.dart';
import 'core/services/navigation_service.dart';
import 'core/services/ai_conversation_memory.dart';
import 'core/services/offline_service.dart';
import 'core/services/app_state_service.dart';
import 'core/services/local_user_service.dart';
import 'core/services/memory_manager.dart';
import 'core/services/platform_service.dart';
import 'core/config/platform_config.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/cycle/providers/cycle_provider.dart';
import 'features/insights/providers/insights_provider.dart';
import 'features/health/providers/health_provider.dart';
import 'features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure Flutter for production performance
  if (kReleaseMode) {
    // Disable debug banner and optimize for production
    debugPrint = (String? message, {int? wrapWidth}) {}; // Disable debug prints in release
  }
  
  // Initialize only critical services synchronously
  await _initializeCriticalServices();
  
  runApp(const FlowAIApp());
  
  // Initialize non-critical services asynchronously after app launch
  _initializeNonCriticalServices();
}

Future<void> _initializeCriticalServices() async {
  // Initialize platform service first - required for cross-platform features
  try {
    await PlatformService().initialize();
    AppLogger.success('Platform Service initialized successfully');
    
    // Initialize platform-specific configurations
    await PlatformConfig().initialize();
    AppLogger.success('Platform Configurations initialized successfully');
  } catch (e) {
    AppLogger.error('Platform Service initialization failed: $e');
  }
  
  // Initialize Firebase with platform-specific configurations
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.success('Firebase initialized successfully');
  } catch (e) {
    AppLogger.warning('Firebase initialization failed: $e');
  }
  
  ImageCacheConfig.configure();
  
  // Initialize app state service which coordinates auth and preferences
  try {
    await AppStateService().initialize();
    AppLogger.success('App State Service initialized');
  } catch (e) {
    AppLogger.warning('App State Service initialization failed: $e');
  }
  
  // Note: System UI configuration is now handled by the PlatformService
}

Future<void> _initializeNonCriticalServices() async {
  // Defer heavy initializations to not block app startup
  await Future.delayed(const Duration(milliseconds: 100));
  
  // Initialize services in parallel with optimized batching for faster startup
  await Future.wait([
    _initializeMemoryManager(),
    _initializeAdMob(),
    _initializeAI(),
    _initializeNotifications(),
    _initializeNavigation(),
    _initializeAuth(),
    _initializeLocalUserService(),
    _initializeAIMemory(),
    _initializeOfflineService(),
  ], eagerError: false); // Don't fail all services if one fails
}

Future<void> _initializeAdMob() async {
  try {
    await AdMobService.initialize();
    final adMobService = AdMobService();
    // Load ads without blocking - fire and forget
    adMobService.loadInterstitialAd();
    adMobService.loadRewardedAd();
    AppLogger.success('AdMob initialized successfully');
  } catch (e) {
    AppLogger.warning('AdMob initialization failed: $e');
  }
}

Future<void> _initializeAI() async {
  try {
    await AIEngine.instance.initialize();
    AppLogger.ai('Enhanced AI Engine initialized');
  } catch (e) {
    AppLogger.warning('AI Engine initialization failed: $e');
  }
}

Future<void> _initializeNotifications() async {
  try {
    await NotificationService.instance.initialize();
    AppLogger.notification('Notification Service initialized');
  } catch (e) {
    AppLogger.warning('Notification Service initialization failed: $e');
  }
}

Future<void> _initializeNavigation() async {
  try {
    await NavigationService().initialize();
    AppLogger.navigation('Navigation Service initialized');
  } catch (e) {
    AppLogger.warning('Navigation Service initialization failed: $e');
  }
}

// Auth is now initialized by AppStateService
Future<void> _initializeAuth() async {
  // Skip this since it's already handled by AppStateService
  AppLogger.auth('Authentication Service already initialized via AppStateService');
}

Future<void> _initializeLocalUserService() async {
  try {
    await LocalUserService().initialize();
    AppLogger.success('Local User Service initialized');
  } catch (e) {
    AppLogger.warning('Local User Service initialization failed: $e');
  }
}

Future<void> _initializeAIMemory() async {
  try {
    await AIConversationMemory().initialize();
    AppLogger.ai('AI Conversation Memory initialized');
  } catch (e) {
    AppLogger.warning('AI Conversation Memory initialization failed: $e');
  }
}

Future<void> _initializeOfflineService() async {
  try {
    await OfflineService().initialize();
    AppLogger.sync('Offline Service initialized');
  } catch (e) {
    AppLogger.warning('Offline Service initialization failed: $e');
  }
}

Future<void> _initializeMemoryManager() async {
  try {
    await MemoryManager().initialize();
    await MemoryManager().enablePerformanceOptimizations();
    AppLogger.memory('Memory Manager initialized with performance optimizations');
  } catch (e) {
    AppLogger.warning('Memory Manager initialization failed: $e');
  }
}

// Helper function to avoid awaiting futures we don't need to wait for
void unawaited(Future<void> future) {}

class FlowAIApp extends StatefulWidget {
  const FlowAIApp({super.key});

  @override
  State<FlowAIApp> createState() => _FlowAIAppState();
}

class _FlowAIAppState extends State<FlowAIApp> {
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    super.initState();
    settingsProvider = SettingsProvider();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    await settingsProvider.initializeSettings();
    if (mounted) {
      setState(() {
        // Settings initialized
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider(create: (_) => InsightsProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          // Update system UI overlay style based on theme
          final isDark = settings.themeMode == ThemeMode.dark ||
              (settings.themeMode == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);
          
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
              systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            ),
          );
          
          final platformInfo = PlatformService().platformInfo;
          
          // Use CupertinoApp for iOS devices
          if (platformInfo.platform == TargetPlatform.iOS && platformInfo.isMobile) {
            return CupertinoApp.router(
              title: 'Flow Ai',
              debugShowCheckedModeBanner: false,
              theme: CupertinoThemeData(
                brightness: settings.themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
                primaryColor: AppTheme.primaryRose,
                scaffoldBackgroundColor: settings.themeMode == ThemeMode.dark 
                    ? AppTheme.darkBackground 
                    : AppTheme.lightBackground,
              ),
              locale: settings.locale,
              routerConfig: AppRouter.router,
              // Internationalization support
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              // Core 12 languages for global market reach (~4.5B people)
              supportedLocales: const [
                Locale('en'), // English → Global default, US, UK, Africa, India, SEA
                Locale('es'), // Spanish → Latin America, Spain, US Hispanic community
                Locale('fr'), // French → France, Canada (Quebec), Africa (West & Central)
                Locale('pt'), // Portuguese (Brazilian) → Brazil, Portugal
                Locale('de'), // German → Germany, Austria, Switzerland
                Locale('it'), // Italian → Italy + diaspora
                Locale('ar'), // Arabic (MSA) → Middle East, North Africa
                Locale('hi'), // Hindi → India
                Locale('zh'), // Chinese (Simplified) → Mainland China, Singapore
                Locale('ja'), // Japanese → Japan
                Locale('ko'), // Korean → South Korea
                Locale('ru'), // Russian → Eastern Europe, Central Asia
              ],
            ).animate().fadeIn(duration: 800.ms);
          } else {
            // Use MaterialApp for Android, web, and desktop platforms
            return MaterialApp.router(
              title: 'Flow Ai',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme.copyWith(
                scaffoldBackgroundColor: AppTheme.lightBackground,
              ),
              darkTheme: AppTheme.darkTheme.copyWith(
                scaffoldBackgroundColor: AppTheme.darkBackground,
              ),
              themeMode: settings.themeMode,
              locale: settings.locale,
              routerConfig: AppRouter.router,
              // Internationalization support
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              // Core 12 languages for global market reach (~4.5B people)
              supportedLocales: const [
                Locale('en'), // English → Global default, US, UK, Africa, India, SEA
                Locale('es'), // Spanish → Latin America, Spain, US Hispanic community
                Locale('fr'), // French → France, Canada (Quebec), Africa (West & Central)
                Locale('pt'), // Portuguese (Brazilian) → Brazil, Portugal
                Locale('de'), // German → Germany, Austria, Switzerland
                Locale('it'), // Italian → Italy + diaspora
                Locale('ar'), // Arabic (MSA) → Middle East, North Africa
                Locale('hi'), // Hindi → India
                Locale('zh'), // Chinese (Simplified) → Mainland China, Singapore
                Locale('ja'), // Japanese → Japan
                Locale('ko'), // Korean → South Korea
                Locale('ru'), // Russian → Eastern Europe, Central Asia
              ],
          ).animate().fadeIn(duration: 800.ms);
          }
        },
      ),
    );
  }
}
