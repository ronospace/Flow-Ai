import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/setup_screen.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/cycle/screens/home_screen.dart';
import '../../features/cycle/screens/calendar_screen.dart';
import '../../features/cycle/screens/tracking_screen.dart';
// Deferred (lazy) imports for heavy features
import '../../features/insights/screens/insights_screen.dart' deferred as insights;
import '../../features/insights/screens/ai_coach_screen.dart' deferred as aicoach;
import '../../features/insights/screens/faq_browser_screen.dart';
import '../../features/health/screens/health_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/feedback/screens/feedback_screen.dart';
import '../../features/future_plans/screens/future_plans_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    // Handle navigation and back button behavior
    redirect: (context, state) {
      // Allow proper back navigation by not forcing redirects
      return null;
    },
    routes: [
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
      
      // Authentication Route
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
            builder: (context, state) => const CalendarScreen(), // Use calendar as cycle overview
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

  const DeferredRouteBuilder({super.key, required this.loadLibrary, required this.builder});

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

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }
  
  @override
  void dispose() {
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
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/calendar');
        break;
      case 2:
        context.go('/tracking');
        break;
      case 3:
        context.go('/insights');
        break;
      case 4:
        context.go('/health');
        break;
      case 5:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        body: widget.child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 80,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Home'),
                  _buildNavItem(1, Icons.calendar_month_rounded, 'Calendar'),
                  _buildNavItem(2, Icons.add_circle_rounded, 'Track'),
                  _buildNavItem(3, Icons.insights_rounded, 'Insights'),
                  _buildNavItem(4, Icons.favorite_rounded, 'Health'),
                  _buildNavItem(5, Icons.settings_rounded, 'Settings'),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => _onNavigationTap(index),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFF9B59B6)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : theme.iconTheme.color?.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF6B9D) : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
