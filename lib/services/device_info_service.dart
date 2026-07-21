import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';

/// Manages persistent device identity and hardware information
class DeviceInfoService {
  static const String _keyDeviceId = 'device_id';
  static const String _keyDeviceModel = 'device_model';
  static const String _keyOsVersion = 'device_os_version';

  static bool _initialized = false;
  static String? _deviceId;
  static String? _deviceModel;
  static String? _osVersion;

  /// Initialize service and load/generate device identifiers
  static Future<void> init() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Get or generate persistent device ID
      String deviceId = prefs.getString(_keyDeviceId) ?? '';
      if (deviceId.isEmpty) {
        deviceId = await _generateHardwareDeviceId();
        await prefs.setString(_keyDeviceId, deviceId);
      }
      _deviceId = deviceId;

      // Get or fetch device model and OS version
      String model = prefs.getString(_keyDeviceModel) ?? '';
      String osVersion = prefs.getString(_keyOsVersion) ?? '';

      if (model.isEmpty || osVersion.isEmpty) {
        final info = await _fetchDeviceInfo();
        model = info['model'] ?? 'unknown';
        osVersion = info['osVersion'] ?? 'unknown';
        await prefs.setString(_keyDeviceModel, model);
        await prefs.setString(_keyOsVersion, osVersion);
      }
      _deviceModel = model;
      _osVersion = osVersion;

      _initialized = true;
    } catch (e, stackTrace) {
      // In production, use proper logging
      print('[DeviceInfoService] init error: $e');
      print(stackTrace);
      rethrow;
    }
  }

  /// Generate hardware-based device identifier (persistent)
  static Future<String> _generateHardwareDeviceId() async {
    try {
      if (Platform.isAndroid) {
        const androidIdPlugin = AndroidId();
        final id = await androidIdPlugin.getId();
        return id ?? 'android_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isIOS) {
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ??
            'ios_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      print('[DeviceInfoService] Hardware ID generation failed: $e');
    }
    // Fallback: generate pseudo-unique ID
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Fetch device model and OS version
  static Future<Map<String, String>> _fetchDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String model = 'unknown';
    String osVersion = 'unknown';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        model = '${androidInfo.brand} ${androidInfo.model}';
        osVersion = 'Android ${androidInfo.version.release} (API ${androidInfo.version.sdkInt})';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        model = '${iosInfo.name} ${iosInfo.model}';
        osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
      }
    } catch (e) {
      print('[DeviceInfoService] Device info fetch failed: $e');
    }

    return {'model': model, 'osVersion': osVersion};
  }

  /// Get device ID (hardware identifier)
  static String? get deviceId => _deviceId;

  /// Get device model string
  static String? get deviceModel => _deviceModel;

  /// Get OS version string
  static String? get osVersion => _osVersion;

  /// Get all device info as map
  static Future<Map<String, String>> getDeviceInfo() async {
    await ensureInitialized();
    return {
      'device_id': _deviceId ?? '',
      'model': _deviceModel ?? '',
      'os_version': _osVersion ?? '',
    };
  }

  /// Ensure service is initialized
  static Future<void> ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  /// Clear stored device info (call on logout)
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyDeviceId);
      await prefs.remove(_keyDeviceModel);
      await prefs.remove(_keyOsVersion);
    } catch (e) {
      print('[DeviceInfoService] clear error: $e');
    } finally {
      _deviceId = null;
      _deviceModel = null;
      _osVersion = null;
      _initialized = false;
    }
  }
}
