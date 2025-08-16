import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

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
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
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
          return MaterialApp.router(
            title: 'FlowSense',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
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
            supportedLocales: const [
              Locale('en'), // English
              Locale('es'), // Spanish
              Locale('fr'), // French
              Locale('de'), // German
              Locale('it'), // Italian
              Locale('pt'), // Portuguese
              Locale('ru'), // Russian
              Locale('ja'), // Japanese
              Locale('ko'), // Korean
              Locale('zh'), // Chinese
              Locale('ar'), // Arabic
              Locale('hi'), // Hindi
              Locale('bn'), // Bengali
              Locale('tr'), // Turkish
              Locale('vi'), // Vietnamese
              Locale('th'), // Thai
              Locale('pl'), // Polish
              Locale('nl'), // Dutch
              Locale('sv'), // Swedish
              Locale('da'), // Danish
              Locale('no'), // Norwegian
              Locale('fi'), // Finnish
              Locale('he'), // Hebrew
              Locale('cs'), // Czech
              Locale('hu'), // Hungarian
              Locale('uk'), // Ukrainian
              Locale('el'), // Greek
              Locale('bg'), // Bulgarian
              Locale('ro'), // Romanian
              Locale('hr'), // Croatian
              Locale('sk'), // Slovak
              Locale('sl'), // Slovenian
              Locale('lt'), // Lithuanian
              Locale('lv'), // Latvian
              Locale('et'), // Estonian
              Locale('mt'), // Maltese
              Locale('is'), // Icelandic
              Locale('ga'), // Irish
              Locale('cy'), // Welsh
            ],
          ).animate().fadeIn(duration: 800.ms);
        },
      ),
    );
  }
}
