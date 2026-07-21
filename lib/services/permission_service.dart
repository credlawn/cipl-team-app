import 'package:permission_handler/permission_handler.dart';
import 'package:call_log/call_log.dart' as cl;

/// Centralized permission collection service
class PermissionService {
  /// Collect status of all relevant permissions
  /// Returns a JSON string with permission names and their status
  static Future<String> collectPermissionStatus() async {
    try {
      final notificationStatus = await Permission.notification.status;
      final phoneStatus = await Permission.phone.status;
      final cameraStatus = await Permission.camera.status;
      final locationStatus = await Permission.location.status;

      // Call log permission requires query attempt to determine
      bool callLogGranted = false;
      try {
        await cl.CallLog.query(
          dateFrom: DateTime.now()
              .subtract(const Duration(days: 1))
              .millisecondsSinceEpoch,
        );
        callLogGranted = true;
      } catch (_) {
        callLogGranted = false;
      }

      final Map<String, String> statusMap = {
        'notification': notificationStatus.name,
        'phone': phoneStatus.name,
        'call_log': callLogGranted ? 'granted' : 'denied',
        'camera': cameraStatus.name,
        'location': locationStatus.name,
      };

      return _encodeJson(statusMap);
    } catch (e) {
      print('[PermissionService] collectPermissionStatus error: $e');
      return '{}';
    }
  }

  /// Check if critical permissions are granted
  static Future<bool> hasRequiredPermissions() async {
    final notification = await Permission.notification.status;
    final phone = await Permission.phone.status;

    return notification.isGranted && phone.isGranted;
  }

  /// Request notification and phone permissions
  static Future<Map<Permission, PermissionStatus>> requestCriticalPermissions() async {
    final results = <Permission, PermissionStatus>{};

    // Request phone permission first (most critical)
    final phoneResult = await Permission.phone.request();
    results[Permission.phone] = phoneResult;

    // Request notification permission
    final notificationResult = await Permission.notification.request();
    results[Permission.notification] = notificationResult;

    return results;
  }

  static String _encodeJson(Map<String, String> map) {
    // Simple JSON encoding without external dependency
    final entries = map.entries.map((e) => '"${e.key}":"${e.value}"').toList();
    return '{${entries.join(',')}}';
  }
}
