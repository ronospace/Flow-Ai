class DeepLinkNormalizer {
  static String? normalizeToAppPath(String raw) {
    if (raw.trim().isEmpty) return null;

    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return null;

    if (uri.scheme == 'flowai') {
      if (uri.host == 'invite') {
        final code = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
        if (code.isEmpty) return null;
        return '/invite/$code';
      }

      final segs = uri.pathSegments;
      if (segs.length >= 2 && segs.first == 'invite') {
        return '/invite/${segs[1]}';
      }

      return null;
    }

    final segs = uri.pathSegments;
    if (segs.length >= 2 && segs.first == 'invite') {
      return '/invite/${segs[1]}';
    }

    return null;
  }
}
