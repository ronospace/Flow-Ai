import 'package:package_info_plus/package_info_plus.dart';

/// Authoritative runtime identity/version metadata for the installed Flow Ai
/// application.
///
/// All runtime consumers must obtain app name, package/bundle identifier,
/// semantic version and build number from this owner instead of duplicating
/// release constants.
class AppRuntimeMetadataService {
  AppRuntimeMetadataService._();

  static final AppRuntimeMetadataService instance =
      AppRuntimeMetadataService._();

  PackageInfo? _packageInfo;
  Future<PackageInfo>? _loading;

  Future<PackageInfo> get packageInfo async {
    final cached = _packageInfo;
    if (cached != null) return cached;

    final activeLoad = _loading;
    if (activeLoad != null) return activeLoad;

    final load = PackageInfo.fromPlatform();
    _loading = load;

    try {
      final resolved = await load;
      _packageInfo = resolved;
      return resolved;
    } finally {
      _loading = null;
    }
  }

  Future<String> get appName async => (await packageInfo).appName;

  Future<String> get packageName async => (await packageInfo).packageName;

  Future<String> get version async => (await packageInfo).version;

  Future<String> get buildNumber async => (await packageInfo).buildNumber;

  Future<String> get versionWithBuild async {
    final info = await packageInfo;
    final build = info.buildNumber.trim();

    if (build.isEmpty) return info.version;
    return '${info.version}+$build';
  }
}
