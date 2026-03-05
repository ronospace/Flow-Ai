class PendingDeepLinkService {
  static String? _pendingRoute;

  static void setPendingRoute(String route) {
    _pendingRoute = route;
  }

  static String? consumePendingRoute() {
    final r = _pendingRoute;
    _pendingRoute = null;
    return r;
  }

  static String? peekPendingRoute() => _pendingRoute;

  static void clear() {
    _pendingRoute = null;
  }

  // Compatibility aliases (older call sites)
  static String? getPendingRoute() => peekPendingRoute();

  static void clearPendingRoute() => clear();

}
