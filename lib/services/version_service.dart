import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../core/pb_api.dart';

class AppVersionInfo {
  final String versionNo;
  final String changelog;
  final String downloadUrl;

  AppVersionInfo({
    required this.versionNo,
    required this.changelog,
    required this.downloadUrl,
  });
}

class VersionService {
  static Future<AppVersionInfo?> checkForUpdate() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return null;
      }

      final records = await PB.pb.collection('app_version').getFullList();
      if (records.isEmpty) {
        return null;
      }

      final serverVersion = records.first.data['version_no'] as String?;
      final changelog = records.first.data['changelog'] as String? ?? '';
      final downloadUrl = records.first.data['download_url'] as String? ?? '';

      if (serverVersion == null || downloadUrl.isEmpty) {
        return null;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isUpdateAvailable(currentVersion, serverVersion)) {
        return AppVersionInfo(
          versionNo: serverVersion,
          changelog: changelog,
          downloadUrl: downloadUrl,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static bool _isUpdateAvailable(String current, String server) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final serverParts = server.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        final currentNum = i < currentParts.length ? currentParts[i] : 0;
        final serverNum = i < serverParts.length ? serverParts[i] : 0;

        if (serverNum > currentNum) return true;
        if (serverNum < currentNum) return false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
