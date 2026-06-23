class ResolvedUserIdentity {
  final String displayName;
  final String greetingName;

  const ResolvedUserIdentity({
    required this.displayName,
    required this.greetingName,
  });
}

/// Resolves the short personal name displayed in greetings.
///
/// Priority:
/// 1. First email token when the address contains an explicit separator.
/// 2. First name supplied by the authenticated account provider.
/// 3. Empty string rather than exposing a concatenated email local part.
abstract final class UserDisplayNameResolver {
  static const Set<String> _placeholders = {
    'user',
    'flow ai user',
    'local ai',
    'guest',
    'unknown',
  };

  static String resolve({
    required String? email,
    required String? displayName,
  }) {
    final emailFirstName = firstNameFromEmail(email);

    if (emailFirstName.isNotEmpty) {
      return emailFirstName;
    }

    return firstNameFromDisplayName(displayName);
  }

  /// Separates the canonical profile name from the short greeting name.
  ///
  /// A provider/profile name is authoritative. A saved name is reused only
  /// for the same authenticated user. Email-derived text is a final fallback.
  static ResolvedUserIdentity resolveIdentity({
    required String? userId,
    required String? email,
    required String? displayName,
    required String existingUserId,
    required String existingDisplayName,
  }) {
    final normalizedUserId = userId?.trim() ?? '';
    final providerDisplayName = normalizeDisplayName(displayName);
    final sameUser =
        normalizedUserId.isNotEmpty && normalizedUserId == existingUserId;
    final savedDisplayName = sameUser
        ? normalizeDisplayName(existingDisplayName)
        : '';
    final emailFirstName = firstNameFromEmail(email);

    final canonicalDisplayName = providerDisplayName.isNotEmpty
        ? providerDisplayName
        : savedDisplayName.isNotEmpty
        ? savedDisplayName
        : emailFirstName;

    final profileFirstName = firstNameFromDisplayName(canonicalDisplayName);
    final greetingName = profileFirstName.isNotEmpty
        ? profileFirstName
        : emailFirstName;

    return ResolvedUserIdentity(
      displayName: canonicalDisplayName,
      greetingName: greetingName,
    );
  }

  static String normalizeDisplayName(String? displayName) {
    final value = displayName?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';

    if (value.isEmpty || _placeholders.contains(value.toLowerCase())) {
      return '';
    }

    return value;
  }

  static String firstNameFromEmail(String? email) {
    final value = email?.trim() ?? '';
    final atIndex = value.indexOf('@');

    if (atIndex <= 0 || atIndex == value.length - 1) {
      return '';
    }

    final localPart = value.substring(0, atIndex);

    if (!RegExp(r'[._+\-\s]').hasMatch(localPart)) {
      return '';
    }

    return _normalizeFirstToken(localPart);
  }

  static String firstNameFromDisplayName(String? displayName) {
    final value = displayName?.trim() ?? '';

    if (value.isEmpty || _placeholders.contains(value.toLowerCase())) {
      return '';
    }

    return _normalizeFirstToken(value);
  }

  static String _normalizeFirstToken(String value) {
    final normalized = value
        .trim()
        .replaceAll(RegExp(r'[._+\-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    if (normalized.isEmpty) {
      return '';
    }

    final token = normalized.split(' ').first;
    final cleaned = token
        .replaceAll(RegExp(r'^[^A-Za-zÀ-ÖØ-öø-ÿ]+'), '')
        .replaceAll(RegExp(r'[^A-Za-zÀ-ÖØ-öø-ÿ]+$'), '')
        .replaceAll(RegExp(r'\d+$'), '');

    if (cleaned.isEmpty) {
      return '';
    }

    final lower = cleaned.toLowerCase();

    if (_placeholders.contains(lower)) {
      return '';
    }

    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }
}
