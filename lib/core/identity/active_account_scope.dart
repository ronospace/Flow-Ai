typedef ActiveAccountIdResolver = Future<String?> Function();

/// Platform-neutral ownership boundary for persisted private data.
///
/// The canonical live identity resolver is provided by the composition root.
/// User IDs are resolved on every operation and are never cached.
final class ActiveAccountScope {
  ActiveAccountScope._();

  static final ActiveAccountScope instance = ActiveAccountScope._();

  ActiveAccountIdResolver? _resolver;

  static const Set<String> _forbiddenIdentifiers = <String>{
    'current_user',
    'unknown',
    'anonymous_user',
  };

  void configure(ActiveAccountIdResolver resolver) {
    _resolver = resolver;
  }

  Future<String> requireUserId() async {
    final resolver = _resolver;

    if (resolver == null) {
      throw StateError(
        'Active account identity is not configured for persisted private data.',
      );
    }

    final resolved = (await resolver())?.trim();

    if (resolved == null ||
        resolved.isEmpty ||
        _forbiddenIdentifiers.contains(resolved)) {
      throw StateError(
        'A verified account identifier is required for persisted private data.',
      );
    }

    return resolved;
  }

  Future<void> requireOwnership(String claimedUserId) async {
    final activeUserId = await requireUserId();
    final claimed = claimedUserId.trim();

    if (claimed.isEmpty || claimed != activeUserId) {
      throw StateError(
        'Persisted private data ownership does not match the active account.',
      );
    }
  }
}
