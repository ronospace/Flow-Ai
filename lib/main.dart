import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/services/ai_engine.dart';
import 'core/services/notification_service.dart';
import 'core/services/admob_service.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/cycle/providers/cycle_provider.dart';
import 'features/insights/providers/insights_provider.dart';
import 'features/health/providers/health_provider.dart';
import 'features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services
  await _initializeServices();
  
  runApp(FlowSenseApp());
}

Future<void> _initializeServices() async {
  // Initialize AdMob
  await AdMobService.initialize();
  
  // Initialize AI Engine
  await AIEngine.instance.initialize();
  
  // Initialize Notification Service
  await NotificationService.instance.initialize();
  
  // Initialize AdMob ads
  final adMobService = AdMobService();
  adMobService.loadInterstitialAd();
  adMobService.loadRewardedAd();
  
  // System UI overlay style will be set dynamically based on theme
  // This is now handled in the MaterialApp theme configuration
}

class FlowSenseApp extends StatefulWidget {
  const FlowSenseApp({super.key});

  @override
  State<FlowSenseApp> createState() => _FlowSenseAppState();
}

class _FlowSenseAppState extends State<FlowSenseApp> {
  late SettingsProvider settingsProvider;
  bool _isInitialized = false;

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
        _isInitialized = true;
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
            title: 'FlowSense',
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
