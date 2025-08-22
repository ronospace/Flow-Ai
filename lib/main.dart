import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/app_localizations.dart';

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
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/cycle/providers/cycle_provider.dart';
import 'features/insights/providers/insights_provider.dart';
import 'features/health/providers/health_provider.dart';
import 'features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize only critical services synchronously
  await _initializeCriticalServices();
  
  runApp(const CycleAIApp());
  
  // Initialize non-critical services asynchronously after app launch
  _initializeNonCriticalServices();
}

Future<void> _initializeCriticalServices() async {
  ImageCacheConfig.configure();
  
  // Initialize app state service which coordinates auth and preferences
  try {
    await AppStateService().initialize();
    debugPrint('✅ App State Service initialized');
  } catch (e) {
    debugPrint('⚠️ App State Service initialization failed: $e');
  }
  
  // System UI overlay style will be set dynamically based on theme
  // This is now handled in the MaterialApp theme configuration
}

Future<void> _initializeNonCriticalServices() async {
  // Defer heavy initializations to not block app startup
  await Future.delayed(const Duration(milliseconds: 50));
  
  // Initialize services in parallel with optimized batching for faster startup
  await Future.wait([
    _initializeAdMob(),
    _initializeAI(),
    _initializeNotifications(),
    _initializeNavigation(),
    _initializeAuth(),
    _initializeLocalUserService(),
    _initializeAIMemory(),
    _initializeOfflineService(),
  ]);
}

Future<void> _initializeAdMob() async {
  try {
    await AdMobService.initialize();
    final adMobService = AdMobService();
    // Load ads without blocking - fire and forget
    adMobService.loadInterstitialAd();
    adMobService.loadRewardedAd();
  } catch (e) {
    debugPrint('AdMob initialization failed: $e');
  }
}

Future<void> _initializeAI() async {
  try {
    await AIEngine.instance.initialize();
  } catch (e) {
    debugPrint('AI Engine initialization failed: $e');
  }
}

Future<void> _initializeNotifications() async {
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('Notification Service initialization failed: $e');
  }
}

Future<void> _initializeNavigation() async {
  try {
    await NavigationService().initialize();
    debugPrint('✅ Navigation Service initialized');
  } catch (e) {
    debugPrint('Navigation Service initialization failed: $e');
  }
}

// Auth is now initialized by AppStateService
Future<void> _initializeAuth() async {
  // Skip this since it's already handled by AppStateService
  debugPrint('🔐 Authentication Service already initialized via AppStateService');
}

Future<void> _initializeLocalUserService() async {
  try {
    await LocalUserService().initialize();
    debugPrint('👤 Local User Service initialized');
  } catch (e) {
    debugPrint('Local User Service initialization failed: $e');
  }
}

Future<void> _initializeAIMemory() async {
  try {
    await AIConversationMemory().initialize();
    debugPrint('🧠 AI Conversation Memory initialized');
  } catch (e) {
    debugPrint('AI Conversation Memory initialization failed: $e');
  }
}

Future<void> _initializeOfflineService() async {
  try {
    await OfflineService().initialize();
    debugPrint('🔄 Offline Service initialized');
  } catch (e) {
    debugPrint('Offline Service initialization failed: $e');
  }
}

// Helper function to avoid awaiting futures we don't need to wait for
void unawaited(Future<void> future) {}

class CycleAIApp extends StatefulWidget {
  const CycleAIApp({super.key});

  @override
  State<CycleAIApp> createState() => _CycleAIAppState();
}

class _CycleAIAppState extends State<CycleAIApp> {
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
          
          return MaterialApp.router(
            title: 'CycleAI',
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
        },
      ),
    );
  }
}
