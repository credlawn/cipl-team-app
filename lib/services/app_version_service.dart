import 'package:package_info_plus/package_info_plus.dart';

/// Service for obtaining application version information
class AppVersionService {
  static String? _cachedVersion;
  static String? _cachedBuildNumber;
  static String? _cachedAppName;

  /// Initialize and cache version info
  static Future<void> init() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _cachedVersion = packageInfo.version;
      _cachedBuildNumber = packageInfo.buildNumber;
      _cachedAppName = packageInfo.appName;
    } catch (e) {
      print('[AppVersionService] init error: $e');
      rethrow;
    }
  }

  /// Get app version (e.g., "1.2.3")
  static String? get version => _cachedVersion;

  /// Get build number
  static String? get buildNumber => _cachedBuildNumber;

  /// Get app name
  static String? get appName => _cachedAppName;

  /// Get version as string (ensures initialized)
  static Future<String> getVersion() async {
    if (_cachedVersion == null) {
      await init();
    }
    return _cachedVersion ?? '';
  }

  /// Get full version string with build number
  static Future<String> getFullVersion() async {
    final version = await getVersion();
    final build = _cachedBuildNumber ?? '';
    return build.isNotEmpty ? '$version+$build' : version;
  }
}
