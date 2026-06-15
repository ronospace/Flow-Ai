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
