import '../../features/auth/screens/app_lock_screen.dart';
import '../services/auth_service.dart';
import '../services/app_lock_service.dart';
import 'package:flow_ai/features/partner/screens/qr_join_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/admob_service.dart';
import '../services/ad_consent_service.dart';
import '../identity/active_account_scope.dart';
import '../../features/premium/providers/subscription_provider.dart';
import '../constants/app_layout.dart';

import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/setup_screen.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/screens/auth_choice_screen.dart';
import '../../features/cycle/screens/home_screen.dart';
import '../../features/cycle/screens/cycle_predictions_screen.dart';
import '../../features/cycle/screens/calendar_screen.dart';
import '../../features/cycle/screens/tracking_screen.dart';
// Deferred (lazy) imports for heavy features
import '../../features/insights/screens/insights_screen.dart'
    deferred as insights;
import '../../features/insights/screens/ai_coach_screen.dart'
    deferred as aicoach;
import '../../features/insights/screens/faq_browser_screen.dart';
import '../../features/health/screens/health_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/partner/screens/partner_dashboard_screen.dart';
import '../../features/feedback/screens/feedback_screen.dart';
import '../../features/future_plans/screens/future_plans_screen.dart';
import '../../features/premium/screens/premium_paywall_screen.dart';
import 'package:flow_ai/core/deeplinks/invite_gate_page.dart';
import 'package:flow_ai/core/deeplinks/deep_link_normalizer.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    // Handle navigation and back button behavior
    redirect: (context, state) async {
      final uri = state.uri;
      if (uri.scheme == 'flowai') {
        return DeepLinkNormalizer.normalizeToAppPath(uri.toString());
      }

      final path = uri.path;
      const publicPaths = {
        '/splash',
        '/onboarding',
        '/setup',
        '/auth/choice',
        '/auth/login',
        '/auth/signup',
        '/auth',
      };

      final isPublic =
          publicPaths.contains(path) ||
          path == '/qr-join' ||
          path.startsWith('/invite/');

      final auth = AuthService();
      if (!auth.isInitialized) {
        await auth.initialize();
      }

      final authenticated = await auth.isAuthenticated;
      final appLock = AppLockService();

      if (!authenticated) {
        if (path == '/auth/lock' || !isPublic) {
          return '/auth/choice';
        }
        return null;
      }

      if (path == '/auth/login' && await appLock.shouldRequireLock()) {
        return null;
      }

      if (path == '/auth/choice') {
        return await appLock.shouldRequireLock() ? '/auth/lock' : '/home';
      }

      if (path == '/auth/lock') {
        if (!auth.isBiometricEnabled()) {
          appLock.markUnlocked();
          return '/home';
        }
        return null;
      }

      if (path.startsWith('/auth')) {
        return await appLock.shouldRequireLock() ? '/auth/lock' : '/home';
      }

      if (!isPublic && await appLock.shouldRequireLock()) {
        return '/auth/lock';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/predictions',
        builder: (context, state) => const CyclePredictionsScreen(),
      ),

      GoRoute(
        path: '/qr-join',
        builder: (context, state) => const QrJoinScreen(),
      ),

      GoRoute(
        path: '/invite/:code',
        builder: (context, state) {
          final code = state.pathParameters['code'] ?? '';
          return InviteGatePage(code: code);
        },
      ),

      // Onboarding Routes
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/setup',
        name: 'setup',
        builder: (context, state) => const SetupScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/auth/lock',
        name: 'auth-lock',
        builder: (context, state) => const AppLockScreen(),
      ),
      GoRoute(
        path: '/auth/choice',
        name: 'auth-choice',
        builder: (context, state) => const AuthChoiceScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'auth-login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        name: 'auth-signup',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // Main App Routes with Shell Navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/calendar',
            name: 'calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/tracking',
            name: 'tracking',
            builder: (context, state) => const TrackingScreen(),
          ),
          GoRoute(
            path: '/insights',
            name: 'insights',
            builder: (context, state) => DeferredRouteBuilder(
              loadLibrary: insights.loadLibrary,
              builder: (_) => insights.InsightsScreen(),
            ),
          ),
          GoRoute(
            path: '/cycle',
            name: 'cycle',
            builder: (context, state) =>
                const CalendarScreen(), // Use calendar as cycle overview
          ),
          GoRoute(
            path: '/health',
            name: 'health',
            builder: (context, state) => const HealthScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/partner-dashboard',
            name: 'partner-dashboard',
            builder: (context, state) => const PartnerDashboardScreen(),
          ),
          GoRoute(
            path: '/faq',
            name: 'faq',
            builder: (context, state) => const FAQBrowserScreen(),
          ),
        ],
      ),

      // AI Coach Modal Route
      GoRoute(
        path: '/ai-coach',
        name: 'ai-coach',
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: DeferredRouteBuilder(
            loadLibrary: aicoach.loadLibrary,
            builder: (_) => aicoach.AICoachScreen(),
          ),
        ),
      ),

      GoRoute(
        path: '/premium',
        name: 'premium',
        builder: (context, state) => const PremiumPaywallScreen(),
      ),
      GoRoute(
        path: '/premium/paywall',
        name: 'premium-paywall',
        builder: (context, state) => const PremiumPaywallScreen(),
      ),

      // Feedback and Future Plans Routes
      GoRoute(
        path: '/feedback',
        name: 'feedback',
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: '/future-plans',
        name: 'future-plans',
        builder: (context, state) => const FuturePlansScreen(),
      ),
    ],
  );
}

/// Helper widget to load deferred libraries before building the route
class DeferredRouteBuilder extends StatefulWidget {
  final Future<void> Function() loadLibrary;
  final WidgetBuilder builder;

  const DeferredRouteBuilder({
    super.key,
    required this.loadLibrary,
    required this.builder,
  });

  @override
  State<DeferredRouteBuilder> createState() => _DeferredRouteBuilderState();
}

class _DeferredRouteBuilderState extends State<DeferredRouteBuilder> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = widget.loadLibrary();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.builder(context);
      },
    );
  }
}

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late ScrollController _scrollController;
  BannerAd? _mainShellBannerAd;
  bool _bannerLoadInFlight = false;
  int _bannerLoadGeneration = 0;
  bool _subscriptionSyncInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    AdMobService.readinessRevision.addListener(_onAdReadinessChanged);
    AdConsentService.instance.addListener(_onAdReadinessChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final appLock = AppLockService();

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        appLock.recordBackgrounded();
        return;

      case AppLifecycleState.detached:
        // A detached app/process cannot retain an unlocked UI session.
        appLock.lock();
        return;

      case AppLifecycleState.resumed:
        // Resuming from temporary system UI must not automatically force
        // biometric re-authentication. A time-based background lock policy
        // must be explicitly defined before it is enforced.
        appLock.recordResumed();
        return;

      case AppLifecycleState.inactive:
        // Permission sheets, biometric UI and platform transitions can make
        // the app inactive briefly. This is not itself a security boundary.
        return;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AdMobService.readinessRevision.removeListener(_onAdReadinessChanged);
    AdConsentService.instance.removeListener(_onAdReadinessChanged);
    _bannerLoadGeneration++;
    _bannerLoadInFlight = false;
    _mainShellBannerAd?.dispose();
    _mainShellBannerAd = null;
    _scrollController.dispose();
    super.dispose();
  }

  void _updateCurrentIndex() {
    final currentRoute = GoRouterState.of(context).fullPath;
    switch (currentRoute) {
      case '/home':
        _currentIndex = 0;
        break;
      case '/calendar':
        _currentIndex = 1;
        break;
      case '/tracking':
        _currentIndex = 2;
        break;
      case '/insights':
        _currentIndex = 3;
        break;
      case '/health':
        _currentIndex = 4;
        break;
      case '/settings':
        _currentIndex = 5;
        break;
      default:
        _currentIndex = 0;
    }
  }

  void _onNavigationTap(int index) {
    final fromRoute = GoRouterState.of(context).uri.path;

    final toRoute = switch (index) {
      0 => '/home',
      1 => '/calendar',
      2 => '/tracking',
      3 => '/insights',
      4 => '/health',
      5 => '/settings',
      _ => '/home',
    };

    setState(() {
      _currentIndex = index;
    });

    context.go(toRoute);

    if (fromRoute == '/insights' && toRoute == '/home') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        AdMobService().showInterstitialAdWithFrequency(
          fromRoute: fromRoute,
          toRoute: toRoute,
        );
      });
    }
  }

  void _onAdReadinessChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _syncSubscriptionForActiveAccount() async {
    if (_subscriptionSyncInFlight || !mounted) return;

    _subscriptionSyncInFlight = true;
    try {
      final userId = await ActiveAccountScope.instance.requireUserId();
      if (!mounted) return;

      final subscription = context.read<SubscriptionProvider>();
      if (!subscription.isInitialized ||
          subscription.initializedUserId != userId) {
        await subscription.initialize(userId);
      }
    } on StateError {
      return;
    } finally {
      _subscriptionSyncInFlight = false;
    }
  }

  void _syncBanner(bool entitlementResolved, bool isPremium, String route) {
    final allowed =
        entitlementResolved &&
        !isPremium &&
        AdMobService.canShowBannerOnRoute(route);

    if (!allowed) {
      _bannerLoadGeneration++;
      _mainShellBannerAd?.dispose();
      _mainShellBannerAd = null;
      _bannerLoadInFlight = false;
      return;
    }

    if (_mainShellBannerAd != null || _bannerLoadInFlight) return;

    _bannerLoadInFlight = true;
    final generation = ++_bannerLoadGeneration;

    final ad = AdMobService().createBannerAd(
      onLoaded: (loadedAd) {
        if (!mounted || generation != _bannerLoadGeneration) {
          loadedAd.dispose();
          return;
        }

        final currentSubscription = context.read<SubscriptionProvider>();
        final currentRoute = GoRouterState.of(context).uri.path;

        final stillAllowed =
            AdMobService.canLoadAds &&
            currentSubscription.isInitialized &&
            !currentSubscription.isPremium &&
            AdMobService.canShowBannerOnRoute(currentRoute);

        if (!stillAllowed) {
          loadedAd.dispose();
          setState(() {
            _bannerLoadInFlight = false;
            _mainShellBannerAd = null;
          });
          return;
        }

        setState(() {
          _bannerLoadInFlight = false;
          _mainShellBannerAd = loadedAd;
        });
      },
      onFailedToLoad: (_) {
        if (!mounted || generation != _bannerLoadGeneration) return;

        setState(() {
          _bannerLoadInFlight = false;
          _mainShellBannerAd = null;
        });
      },
    );
    ad.load();
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncSubscriptionForActiveAccount();
      _syncBanner(
        subscription.isInitialized,
        subscription.isPremium,
        GoRouterState.of(context).uri.path,
      );
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Handle back navigation properly
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
        } else {
          // If can't pop, exit the app or go to a safe route
          // This prevents the infinite redirect loop
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: false,
        body: Column(
          children: [
            Expanded(child: widget.child),
            if (_mainShellBannerAd != null &&
                AdMobService.canShowBannerOnRoute(
                  GoRouterState.of(context).uri.path,
                ))
              SizedBox(
                width: _mainShellBannerAd!.size.width.toDouble(),
                height: _mainShellBannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _mainShellBannerAd!),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.98),
            height: AppLayout.bottomNavigationHeight,
            child: Row(
              children: [
                Expanded(child: _buildNavItem(0, Icons.home_rounded, 'Home')),
                Expanded(
                  child: _buildNavItem(
                    1,
                    Icons.calendar_month_rounded,
                    'Calendar',
                  ),
                ),
                Expanded(
                  child: _buildNavItem(2, Icons.add_circle_rounded, 'Track'),
                ),
                Expanded(
                  child: _buildNavItem(3, Icons.insights_rounded, 'Insights'),
                ),
                Expanded(
                  child: _buildNavItem(4, Icons.favorite_rounded, 'Health'),
                ),
                Expanded(
                  child: _buildNavItem(5, Icons.settings_rounded, 'Settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final theme = Theme.of(context);
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onNavigationTap(index),
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(index == 4 ? 4 : 6),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFFF6B9D), Color(0xFF9B59B6)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(index == 4 ? 10 : 12),
                ),
                child: Transform.translate(
                  offset: index == 4 ? const Offset(0, -2) : Offset.zero,
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : theme.iconTheme.color?.withValues(alpha: 0.6),
                    size: index == 4 ? 21 : 24,
                  ),
                ),
              ),
              SizedBox(height: index == 4 ? 2 : 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFFF6B9D)
                      : theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.6,
                        ),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
