import 'dart:async';
import 'dart:developer' as developer;

import 'package:go_router/go_router.dart';

import '../services/production_analytics_service.dart';

class RuntimeNavigationTelemetry {
  RuntimeNavigationTelemetry._();

  static final RuntimeNavigationTelemetry instance =
      RuntimeNavigationTelemetry._();

  GoRouter? _router;
  String? _lastPath;

  void attach(GoRouter router) {
    if (identical(_router, router)) return;

    detach();
    _router = router;
    router.routerDelegate.addListener(_onRouteChanged);
    _recordCurrentRoute(source: 'attach');
  }

  void detach() {
    final router = _router;
    if (router != null) {
      router.routerDelegate.removeListener(_onRouteChanged);
    }
    _router = null;
    _lastPath = null;
  }

  void _onRouteChanged() {
    _recordCurrentRoute(source: 'delegate');
  }

  void _recordCurrentRoute({required String source}) {
    final router = _router;
    if (router == null) return;

    final path = router.routerDelegate.currentConfiguration.uri.path;
    if (path.isEmpty || path == _lastPath) return;

    final previous = _lastPath;
    _lastPath = path;

    developer.log(
      'NAV source=$source route=$path'
      '${previous == null ? '' : ' previous=$previous'}',
      name: 'FLOW_RUNTIME',
    );

    final analytics = ProductionAnalyticsService();

    unawaited(analytics.trackScreenView(path));
    unawaited(
      analytics.recordNavigationDiagnostic(path: path, previousPath: previous),
    );
  }
}
